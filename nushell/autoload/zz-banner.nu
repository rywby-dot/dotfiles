# Replace the standard Nushell banner with a compact startup message.
$env.config.show_banner = false

let banner = r#'     __  ,
 .--()°'.'
'|, . ,'
 !_-(_\'#

$env.NU_COMPACT_BANNER_PENDING = true

let show_compact_banner = {||
    if "NU_COMPACT_BANNER_PENDING" in $env {
        print $"(ansi green)($banner)(ansi reset)"
        print $"(ansi green_bold)Startup Time:(ansi reset) (ansi white)($nu.startup-time)(ansi reset)"
        hide-env NU_COMPACT_BANNER_PENDING
    }
}

$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt?
    | default []
    | append $show_compact_banner
)
