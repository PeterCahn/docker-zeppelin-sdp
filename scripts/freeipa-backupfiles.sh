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

		mkdir -p $destRootDir/sssd
		mkdir -p $destRootDir/ipa
		mkdir -p $destRootDir/openldap
		mkdir -p $destRootDir/pki/nssdb
		mkdir -p $destRootDir/sysconfig
		mkdir -p $destRootDir/sysconfig/network
		mkdir -p $destRootDir/ntp

		cp -vf /etc/sssd/sssd.conf		 $destRootDir/sssd/sssd.conf
		cp -vf /etc/sysconfig/ntpd       $destRootDir/sysconfig/
		cp -vf /etc/ntp/step-tickers     $destRootDir/ntp/step-tickers
		cp -vf /etc/krb5.conf            $destRootDir/krb5.conf
		cp -vf /etc/ipa/ca.crt           $destRootDir/ipa/ca.crt
		cp -vf /etc/ipa/default.conf     $destRootDir/ipa/default.conf
		cp -vf /etc/openldap/ldap.conf   $destRootDir/openldap/ldap.conf
		cp -vf /etc/pki/nssdb/*          $destRootDir/pki/nssdb
		cp -vf /etc/krb5.keytab          $destRootDir/krb5.keytab

		cp -vf /etc/hosts                $destRootDir/hosts
		cp -vf /etc/hostname             $destRootDir/hostname
		cp -vf /etc/hostname             $destRootDir/hostname.ipa-client

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

		if [ -d "$sourceRootDir/" -a -d "$sourceRootDir/etc/sssd" -a -d "$sourceRootDir/etc/sysconfig" -a -d "$sourceRootDir/etc/ntp" -a -d "$sourceRootDir/etc/ipa" -a -d "$sourceRootDir/etc/openldap" -a -d "$sourceRootDir/etc/pki" ]; then

			/bin/mv -vf $sourceRootDir/sssd/sssd.conf 		/etc/sssd/sssd.conf
			/bin/mv -vf $sourceRootDir/sysconfig/ntpd		/etc/sysconfig/
			/bin/mv -vf $sourceRootDir/ntp/step-tickers		/etc/ntp/step-tickers
			/bin/mv -vf $sourceRootDir/krb5.conf			/etc/krb5.conf
			/bin/mv -vf $sourceRootDir/ipa/ca.crt 			/etc/ipa/ca.crt
			/bin/mv -vf $sourceRootDir/ipa/default.conf 	/etc/ipa/default.conf
			/bin/mv -vf $sourceRootDir/openldap/ldap.conf 	/etc/openldap/ldap.conf
			/bin/mv -vf $sourceRootDir/pki/nssdb/* 			/etc/pki/nssdb
			/bin/mv -vf $sourceRootDir/krb5.keytab 			/etc/krb5.keytab

			cat $sourceRootDir/hosts > /etc/hosts
			cat $sourceRootDir/hostname > /etc/hostname
			cat $sourceRootDir/hostname > /etc/hostname.ipa-client
			#rm -vf $sourceRootDir/hostname
			#rm -vf $sourceRootDir/hosts
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
