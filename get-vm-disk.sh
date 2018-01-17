#!/bin/bash

vm_list=($(virsh list --all --name))

get_vm_diskpath()
{
	local vmname=$1
	local match=0
	if [[ $1 == all ]]; then
		for vm in ${vm_list[@]}
		do
			os_disks=$(virsh domblklist $vm | grep 'sda\|vda' | awk '{print $2}')
			attach_disks=$(virsh domblklist $vm | grep -v 'sda' | awk '{print $2}' | sed '/^\s*$/d' | tail -n +2)
			if [[ -z $attach_disks ]]; then
				attach_disks=null
			fi
			printf "%s\n%s\n\n%s\n%s\n\n%s\n%s\n\n" "=== VM name ===" $vm "== OS Disk ==" "$os_disks" "== Attach Disk ==" "$attach_disks"
		done
	else
		for vm in ${vm_list[@]}
		do
			if [[ $1 == $vm ]]; then
				local match=1
				break
			fi
		done
		if [[ $match == 0 ]]; then
			echo "Hostname not found, please check"
			exit 0
		fi
		os_disks=$(virsh domblklist $1 | grep 'sda\|vda' | awk '{print $2}')
		attach_disks=$(virsh domblklist $1 | grep -v 'sda' | awk '{print $2}' | sed '/^\s*$/d' | tail -n +2)
		if [[ -z $attach_disks ]]; then
			attach_disks=null
		fi
		printf "%s\n%s\n\n%s\n%s\n\n%s\n%s\n" "== VM name ==" $1 "== OS Disk ==" "$os_disks" "== Attach Disk ==" "$attach_disks"
	fi
}

if [[ !$# -eq 1 ]]; then
	echo "[ERROR] argument missing, use -h or --help to check argument"
	exit 0
else
	for opt in $@
	do
		case $opt in
			-h|--help) echo "Usage: ./$0 [all] or give [VM name]"; exit 0;;
		esac
	done
fi

get_vm_diskpath $1