# Script d'initialisation d'un serveur Debian après son installation.

    
![Menu](https://github.com/Xev-47/Init-Debian-Script/blob/main/menu.png)


## Fonctionnalités

- Ajouter un compte et désactiver le compte **root**
- Mettre le système à jour et installer les mises à jour automatiquement
- Ajouter le compte **docker**, installer **docker** et **Portainer** (port 9000)
- Personnaliser l'écran d'accueil
- Modifier le port **ssh** et empêcher l'accès **root**
- Installer outils (MC,...)



## Installation

* root
  ``wget -qO ./i https://raw.githubusercontent.com/Xev-47/Init-Debian-Script/main/init.sh && chmod +x i && ./i
  ``
* non root
 ``sudo wget -qO ./i https://raw.githubusercontent.com/Xev-47/Init-Debian-Script/main/init.sh && sudo chmod +x i && sudo ./i
``

