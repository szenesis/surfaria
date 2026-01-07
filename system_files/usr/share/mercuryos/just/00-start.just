sdots_path := "/usr/share/mercuryos/sdots"
toggle-user-motd:
    #!/usr/bin/env bash

    TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/mercuryos/no-show-user-motd"

    if [ -e "$TARGET" ] ; then
         rm -r "${TARGET}"
         echo "Enabled the MOTD"
         exit 0
    fi
    mkdir -p "$(dirname "$(realpath ${TARGET})")"
    touch "${TARGET}"
    echo "Disabled the MOTD"
update:
    sudo uupd
