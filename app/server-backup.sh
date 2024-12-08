#!/bin/bash

rsync -aAXve "ssh -p 989" root@91.147.92.228:/etc/openvpn /home/navgeo/netserver_backup/
rsync -aAXve "ssh -p 989" root@91.147.92.228:/home/wildroger/cert_user_files /home/navgeo/netserver_backup/

#Чтобы восстановить систему из резервной копии, просто измените исходные и целевые пути в приведенной выше команде.
#rsync -aAXve "ssh -p 989" /home/navgeo/netserver_backup/openvpn root@91.147.92.228:/etc/