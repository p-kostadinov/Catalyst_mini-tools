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
        echo "interface,vlan,DESC"
        echo "interface,vlan,DESC"
    done
    space
    echo "Or pass following argument order for one Interface"
    space
    echo "interface vlan DESC"
    padding
    exit 1
fi

fileArray[1]="interface"
fileArray[2]="vlan"
fileArray[3]="DESC"

if [ ! -f "$1" ];then
    Counter="0"
    interface[0]=$1
    vlan[0]=$2
    DESC[0]=$3
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
    echo "description ${DESC[$i]}"
}

padding
for i in $(seq 0 "$Counter"); do
    InterfaceConf "$i"
done
padding

