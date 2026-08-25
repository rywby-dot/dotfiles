#!/usr/bin/env bash
set -Eeuo pipefail

DEFAULT_RATIO="${DECK_RATIO:-60}"

need() {
    command -v "$1" >/dev/null 2>&1 || {
        printf 'sway-deck: missing dependency: %s\n' "$1" >&2
        exit 1
    }
}

need swaymsg
need jq

usage() {
    cat <<'USAGE'
Usage:
  sway-deck apply [RATIO]     rebuild current workspace as deck
  sway-deck promote [RATIO]   make focused tiled window the master
  sway-deck ratio RATIO       change master width (percent)
  sway-deck watch             maintain deck on window new/close events

Environment:
  DECK_RATIO=60               default master width in percent
USAGE
}

validate_ratio() {
    local ratio="$1"

    [[ "$ratio" =~ ^[0-9]+$ ]] || {
        printf 'sway-deck: ratio must be an integer, got %q\n' "$ratio" >&2
        exit 2
    }

    (( ratio >= 10 && ratio <= 90 )) || {
        printf 'sway-deck: ratio must be between 10 and 90\n' >&2
        exit 2
    }
}

focused_workspace_info() {
    swaymsg -r -t get_workspaces |
        jq -c 'first(.[] | select(.focused == true))'
}

workspace_tree() {
    local ws_name="$1"

    swaymsg -r -t get_tree |
        jq -c --arg ws "$ws_name" '
            first(
                recurse(.nodes[]?)
                | select(.type == "workspace" and .name == $ws)
            )
        '
}

window_ids() {
    jq -r '
        recurse(.nodes[]?)
        | select(
            .type == "con"
            and (.app_id != null or .window != null)
        )
        | .id
    '
}

focused_tiled_id() {
    jq -r '
        [
            recurse(.nodes[]?)
            | select(
                .type == "con"
                and .focused == true
                and (.app_id != null or .window != null)
            )
            | .id
        ][0] // empty
    '
}

marked_id() {
    local mark="$1"

    jq -r --arg mark "$mark" '
        [
            recurse(.nodes[]?)
            | select(
                .type == "con"
                and ((.marks // []) | index($mark))
            )
            | .id
        ][0] // empty
    '
}

cmd() {
    swaymsg -q "$1"
}

rebuild() {
    local mode="$1"
    local ratio="$2"

    validate_ratio "$ratio"

    local ws_info ws_name ws_id tree
    local focus_id master_id

    ws_info="$(focused_workspace_info)"
    [[ -n "$ws_info" && "$ws_info" != "null" ]] || exit 0

    ws_name="$(jq -r '.name' <<<"$ws_info")"
    ws_id="$(jq -r '.id' <<<"$ws_info")"

    tree="$(workspace_tree "$ws_name")"
    [[ -n "$tree" && "$tree" != "null" ]] || exit 0

    local master_mark="_deck_master_${ws_id}"
    local stack_mark="_deck_stack_${ws_id}"
    local tmp_ws="__sway_deck_tmp_${ws_id}_$$"

    mapfile -t ids < <(window_ids <<<"$tree")

    ((${#ids[@]} > 0)) || exit 0

    focus_id="$(focused_tiled_id <<<"$tree")"

    if [[ "$mode" == "promote" ]]; then
        [[ -n "$focus_id" ]] || {
            printf 'sway-deck: focus a tiled window first\n' >&2
            exit 1
        }

        master_id="$focus_id"
    else
        master_id="$(marked_id "$master_mark" <<<"$tree")"

        if [[ -z "$master_id" ]]; then
            if [[ -n "$focus_id" ]]; then
                master_id="$focus_id"
            else
                master_id="${ids[0]}"
            fi
        fi
    fi

    # Remove stale marks and remember master.
    cmd "[con_mark=$master_mark] unmark $master_mark" || true
    cmd "[con_mark=$stack_mark] unmark $stack_mark" || true

    cmd "[con_id=$master_id] mark --add $master_mark"

    local stack_ids=()
    local id

    for id in "${ids[@]}"; do
        [[ "$id" == "$master_id" ]] && continue
        stack_ids+=("$id")
    done

    # Only one window -> just master.
    if ((${#stack_ids[@]} == 0)); then
        [[ -n "$focus_id" ]] &&
            cmd "[con_id=$focus_id] focus" || true
        exit 0
    fi

    # Temporarily detach all stack windows from the existing tree.
    # We use another workspace rather than scratchpad so they stay tiled.
    for id in "${stack_ids[@]}"; do
        cmd "[con_id=$id] move container to workspace $tmp_ws"
    done

    #
    #     MASTER | STACK
    #
    cmd "[con_id=$master_id] focus"
    cmd "[con_id=$master_id] split h"

    local anchor="${stack_ids[0]}"

    cmd "[con_id=$anchor] move container to mark $master_mark"
    cmd "[con_id=$anchor] mark --add $stack_mark"

    #
    # Create:
    #
    # ┌───────────┬───────────┐
    # │           │ 2 | 3 | 4 │
    # │  MASTER   ├───────────┤
    # │           │   deck    │
    # └───────────┴───────────┘
    #
    if ((${#stack_ids[@]} >= 2)); then
        cmd "[con_id=$anchor] split v"

        cmd "[con_id=${stack_ids[1]}] move container to mark $stack_mark"

        cmd "[con_id=$anchor] layout tabbed"

        if ((${#stack_ids[@]} >= 3)); then
            for id in "${stack_ids[@]:2}"; do
                cmd "[con_id=$id] move container to mark $stack_mark"
            done
        fi
    fi

    cmd "[con_id=$master_id] resize set width $ratio ppt" || true

    # Preserve original focus.
    if [[ -n "$focus_id" ]]; then
        cmd "[con_id=$focus_id] focus" || true
    fi
}

set_ratio() {
    local ratio="$1"

    validate_ratio "$ratio"

    local ws_info ws_name ws_id tree master_id

    ws_info="$(focused_workspace_info)"
    [[ -n "$ws_info" && "$ws_info" != "null" ]] || exit 0

    ws_name="$(jq -r '.name' <<<"$ws_info")"
    ws_id="$(jq -r '.id' <<<"$ws_info")"

    tree="$(workspace_tree "$ws_name")"

    local master_mark="_deck_master_${ws_id}"

    master_id="$(marked_id "$master_mark" <<<"$tree")"

    if [[ -z "$master_id" ]]; then
        rebuild apply "$ratio"
    else
        cmd "[con_id=$master_id] resize set width $ratio ppt"
    fi
}

watch() {
    need flock

    local lock="${XDG_RUNTIME_DIR:-/tmp}/sway-deck-watch.lock"

    exec 9>"$lock"
    flock -n 9 || exit 0

    # Do not watch "move"/"mark": rebuild() itself generates them.
    swaymsg -m -r -t subscribe '["window"]' |
        jq -c --unbuffered \
            'select(.change == "new" or .change == "close")' |
        while IFS= read -r _event; do
            "$0" apply "$DEFAULT_RATIO" || true
        done
}

case "${1:-apply}" in
    apply)
        rebuild apply "${2:-$DEFAULT_RATIO}"
        ;;

    promote)
        rebuild promote "${2:-$DEFAULT_RATIO}"
        ;;

    ratio)
        [[ $# -ge 2 ]] || {
            usage >&2
            exit 2
        }

        set_ratio "$2"
        ;;

    watch)
        watch
        ;;

    -h|--help|help)
        usage
        ;;

    *)
        usage >&2
        exit 2
        ;;
esac
