#!/bin/bash
echo "*******************"
PS3='Select an option and press Enter (hit enter to show all options): '
options=("Check Management Accounts" "Update managemen account for vCenter" "Update management account for the nodes" "Check PSNTs and Serial numbers" "Quit")
select opt in "${options[@]}"
do
  case $opt in
        "Check Management Accounts")
                echo ""
                echo "Checking vCenter account"
                echo ""
                curl --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -X GET "http://localhost/rest/vxm/internal/lockbox/v1/credentials?lockbox_name=SYSTEM&credential_names=management_account_vc" |jq
                sleep 2
                echo ""
                echo "Checking ESXi accounts"
                echo ""
                psql -U postgres vxrail -c "Select sn  from node.node" | sed -n '1!p' | sed -n '1!p' | head -n -2 > /$PWD/sn.txt
while read i;do curl --unix-socket /var/lib/vxrail/nginx/socket/nginx.sock -X GET "http://localhost/rest/vxm/internal/lockbox/v1/credentials?lockbox_name=SYSTEM&credential_names=management_account_esxi__{$i}" | jq ;sleep 2; done < /$PWD/sn.txt
                rm /$PWD/sn.txt
                echo ""
          ;;
        "Update managemen account for vCenter")
                echo ""
                echo "Type the username for the vCenter management account:"
                read mgmtusername
                echo ""
                echo "Type the hash for password for the vCenter management account:"
                read mgmtpassword
                echo ""
                read -p "Proceed updating account (Y/N) " -n 1 -r
                echo  ""
                if [[ $REPLY =~ ^[Yy]$ ]]
                        then

curl -X PUT --unix-socket  /var/lib/vxrail/nginx/socket/nginx.sock "http://localhost/rest/vxm/internal/lockbox/v1/credentials" -H "accept: application/json" -H "Content-Type: application/json" -d '{"lockbox_name":"SYSTEM","credentials":[{"credential_name":"management_account_vc","username":"'$mgmtusername'","password":"'$mgmtpassword'"}]}'

                fi
                ;;
        "Update management account for the nodes")

                echo "Update management account for the nodes"
                echo ""
                echo "This option will set the SAME management account / password for all nodes in the cluster. If you need to set it individually, proceed with the manual process from KB 000157662"
                echo ""
                psql -U postgres vxrail -c "Select sn  from node.node" | sed -n '1!p' | sed -n '1!p' | head -n -2 > /$PWD/sn.txt
                echo "Type the username for the ESXi management account:"
                read esximgmtusername
                echo ""
                echo "Type the hash for password for the esxi management account:"
                read esximgmtpassword
                echo ""
                read -p "Proceed updating account (Y/N) " -n 1 -r
                echo  ""
                if [[ $REPLY =~ ^[Yy]$ ]]
                        then
                        while read i;do curl -X PUT --unix-socket  /var/lib/vxrail/nginx/socket/nginx.sock "http://localhost/rest/vxm/internal/lockbox/v1/credentials" -H "accept: application/json" -H "Content-Type: application/json" -d '{"lockbox_name":"SYSTEM","credentials":[{"credential_name":"management_account_esxi__'$i'","username":"'$esximgmtusername'","password":"'$esximgmtpassword'"}]}' ; done < /$PWD/sn.txt
                fi

                rm /$PWD/sn.txt

                ;;
        "Check PSNTs and Serial numbers")
                echo ""
                psql -U postgres vxrail -c "Select chassis_id,sn  from node.node"
                ;;
                  "Quit")
                echo "Quiting"
                break
                ;;

        *) echo "invalid option";;
  esac
done
echo "*********************"
