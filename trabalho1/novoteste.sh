#!/bin/bash	

rede=($(ifconfig | grep -w mtu | awk '{print $1}')) #linha com nome da rede
dadosRX=($(ifconfig | grep -w "RX packets" | awk '{print $3}')) #guarda volor do bytes RX
dadosTX=($(ifconfig | grep -w "TX packets" | awk '{print $3}'))  #guarda volor do bytes tx
	

for ((i=0; i< ${#rede[@]}; i++));
do
    echo $i
    echo ${rede[$i]}
    echo ${dadosRX[$i]}
    echo ${dadosTX[$i]}
done

