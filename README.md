# Zeppelin on Docker

Questo repository contiene il Dockerfile e i relativi file per poter eseguire Zeppelin in ambito SDP.

L'immagine è ispirata, nella sua parte di collegamento con FreeIPA, al client proposto direttamente dal [progetto ufficiale FreeIPA per CentOS 7](https://github.com/freeipa/freeipa-container/tree/centos-7-client), ma estesa e adattata per utilizzarlo all'interno della piattaforma tramite [Apache Zeppelin](https://zeppelin.apache.org/).

L'immagine di Zeppelin, con le relative funzionalità, è ispirata invece al repository di [xemuliam](https://hub.docker.com/r/xemuliam/zeppelin-base)


## Prerequisiti

 - [Docker](https://docs.docker.com/install/)
 - [docker-compose](https://docs.docker.com/compose/install/) (facoltativo, ma consigliato per la facilità d'uso)
 - Popolare il file *.env* nella root del repository con le variabili d'ambiente che serviranno all'immagine per essere eseguita.

## Build
Per effettuare delle modifiche all'immagine, effettuarne il *clone* tramite **git** e successivamente fare la build dell'immagine eseguendo il comando

    docker build -t my-zeppelin:my-tag .

## Esecuzione
Dopo aver fatto la build, l'immagine (*my-zeppelin:my-tag*) è pronta per essere eseguita. Alternativamente l'immagine da utilizzare potrà già essere quella presente su Docker Cloud (*pietrocannalire/zeppelin:[tag]*).

Due modalità di esecuzione:

 1. *Docker CLI*

	`docker run -d -p 8080:8080 -p 8443:8443 -v freeipa-backups:/etc/security/freeipa-backups  -v logs:/opt/zeppelin/logs -v notebook:/opt/zeppelin/notebook --env-file -v keytabs:/etc/security/keytabs ./.env --name zeppelin my-zeppelin:my-tag`

 2. *docker-compose*

	`docker-compose up`

	dalla root del repository, dove si trova il file *docker-compose.yml*,
	facendo attenzione a sostituire il nome corretto dell'immagine alla voce *image: ...* (per esempio *my-zeppelin:my-tag*)

N.B.: se le porte 8080 e 8443 sono già occupate, modificare la porta specificata a sinistra dei due punti nel parametro *-p*, che si riferisce all'host)
