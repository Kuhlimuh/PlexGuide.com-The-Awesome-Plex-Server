#!/bin/bash
#
# [PlexGuide Menu]
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705 & Deiteq
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
export NCURSES_NO_UTF8_ACS=1
echo 'INFO - @Unencrypted PG Drive Menu' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh

#### Recalls from prior menu what user selected
selected=$( cat /var/plexguide/menu.select )
################################################################## CORE

HEIGHT=11
WIDTH=35
CHOICE_HEIGHT=4
BACKTITLE="Visit https://PlexGuide.com - Automations Made Simple"
TITLE="PGDrive /w $selected"
MENU="Make a Selection:"

OPTIONS=(A "Config : RClone"
         B "Deploy : PGDrive"
         C "Deploy : $selected"
         Z "Exit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        A)
            #### RClone Missing Warning - START
            file="/usr/bin/rclone" 1>/dev/null 2>&1
              if [ -e "$file" ]
                then
                  echo "" 1>/dev/null 2>&1
                else
                  echo 'WARNING - You Must Install RCLONE First' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
                  dialog --title "WARNING!" --msgbox "\nYou Need to Install RClone First" 0 0
                  bash /opt/plexguide/menus/mount/main.sh
                  exit
              fi
echo 'INFO - Configured RCLONE for PG Drive' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh

            #### RClone Missing Warning - END
            rclone config
            touch /mnt/gdrive/plexguide/ 1>/dev/null 2>&1
            #### GREP Checks
            tdrive=$(grep "tdrive" /root/.config/rclone/rclone.conf)
            gdrive=$(grep "gdrive" /root/.config/rclone/rclone.conf)
            mkdir -p /root/.config/rclone/
            chown -R 1000:1000 /root/.config/rclone/
            cp ~/.config/rclone/rclone.conf /root/.config/rclone/ 1>/dev/null 2>&1
            #################### installing dummy file for prep of pgdrive deployment
            file="/mnt/unionfs/plexguide/pgchecker.bin"
            if [ -e "$file" ]
            then
               echo 'PASSED - UnionFS is Properly Working - PGChecker.Bin' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            else
               mkdir -p /mnt/tdrive/plexguide/ 1>/dev/null 2>&1
               mkdir -p /mnt/gdrive/plexguide/ 1>/dev/null 2>&1
               mkdir -p /tmp/pgchecker/ 1>/dev/null 2>&1
               touch /tmp/pgchecker/pgchecker.bin 1>/dev/null 2>&1
               rclone copy /tmp/pgchecker gdrive:/plexguide/ &>/dev/null &
               rclone copy /tmp/pgchecker tdrive:/plexguide/ &>/dev/null &
               echo 'INFO - Deployed PGChecker.bin - PGChecker.Bin' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            fi
            ;;
        B)
            #### RCLONE MISSING START
            file="/usr/bin/rclone" 1>/dev/null 2>&1
              if [ -e "$file" ]
                then
                  echo "" 1>/dev/null 2>&1
                else
                echo 'WARNING - You Must Install RCLONE First' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
                  dialog --title "WARNING!" --msgbox "\nYou Need to Install RClone First" 0 0
                  bash /opt/plexguide/menus/mount/main.sh
                  exit
              fi

            #### RCLONE MISSING END
echo 'INFO - DEPLOYED PG Drive' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh

            #### RECALL VARIABLES START
            tdrive=$(grep "tdrive" /root/.config/rclone/rclone.conf)
            gdrive=$(grep "gdrive" /root/.config/rclone/rclone.conf)
            #### RECALL VARIABLES END

            #### REQUIRED TO DEPLOY STARTING
            ansible-playbook /opt/plexguide/pg.yml --tags pgdrive_standard
#            ansible-playbook /opt/plexguide/scripts/test/check-remove/tasks/main.yml

            #### BLANK OUT PATH - This Builds For UnionFS
            rm -r /var/plexguide/unionfs.pgpath 1>/dev/null 2>&1
            touch /var/plexguide/unionfs.pgpath 1>/dev/null 2>&1

            #### IF EXIST - DEPLOY
            if [ "$tdrive" == "[tdrive]" ]
              then

              #### ADDS TDRIVE to the UNIONFS PATH
              echo -n "/mnt/tdrive=RO:" >> /var/plexguide/unionfs.pgpath
              ansible-playbook /opt/plexguide/pg.yml --tags tdrive
            fi

            if [ "$gdrive" == "[gdrive]" ]
              then

              #### ADDS GDRIVE to the UNIONFS PATH
              echo -n "/mnt/gdrive=RO:" >> /var/plexguide/unionfs.pgpath
              ansible-playbook /opt/plexguide/pg.yml --tags gdrive
            fi

            #### REQUIRED TO DEPLOY ENDING
            ansible-playbook /opt/plexguide/pg.yml --tags unionfs
            ansible-playbook /opt/plexguide/pg.yml --tags ufsmonitor

            read -n 1 -s -r -p "Press any key to continue"
            dialog --title "NOTE" --msgbox "\nPG Drive Deployed!!" 0 0
            ;;
        C)
            #### RClone Missing Warning -START
            file="/usr/bin/rclone" 1>/dev/null 2>&1
              if [ -e "$file" ]
                then
                  echo "" 1>/dev/null 2>&1
                else
                  dialog --title "WARNING!" --msgbox "\nYou Need to Install RClone First" 0 0
                  bash /opt/plexguide/menus/mount/main.sh
                  exit
              fi
            #### RClone Missing Warning - END

            #### RECALL VARIABLES START
            tdrive=$(grep "tdrive" /root/.config/rclone/rclone.conf)
            gdrive=$(grep "gdrive" /root/.config/rclone/rclone.conf)
            #### RECALL VARIABLES END

            #### BASIC CHECKS to STOP Deployment - START
            if [[ "$selected" == "Move" && "$gdrive" != "[gdrive]" ]]
              then
echo 'FAILURE - Using MOVE: Must Configure gdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            dialog --title "WARNING!" --msgbox "\nYou are UTILZING PG Move!\n\nTo work, you MUST have a gdrive\nconfiguration in RClone!" 0 0
            bash /opt/plexguide/menus/mount/unencrypted.sh
            exit
            fi

            if [[ "$selected" == "ZenDrive" && "$gdrive" != "[gdrive]" ]]
              then
echo 'FAILURE - Using MOVE: Must Configure gdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            dialog --title "WARNING!" --msgbox "\nYou are UTILZING PG Move!\n\nTo work, you MUST have a gdrive\nconfiguration in RClone!" 0 0
            bash /opt/plexguide/menus/mount/unencrypted.sh
            exit
            fi

            if [[ "$selected" == "SuperTransfer2" && "$tdrive" != "[tdrive]" ]]
              then
echo 'FAILURE - USING ST2: Must Configure tdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            dialog --title "WARNING!" --msgbox "\nYou are UTILZING PG SuperTransfer2!\n\nTo work, you MUST have a tdrive\nconfiguration in RClone!" 0 0
            bash /opt/plexguide/menus/mount/unencrypted.sh
            exit
            fi

            if [[ "$selected" == "SuperTransfer2" && "$gdrive" != "[gdrive]" ]]
              then
echo 'FAILURE - USING ST2: Must Configure tdrive for RCLONE' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            dialog --title "WARNING!" --msgbox "\nYou are UTILZING PG SuperTransfer2!\n\nTo work, you MUST have a tdrive\nconfiguration in RClone!" 0 0
            bash /opt/plexguide/menus/mount/unencrypted.sh
            exit
            fi

            #### DEPLOY a TRANSFER SYSTEM - START
            if [ "$selected" == "Move" ]
            then
              ansible-playbook /opt/plexguide/pg.yml --tags move1
              read -n 1 -s -r -p "Press any key to continue"
            fi

            if [ "$selected" == "ZenDrive" ]
            then
              ansible-playbook /opt/plexguide/pg.yml --tags move2
              read -n 1 -s -r -p "Press any key to continue"
            fi

            if [ "$selected" == "SuperTransfer2" ]
            then
              systemctl stop move 1>/dev/null 2>&1
              systemctl disable move 1>/dev/null 2>&1
              clear
              bash /opt/plexguide/scripts/supertransfer/config.sh
              ansible-playbook /opt/plexguide/pg.yml --tags supertransfer2
              journalctl -f -u supertransfer2
              read -n 1 -s -r -p "Press any key to continue"
            fi

            #### DEPLOY a TRANSFER SYSTEM - END
            dialog --title "NOTE!" --msgbox "\n$selected is now running!" 7 38
            echo 'SUCCESS - $selected is now running!' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            ;;
            F)
            ansible-playbook /opt/plexguide/scripts/test/check-remove/tasks/main.yml
            echo 'INFO - REMOVED OLD SERVICES' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            #ansible-role services_remove
            dialog --title " All Google Related Services Removed!" --msgbox "\nPlease re-run:-\n             'Deploy : PGDrive'\n     and     'Deploy : $selected'" 0 0
            ;;
        Z)
            exit 0 ;;

########## Deploy End
esac

bash /opt/plexguide/menus/mount/unencrypted.sh

       #E)
       #     if [ ! "$(docker ps -q -f name=plex)" ]; then
       #       dialog --title "NOTE!" --msgbox "\nPlex needs to be running!" 7 38
       #     else
       #       if [ ! -s /opt/appdata/plexguide/plextoken ]; then
       #         dialog --title "NOTE!" --msgbox "\nYour plex username and password is needed to get your plextoken!" 7 38
       #         bash /opt/plexguide/scripts/plextoken/main.sh
       #       fi
       #       ansible-role pgscan
       #       dialog --title "Your PGscan URL - We Saved It" --msgbox "\nURL: $(cat /opt/appdata/plexguide/pgscanurl)\nNote: You need this for sonarr/radarr!\nYou can always get it later!" 0 0
       #     fi
       #     ;;
        F)
            ansible-playbook /opt/plexguide/scripts/test/check-remove/tasks/main.yml
            echo 'INFO - REMOVED OLD SERVICES' > /var/plexguide/pg.log && bash /opt/plexguide/scripts/log.sh
            #ansible-role services_remove
            dialog --title " All Google Related Services Removed!" --msgbox "\nPlease re-run:-\n             'Deploy : PGDrive'\n     and     'Deploy : $selected'" 0 0
            ;;
