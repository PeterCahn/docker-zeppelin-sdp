#!/bin/bash

if [ -z "$1" ] ; then
	echo "Usage: manage-freeipa-backupfiles.sh [ backup [dest-dir] | restore [source-dir] | delete [dir] ]"
	exit 1
fi

case "$1" in

	"backup" )
	
		echo "Backup current FreeIPA client config"
		
		if [ -n "$2" ] ; then
			destRootDir="$2"
		else
			destRootDir="/etc/security/freeipa-backups/etc"
		fi

		if [ ! -d $destRootDir ] ; then
			mkdir -p $destRootDir
		fi

#		cp -vf /etc/ipa/ca.crt           $destRootDir/ca.crt
		cp -vf /etc/krb5.conf          $destRootDir/krb5.conf

		cp -vf /etc/hosts                $destRootDir/hosts
		cp -vf /etc/hostname             $destRootDir/hostname
		cp -vf /etc/hostname             $destRootDir/hostname.ipa-client
		
		cp -vf $ZEPPELIN_HOME/conf/interpreter.json $ZEPPELIN_HOME/interpreters/interpreter.json.bckp
		
	;;
	
	"restore" )
	
		echo "Restoring previous FreeIPA client config"

		if [ -n "$2" ] ; then
			if [ -d "$2" ] ; then
				sourceRootDir="$1"
			else
				echo "Directory $1 does not exists"
				exit 1
			fi
		else
			sourceRootDir="/etc/security/freeipa-backups/etc"
		fi


#		/bin/cp -vf $sourceRootDir/ca.crt 			/etc/ipa/ca.crt
		/bin/cp -vf $sourceRootDir/krb5.conf			/etc/krb5.conf

                if [ -f $sourceRootDir/hosts -a -f sourceRootDir/hostname -a sourceRootDir/hostname ] ; then
			cat $sourceRootDir/hosts > /etc/hosts
			cat $sourceRootDir/hostname > /etc/hostname
			cat $sourceRootDir/hostname > /etc/hostname.ipa-client
		fi
	
		
		if [ -f $ZEPPELIN_HOME/interpreters/interpreter.json ] ; then
		    /bin/cp -vf $ZEPPELIN_HOME/interpreters/interpreter.json /opt/zeppelin/conf/interpreter.json
		elif [ -f $ZEPPELIN_HOME/interpreters/interpreter.json.bckp ] ; then
                    /bin/cp -vf $ZEPPELIN_HOME/interpreters/interpreter.json.bckp /opt/zeppelin/conf/interpreter.json
                fi
		

		
	;;
	
	"delete" )
		echo "Deleting previous FreeIPA client config: related host does not exist anymore on current ipaserver"
		
		if [ -n "$2" ] ; then
			targetDir="$2"
		else
			targetDir="/etc/security/freeipa-backups"
		fi

		if [ -d $targetDir/etc ] ; then
			rm -rvf $targetDir/etc
		fi
		
	;;
	
esac
