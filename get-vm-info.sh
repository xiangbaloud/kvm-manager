#/bin/bash

check_host_alive() {
	if ping -c1 -w1 $1 > /dev/null 2>&1
	then
		:
	else
		echo "[ERROR] Host did not respond, please check"
		exit 0
	fi	
}

if [[ ! -f /usr/bin/virsh ]]; then
	read -p "input the vm host IP address: " vm_host

	if [[ -z $vm_host ]]; then
		echo "[ERROR] host ip empty"
		exit 0
	else
		vm_host_cmd="ssh $vm_host"
	fi
	check_host_alive $vm_host
fi

get_vm_list=($($vm_host_cmd virsh list --all --name))

i=0
for vm in ${get_vm_list[@]}
do
	if [[ $i == 0 ]]; then
		printf "\n-------------------------------------------------------------------\n"
		printf "%-17s %s %-17s %s %-12s %s %-10s %s\n-------------------------------------------------------------------\n" NAME "|" MAC "|" IP "|" OWNER "|"
	fi

	vm_interface_mac=$($vm_host_cmd virsh domiflist $vm | grep ':' | awk '{print $5}')
	[[ -z $vm_interface_mac ]] && vm_interface_mac="null"
	vm_ip=$($vm_host_cmd arp | grep $vm_interface_mac | awk '{print $1}')
	[[ -z $vm_ip ]] && vm_ip="null"
	[[ -z $vm_owner ]] && vm_owner="null"
	printf "%-17s %s %-17s %s %-12s %s %-10s %s" $vm "|" $vm_interface_mac "|" $vm_ip "|" $vm_owner "|"
	printf "\n-------------------------------------------------------------------\n"

	((i++))
done