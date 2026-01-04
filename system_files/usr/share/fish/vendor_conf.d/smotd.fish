#!/usr/bin/fish
#shellcheck disable=all

function fish_greeting
    if test -d "$HOME"
        if test ! -e "$HOME"/.config/mercuryos/no-show-user-motd
            if test -x /usr/bin/smotd
               /usr/bin/smotd
            end
        end
    end
    if set -q fish_private_mode
        echo "fish is running in private mode, history will not be persisted."
    end
end
