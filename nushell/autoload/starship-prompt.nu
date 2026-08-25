# Loaded after vendor/autoload/starship.nu.
# Keep Nushell's stock left prompt and extend its indicators with Starship Git.

if "NU_STOCK_PROMPT_COMMAND" in $env {
    $env.PROMPT_COMMAND = $env.NU_STOCK_PROMPT_COMMAND
    hide-env NU_STOCK_PROMPT_COMMAND
}

if not (which starship | is-empty) {
    let render_indicator = {|symbol: string|
        let failed = $env.LAST_EXIT_CODE != 0
        let indicator = if $failed {
            $" (ansi red)($symbol)(ansi reset)"
        } else {
            $" ($symbol)"
        }

        let git = (
            ^starship prompt
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
        )

        if ($git | is-empty) {
            $"($indicator) "
        } else {
            $"($indicator)  ($git) "
        }
    }

    # PROMPT_INDICATOR is the emacs-mode fallback. In vi mode Nushell selects
    # ':' for insert mode and '>' for normal mode, matching its stock defaults.
    $env.PROMPT_INDICATOR = {|| do $render_indicator ":" }
    $env.PROMPT_INDICATOR_VI_INSERT = {|| do $render_indicator ":" }
    $env.PROMPT_INDICATOR_VI_NORMAL = {|| do $render_indicator ">" }
}
