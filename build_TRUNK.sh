#!/usr/bin/env bash
#1.0.1

space() {
	echo ""
}

padding() {
	space
	echo "#################################"
	echo "#################################"
	space
}

switchportConfig() {
    echo "switchport"
    echo "switchport mode trunk"
    echo "channel-group $1 mode active"
    echo "no shutdown"
}

STPtypeNormal() {
    echo "spanning-tree port type normal"
    echo "spanning-tree bpduguard disable"
}

STPtypeNetwork() {
    echo "spanning-tree port type network"
}

switchportTrunk() {
    echo "switchport"
    echo "switchport mode trunk"
    echo "no shutdown"
}

if [ -z "$1" ]; then
    padding
    echo "Pass file.csv formatted in the following order"
    space
    for i in {1..3}; do
        echo "Uplnk1local,Uplnk1,Uplnk2local,Uplnk2,switchName,switchIP,switchPoCH"
    done
    space
    echo "Or pass following argument order for one trunk:"
    space
    echo "Uplnk1local Uplnk1 Uplnk2local Uplnk2 switchName switchIP switchPoCH"
    padding
    exit 1
fi

if [ -f "$1" ]; then
    csvFile=${1}
fi

#####################################
#Source
#####################################

readCSV() {
    fileArray[1]="switchUPLNK1local"
    fileArray[2]="switchUPLNK1"
    fileArray[3]="switchUPLNK2local"
    fileArray[4]="switchUPLNK2"
    fileArray[5]="switch"
    fileArray[6]="switchIP"
    fileArray[7]="switchPoCH"
    for i in $(seq 1 ${#fileArray[@]} ); do
        awk -F',' -v var="$i" '{print $var}' "$csvFile" > ./"${fileArray[$i]}".txt
        mapfile -t "${fileArray[$i]}" < ./"${fileArray[$i]}".txt
        rm -f ./"${fileArray[$i]}".txt
    done
    Count=$(wc -l "$csvFile"  | awk '{print $1}' )
    Count=$((Count - 1 ))
}

if [ ! -f "$1" ]; then
    SVICount="0"
    switchUPLNK1local[0]="$2"
    switchUPLNK1[0]="$3"
    switchUPLNK2local[0]="$4"
    switchUPLNK2[0]="$5"
    switch[0]="$6"
    switchIP[0]="$7"
    switchPoCH[0]="$8"
else
    readCSV
fi

#####################################
#Trunk
#####################################

trunk() {
        space
        echo "interface ${switchUPLNK1local[$2]}"
        echo "description TYPE=vPC SW=${switch[$2]} IP=${switchIP[$2]} IF=Eth${switchUPLNK1[$2]}"
        switchportConfig "${switchPoCH[$2]}"
        STPtypeNormal
        space
        echo "interface ${switchUPLNK2local[$2]}"
        echo "description TYPE=vPC SW=${switch[$2]} IP=${switchIP[$2]} IF=Eth${switchUPLNK2[$2]}"
        switchportConfig "${switchPoCH[$2]}"
        STPtypeNormal
        space
        echo "interface port-channel${switchPoCH[$2]}"
        echo "description TYPE=local SW=${switch[$2]} IP=${switchIP[$2]} IF=Po${switchPoCH[$2]}"
        switchportTrunk
        STPtypeNormal
        echo "vpc ${switchPoCH[$2]}"
        space
        echo "#################################"
}

padding
for i in $(seq 0 "$Count"); do
    trunk  "$i"
done
padding

