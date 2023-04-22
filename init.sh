#!/bin/sh
apt-get update
apt install dialog -y
DIALOG=${DIALOG=dialog}

fichtemp=`tempfile 2>/dev/null` || fichtemp=/tmp/test$$
fichtemp2=`tempfile2 2>/dev/null` || fichtemp2=/tmp/test$$
fichtemp3=`tempfile3 2>/dev/null` || fichtemp3=/tmp/test$$
fichtemp4=`tempfile 2>/dev/null` || fichtemp4=/tmp/test$$

menu () {
# Menu
trap "rm -f $fichtemp" 0 1 2 5 15
$DIALOG --clear \
  --backtitle "Initialisation d'un système" \
  --title "Initialisation d'un système" \
        --menu "Sélectionner l'action a exécuter" 13 85 4 \
         "Compte" "Ajouter un compte et désactiver le compte root" \
         "Maj" "Mettre le système à jour et installer les mises à jour automatiquement" \
         "Docker" "Ajouter le compte docker, installer docker et Portainer (port 9000)" \
         "Accueil" "Personnaliser l'écran d'accueil" \
         "SSH" "Modifier le port ssh et empêcher l'accès root" \
         "Outils" "Installer outils (MC, Nano, Fail2ban..)" 2> $fichtemp
valret=$?
choix=`cat $fichtemp`

case $valret in
 0)     echo "'$choix'"
  case $choix in
  # Ajouter un compte et désactiver le compte root
    Compte)
    $DIALOG --title "Création d'un compte" --clear \
    --backtitle "Initialisation d'un système - Création d'un compte" \
          --inputbox "Saisir le nom du compte\n
    " 16 51 2> $fichtemp2
    adduser $(cat $fichtemp2)
    apt install sudo -y
    usermod -aG sudo $(cat $fichtemp2)
    passwd -l root
    menu
    ;;
  # Mettre le système à jour et installer les mises à jour automatiquement
  Maj)
    apt-get update
    apt-get upgrade -y
    apt-get install unattended-upgrades apt-listchanges -y
    menu
    ;;
  # Ajouter le compte docker, installer docker et Portainer (port 9000)
  Docker)
      newgrp docker
      groupadd docker
      useradd docker -gdocker
      usermod -aG docker docker
      mkdir /home/docker
            chown docker:docker /home/docker -R
      chmod g+rwx /home/docker -R
      apt install curl -y
      curl -fsSL https://get.docker.com -o get-docker.sh
      chmod +x get-docker.sh
      sh get-docker.sh
      get-docker.sh
      rm get-docker.sh
      apt install docker-compose docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
      systemctl enable docker.service
      mkdir /home/docker/Portainer
      chown docker:docker /home/docker/Portainer
      cd /home/docker/Portainer
      echo "version: '3'" > docker-compose.yml
      echo "services:" >> docker-compose.yml
      echo "  portainer:" >> docker-compose.yml
      echo "    image: portainer/portainer-ce:latest" >> docker-compose.yml
      echo "    container_name: Portainer" >> docker-compose.yml
      echo "    command: -H unix:///var/run/docker.sock" >> docker-compose.yml
      echo "    security_opt:" >> docker-compose.yml
      echo "      - no-new-privileges:true" >> docker-compose.yml
      echo "    volumes:" >> docker-compose.yml
      echo "      - /etc/localtime:/etc/localtime:ro" >> docker-compose.yml
      echo "      - /var/run/docker.sock:/var/run/docker.sock:ro" >> docker-compose.yml
      echo "      - /home/docker/Portainer:/data" >> docker-compose.yml
      echo "    ports:" >> docker-compose.yml
      echo "      - \"9000:9000\"" >> docker-compose.yml
      echo "    labels:" >> docker-compose.yml
      echo "      - \"traefik.backend=Portainer\"" >> docker-compose.yml
      echo "      - \"traefik.docker.network=web\"" >> docker-compose.yml
      echo "      - \"traefik.enable=true\"" >> docker-compose.yml
      echo "      - \"traefik.http.routers.portainer.entrypoints=interne\"" >> docker-compose.yml
      echo "      - \"traefik.http.routers.portainer.rule=Host(\`portainer.my-server.com\`)\"" >> docker-compose.yml
      echo "      - \"traefik.http.services.portainer.loadbalancer.server.port=9000\"" >> docker-compose.yml
      echo "      - \"com.centurylinklabs.watchtower.enable=true\"" >> docker-compose.yml
      echo "    networks:" >> docker-compose.yml
      echo "      - web" >> docker-compose.yml
      echo "    hostname: portainer" >> docker-compose.yml
      echo "    restart: always" >> docker-compose.yml
      echo "" >> docker-compose.yml
      echo "networks:" >> docker-compose.yml
      echo "  web:" >> docker-compose.yml
      echo "    external:" >> docker-compose.yml
      echo "      name:  web" >> docker-compose.yml
      docker network create web
      docker-compose up -d
      menu
      ;;
  # Personnaliser l'écran d'accueil
  Accueil)
      apt-get install neofetch -y
      echo "#!/bin/bash" > /etc/profile.d/mymotd.sh
      echo "clear" >> /etc/profile.d/mymotd.sh
      echo "" >> /etc/profile.d/mymotd.sh
      echo "disquepourcent=$(df -Th -x tmpfs -x devtmpfs -x overlay / |awk '{print $6}'|grep '%'| sed 's/%//')" >> /etc/profile.d/mymotd.sh
      echo "disquetotal=$(df -Th -x tmpfs -x devtmpfs -x overlay / |awk '{print $3}'|grep 'G')" >> /etc/profile.d/mymotd.sh
      echo "disqueutil=$(df -Th -x tmpfs -x devtmpfs -x overlay / |awk '{print $4}'|grep 'G')" >> /etc/profile.d/mymotd.sh
      echo "ip=\$(hostname -I|awk '{print \$1}')" >> /etc/profile.d/mymotd.sh
      echo "host=\$(hostname)" >> /etc/profile.d/mymotd.sh
      echo "user=\`whoami\`" >> /etc/profile.d/mymotd.sh
      echo "echo" >> /etc/profile.d/mymotd.sh
      echo "if [[ -f /usr/bin/neofetch ]] ; then neofetch ; fi" >> /etc/profile.d/mymotd.sh
      echo "derniereco=\$(lastlog|grep -v \"Never logged\"|tail +2)" >> /etc/profile.d/mymotd.sh
      echo "uptime=\$(uptime -p)" >> /etc/profile.d/mymotd.sh
      echo "swaptotal=\$(cat /proc/meminfo | grep SwapTotal | awk {'print \$2 \" \" \$3'})" >> /etc/profile.d/mymotd.sh
      echo "memtotal=\$(free | awk '/Mem:/{printf(\"%.0f\", \$2*1000)}')" >> /etc/profile.d/mymotd.sh
      echo "memtotal=\$(numfmt --from=iec --to=si --suffix= --format=\"%9.2f\" \$memtotal)" >> /etc/profile.d/mymotd.sh
      echo "pourcentfree=\$(free | awk '/Mem:/{printf(\"%.0f\", \$3/\$2*100)}')" >> /etc/profile.d/mymotd.sh
      echo "memutil=\$(free | awk '/Mem:/{printf(\"%.0f\", \$3*1000)}')" >> /etc/profile.d/mymotd.sh
      echo "memutil=\$(numfmt --from=iec --to=si --suffix= --format=\"%9.2f\" \$memutil)" >> /etc/profile.d/mymotd.sh
      echo "usersco=\$(users | tr ' ' '\\\n' | sort | uniq | wc -w)" >> /etc/profile.d/mymotd.sh
      echo "echo" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[32m\"" >> /etc/profile.d/mymotd.sh
      echo "echo" >> /etc/profile.d/mymotd.sh
      echo "echo" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[34mBienvenue \$user sur \`hostname\`\\\033[0;36m (\$ip)\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[0;31mUptime :\\\033[1;30m \${uptime}\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[0;31mUtilisateur(s) :\\\033[1;30m \${usersco} utilisateur(s) connecté(s)\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[0;31mDernières connexions :\\\033[1;30m\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\${derniereco}\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[0;31mUtilisation Mémoire :\\\033[1;30m \${pourcentfree}%% - \${memutil}o / \${memtotal}o\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\033[0;31mUtilisation Disque  :\\\033[1;30m \${disquepourcent}%% - \${disqueutil}o / \${disquetotal}o\\\n\"" >> /etc/profile.d/mymotd.sh
      echo "update=\$(apt update 2>&1 | grep -c \"Tous les paquets sont à jour\")" >> /etc/profile.d/mymotd.sh
      echo "if [ \"\${update}\" = \"0\" ] ; then printf \"\\\033[5;31mMises à jours disponibles\\\033[m\\\n\" ; else printf \"\\\033[0;32mSystème à jour\033[m\n\" ; fi" >> /etc/profile.d/mymotd.sh
      echo "printf \"\\\n\"" >> /etc/profile.d/mymotd.sh
      chmod +x /etc/profile.d/mymotd.sh
      menu
      ;;
  # Modifier le port ssh et empêcher l'accès root
  SSH)
    $DIALOG --title "Numéro de port" --clear \
          --backtitle "Initialisation d'un système - Modification du port ssh" \
          --inputbox "Saisir le numéro de port\n
    " 16 51 2> $fichtemp3
    valret=$?
    numero=`cat $fichtemp3`
    sed -i -e "s/#Port 22/Port $numero/g" /etc/ssh/sshd_config
        sed -i -e "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
      menu
      ;;
  # Installer outils (MC, Nano, Fail2ban..)
  Outils)
      trap "rm -f $fichtemp4" 0 1 2 5 15
    $DIALOG --backtitle "Initialisation d'un système - Liste des applications" \
        --title "Liste des applications" --clear \
        --checklist "Sélectionner les applications à installer " 20 61 5 \
        "nano" "Editeur de texte" ON\
        "mc" "Gestionnaire de fichiers" ON\
        "fail2ban" "Surveillance des logs" off 2> $fichtemp4
    valret=$?
    choix2=`cat $fichtemp4`
    case $valret in
      0)
      echo "'$choix' est votre chanteur préféré"
      apt install $choix2 -y;;
      1)
      echo "Appuyé sur Annuler.";;
      255)
      echo "Appuyé sur Echap.";;
    esac

      menu
       ;;
  esac
  ;;
 1)     # echo "Appuyé sur Annuler."
      apt-get remove dialog -y
        apt-get autoremove -y
        apt-get autoclean -y
  clear
  clear
  ;;
255)    # echo "Appuyé sur Echap."
      apt-get remove dialog -y
        apt-get autoremove -y
        apt-get autoclean -y
  ;;
esac
}

menu
