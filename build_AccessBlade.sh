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
    space
    echo "Argument order:"
    space
    echo "interfaceName PortQty AccessVlan VoipVlan BladeCount"
    space
    smallPad
    space
    echo "3rd argument can be file.csv formatted as:"
    echo "(4th argument will be BladeCount)"
    space
    for i in {1..4}; do
        echo "switchName,accessVlan,voipVlan"
    done
    space
    padding
    exit 1
fi

endPort="$2"

intConfig() {
    echo "interface range $1$i/0/1 - $endPort"
    echo "switchport mode access"
    echo "switchport access vlan $2"
    echo "switchport voice vlan $3"
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
if [ -f "$3" ]; then
    bladeCount="$4"
    fileArray[1]="switch"
    fileArray[2]="vlan"
    fileArray[3]="voip"
    intConfigPass() {
        for i in $(seq 1 "$bladeCount"); do
            intConfig "$1" "${vlan[$2]}" "${voip[$2]}"
        done
    }
    for i in {1..3}; do
        awk -F',' -v var="$i" '{print $var}' "$3" > ./"${fileArray[$i]}".txt
        mapfile -t "${fileArray[$i]}" < ./"${fileArray[$i]}".txt
        rm -f ./"${fileArray[$i]}".txt
    done
    Counter=$(wc -l "$3"  | awk '{print $1}' )
    Counter=$((Counter - 1 ))
    mkdir ./AccessInt
    for i in $(seq 0 "$Counter"); do
        echo "config built: ${switch[$i]}"
        intConfigPass "$1" "$i" > ./AccessInt/IDF_${switch[$i]}.txt
    done    
else
    bladeCount="$5"
    for i in $(seq 1 "$bladeCount"); do
        intConfig "$1" "$3" "$4"
    done
fi
padding

