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
			destRootDir="/etc/security/freeipa-backups"
		fi

		if [ ! -d $destRootDir ] ; then
			mkdir -p $destRootDir
		fi

		mkdir -p $destRootDir/etc/sssd
		mkdir -p $destRootDir/etc/ipa
		mkdir -p $destRootDir/etc/openldap
		mkdir -p $destRootDir/etc/pki/nssdb
		mkdir -p $destRootDir/etc/sysconfig
		mkdir -p $destRootDir/etc/sysconfig/network
		mkdir -p $destRootDir/etc/ntp

		cp -f /etc/sssd/sssd.conf		$destRootDir/etc/sssd/sssd.conf
		cp -f /etc/sysconfig/ntpd       $destRootDir/etc/sysconfig/
		cp -f /etc/ntp/step-tickers     $destRootDir/etc/ntp/step-tickers
		cp -f /etc/krb5.conf            $destRootDir/etc/krb5.conf
		cp -f /etc/ipa/ca.crt           $destRootDir/etc/ipa/ca.crt
		cp -f /etc/ipa/default.conf     $destRootDir/etc/ipa/default.conf
		cp -f /etc/openldap/ldap.conf   $destRootDir/etc/openldap/ldap.conf
		cp -f /etc/pki/nssdb/*          $destRootDir/etc/pki/nssdb
		cp -f /etc/krb5.keytab          $destRootDir/etc/krb5.keytab

		cp -f /etc/hosts                $destRootDir/etc/hosts
		cp -f /etc/hostname             $destRootDir/etc/hostname
		cp -f /etc/hostname             $destRootDir/etc/hostname.ipa-client

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

			/bin/mv -f $sourceRootDir/sssd/sssd.conf 	/etc/sssd/sssd.conf
			/bin/mv -f $sourceRootDir/sysconfig/ntpd	/etc/sysconfig/
			/bin/mv -f $sourceRootDir/ntp/step-tickers	/etc/ntp/step-tickers
			/bin/mv -f $sourceRootDir/krb5.conf		/etc/krb5.conf
			/bin/mv -f $sourceRootDir/ipa/ca.crt 		/etc/ipa/ca.crt
			/bin/mv -f $sourceRootDir/ipa/default.conf 	/etc/ipa/default.conf
			/bin/mv -f $sourceRootDir/openldap/ldap.conf 	/etc/openldap/ldap.conf
			/bin/mv -f $sourceRootDir/pki/nssdb/* 		/etc/pki/nssdb
			/bin/mv -f $sourceRootDir/krb5.keytab 		/etc/krb5.keytab

			cat $sourceRootDir/hosts > /etc/hosts
			cat $sourceRootDir/hostname > /etc/hostname
			cat $sourceRootDir/hostname > /etc/hostname.ipa-client
			rm -f $sourceRootDir/hostname
			rm -f $sourceRootDir/hosts
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
			rm -rf $targetDir/etc
		fi
		
	;;
	
esac
