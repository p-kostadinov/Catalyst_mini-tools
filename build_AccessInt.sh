#!/usr/bin/env bash
#1.0.0

space() {
    echo ""
}

smallPad() {
    echo "#################################"
}

padding() {
    space
    smallPad
    smallPad
    space
}

if [ -z "$1" ];then
    padding
    echo "Pass arguments 'file.csv' "
    space
    for i in {1..2}; do
        echo "interface,AccessVlan,voipVlan"
        echo "interface,AccessVlan,voipVlan"
    done
    space
    echo "Or pass following argument order for one Interface"
    space
    echo "interface AccessVlan voipVlan"
    padding
    exit 1
fi

fileArray[1]="interface"
fileArray[2]="vlan"
fileArray[3]="voip"


if [ ! -f "$1" ];then
    Counter="0"
    interface[0]=$1
    vlan[0]=$2
    voip[0]=$3
else
    for i in $(seq 1 ${#fileArray[@]} ); do
        awk -F',' -v var="$i" '{print $var}' "$1" > ./"${fileArray[$i]}".txt
        mapfile -t "${fileArray[$i]}" < ./"${fileArray[$i]}".txt
        rm -f ./"${fileArray[$i]}".txt
    done
    Counter=$(wc -l "$1"  | awk '{print $1}' )
    Counter=$((Counter - 1 ))
fi

InterfaceConf() {
    echo "interface ${interface[$i]}"
    echo "switchport mode access"
    echo "switchport access vlan ${vlan[$i]}"
    echo "switchport voice vlan ${voip[$i]}"
    echo "spanning-tree portfast"
    echo "spanning-tree bpduguard enable"
    echo "storm-control broadcast level 1.00"
    echo "ip dhcp snooping limit rate 30"
    echo "no snmp trap link-status"
    echo "no logging event link-status"
    echo "service-policy input L2-Access-Trust-In"
    echo "service-policy output L2-Access-Out"
    echo "no shutdown"
    space
    smallPad
    space
}

padding
for i in $(seq 0 "$Counter"); do
    InterfaceConf "$i"
done
padding

