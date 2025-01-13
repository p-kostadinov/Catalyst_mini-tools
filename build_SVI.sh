#!/usr/bin/env bash
#1.0.1

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
    echo "Pass arguments 'file.csv' then VPC member 1/2"
    space
    echo "vlan,name,0.0.0.,mask,netID,DHCP,DHCP_address1"
    echo "vlan,name,0.0.0.,mask,netID,noDHCP,DHCP_address2"
    for i in {1..3}; do
    echo "vlan,name,0.0.0.,mask,netID,DHCP"
    echo "vlan,name,0.0.0.,mask,netID,noDHCP"
    done
    space
    echo "Or pass following argument order for one SVI"
    space
    echo "vpcMember vlan name 0.0.0. mask netID DHCP"
    echo "vpcMember vlan name 0.0.0. mask netID noDHCP"
    padding
    exit 1
elif [ -z "$2" ];then
    echo "PROVIDE SVI MEMBER 1 OR 2"
    exit 1
fi

#####################################
#
#####################################

fileArray[1]="VLAN"
fileArray[2]="NetName"
fileArray[3]="Network"
fileArray[4]="NetworkMASK"
fileArray[5]="netID"
fileArray[6]="DHCP"
fileArray[7]="DHCPaddress"

if [ ! -f "$1" ];then
    SVICount="0"
    vpcMember=$1
    VLAN[0]=$2
    NetName[0]=$3
    Network[0]=$4
    NetworkMASK[0]=$5
    netID[0]=$6
    DHCP[0]=$7
else
    vpcMember=$2
    for i in $(seq 1 ${#fileArray[@]} ); do
        awk -F',' -v var="$i" '{print $var}' "$1" > ./"${fileArray[$i]}".txt
        mapfile -t "${fileArray[$i]}" < ./"${fileArray[$i]}".txt
        rm -f ./"${fileArray[$i]}".txt
    done
    SVICount=$(wc -l "$1"  | awk '{print $1}' )
    SVICount=$((SVICount - 1 ))
fi

#####################################
#SVI
#####################################

svi() {
    networkID=${netID[$1]}
    gw=$((networkID + 1))
    if [ "$vpcMember" =  1 ]; then
        host=$((networkID + 2))
        hsrpPriority="150"
    elif [ "$vpcMember" =  2 ]; then
        host=$((networkID + 3))
        hsrpPriority="100"
    fi
    gatewayIP=${Network[$1]}${gw}
    hostIP=${Network[$1]}${host}
    #
    echo "vlan ${VLAN[$1]}"
    echo "name ${NetName[$1]}"
    echo "interface vlan ${VLAN[$1]}"
    echo "description ${NetName[$1]}"
    echo "no shutdown"
    echo "no ip redirects"
    echo "ip address $hostIP/${NetworkMASK[$1]}"
    echo "no ipv6 redirects"
    echo "ip router eigrp 2755"
    echo "hsrp version 2"
    echo "hsrp ${VLAN[$1]}"
    echo "preempt delay minimum 2"
    echo "priority $hsrpPriority"
    echo "ip $gatewayIP"
    if [ "${DHCP[$1]}" = "DHCP" ]; then
        echo "ip dhcp relay address ${DHCPaddress[0]}"
        echo "ip dhcp relay address ${DHCPaddress[1]}"
    fi
    space
    smallPad
    space
}

padding
for i in $(seq 0 "$SVICount"); do
    svi "$i"
done
padding
