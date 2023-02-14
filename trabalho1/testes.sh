#!/bin/bash	

flagP=0;
flagC=0;
flagDados=0;
flagL=0;
byte=0;
TXTOT=(0 0 0 0 0 0 0 0 0 0);
RXTOT=(0 0 0 0 0 0 0 0 0 0);


flagSort=0;			# verificaçao
flagReverse=0;		# verificar default

sort="sort "
order=" -n "		# ordem por default


message(){

	echo "         
        ----------------------------------------------- OPÇÕES VÁLIDAS ------------------------------------------------        

        ./netifstat.sh <OPTION> : onde OPTION é número de segundos que serão usados para calcular as taxas de transferência

	Nota: O último argumento passado terá de ser o número de segundos obrigatoriamente!

	    Filtros de procura:
                -p <OPTION> : número de interfaces a visualizar (OPTION=number)
                -c <OPTION> : selecionar interfaces através de uma expressão regular (OPTION=REGEX EXPRESSION)
	
        Filtros de visualisação:
                -b    : todos os dados estarão em bytes
	            -k    : todos os dados estarão em kilobytes
                -m    : todos os dados estarão em megabytes 
        
        Ordenação das colunas:
                -v	    : reverse order
                -r	    : sorts on RX
                -t	    : sorts on TX
                -T	    : sorts on TRATE
                -R	    : sorts on RRATE

        Opção extra:
                -l      : loop onde a cada s segundos é imprimida nova informação

        "	             
}

while getopts ":c:bkmp:vtrTRl" options; do
	case "${options}" in

    c) #selecção dos interfaces a visualizar pode ser realizada através de uma expressão regular
		c="${OPTARG}"

		if [[ $flagC == 1 ]]; then
			echo "ERRO: -c <OPTION> só pode ser selecionado uma vez!"
			exit 1
		fi

		flagC=1;
	;;

    b) #mostrar os dados em bytes
		byte=1;
		if [[ $flagDados == 0 ]]; then
            flagDados=1;
        else
			echo "ERRO: Não se pode selecionar mais do que um tipo de visualisação!"
            message
			exit 1
		fi
	;;

    k) #mostrar os dados em kilobytes
		byte=1024;
		if [[ $flagDados == 0 ]]; then
            flagDados=1;
        else
			echo "ERRO: Não se pode selecionar mais do que um tipo de visualisação!"
            message
			exit 1
		fi

	;;

    m) #mostrar os dados em megabytes
		byte=1000000;
		if [[ $flagDados == 0 ]]; then
            flagDados=1;
        else
			echo "ERRO: Não se pode selecionar mais do que um tipo de visualisação!"
            message
			exit 1
		fi
	;;

	p) # número de interfaces a visualizar
		p="${OPTARG}"

		if [[ ! "${p}" =~ ^[0-9] ]]; then
			printf "\n	ERRO: Número de interfaces inválido!"
			message	
			exit 1
		fi

		if [[ $flagP == 1 ]]; then
			printf "\n	ERRO: -p <OPTION> só pode ser selecionado uma vez!"
			message
			exit 1
		fi

		flagP=1;
	;;

    v) #reverse

		if [[ $flagReverse == 0 ]]; then									
			flagReverse=1
		else
			printf "\n	ERRO: Só pode utilizar '-v' no máximo uma vez!"
			message
			exit 1
		fi	
	;;

    t)	# sort on TX

		if [[ $flagSort == 0 ]]; then
			flagSort=1;
			sort+="-k2";
			order="-r"
		else
			printf "\n	ERRO: Não se pode selecionar mais que 1 tipo de ordenação!"
			message
			exit 1
		fi
	;;

    r)	# sort on RX

		if [[ $flagSort == 0 ]]; then
			flagSort=1;
			sort+="-k3";
			order="-r"
		else
			printf "\n	ERRO: Não se pode selecionar mais que 1 tipo de ordenação!"
			message
			exit 1
		fi
	;;

    T)	# sort on TRATE

		if [[ $flagSort == 0 ]]; then
			flagSort=1;
			sort+="-k4";
			order="-r"
		else
			printf "\n	ERRO: Não se pode selecionar mais que 1 tipo de ordenação!"
			message
			exit 1
		fi
	;;

    R)	# sort on RRATE

		if [[ $flagSort == 0 ]]; then
			flagSort=1;
			sort+="-k5";
			order="-r"
		else
			printf "\n	ERRO: Não se pode selecionar mais que 1 tipo de ordenação!"
			message
			exit 1
		fi
	;;

    l) #loop

		if [[ $flagL == 0 ]]; then
            flagL=1;
		fi
	;;

    *) #opção inválida ou falta de argumento obrigatório
		printf "\n	ERRO: Por favor introduza uma expressão válida!"
		message
		exit 1
	;;

    esac
done
shift $((OPTIND-1))

#validações

if [[ $flagSort == 1 && $flagReverse == 0 ]]; then 
	order="-r "
fi

if [[ $flagP == 1 && $flagReverse == 1 ]]; then 
	order="-r"
fi

re='^[0-9]+([.][0-9]+)?$' 
if [[ ${@: -1} =~ $re ]]; then		# verificar se o último argumento é um número 
	segundos=${@: -1}
else
	printf "\n	ERRO: Por favor introduza uma expressão válida!"
	message
	exit 1
fi

if [[ ${#@} -gt 1 ]]; then		# verificar que o único argumento excluindo as opções é o $segundos
	printf "\n	ERRO: Por favor introduza uma expressão válida!"
	message
	exit 1
fi


get_dados(){

	rede=($(ifconfig | grep -w mtu | awk '{print $1}')) #linha com nome da rede
	dadosRX=($(ifconfig | grep -w "RX packets" | awk '{print $3}')) #guarda volor do bytes RX
	dadosTX=($(ifconfig | grep -w "TX packets" | awk '{print $3}'))  #guarda volor do bytes tx

		
	sleep $segundos
	i=0;
	
	#rede=$(ifconfig | grep -w mtu | awk '{print $1}') #linha com nome da rede
	dados2RX=($(ifconfig | grep -w "RX packets" | awk '{print $3}')) #guarda volor do bytes RX
	dados2TX=($(ifconfig | grep -w "TX packets" | awk '{print $3}'))  #guarda volor do bytes tx


	difTX=( )
	difRX=( )
	TRATE=( )
	RRATE=( )

	
   
	for (( k=0; k<${#rede[@]}; k++ )); #percorrE
    do 
		if [[ $flagDados == 1 ]]; then
			dadosTX[k]=$(echo "scale=4; ${dadosTX[k]}/$byte" | bc -l)  
			dadosRX[k]=$(echo "scale=4; ${dadosRX[k]}/$byte" | bc -l)
			dados2TX[k]=$(echo "scale=4; ${dados2TX[k]}/$byte" | bc -l)
			dados2RX[k]=$(echo "scale=4; ${dados2RX[k]}/$byte" | bc -l)
		fi

        difTX[k]=$(echo "scale=4; ${dados2TX[k]} - ${dadosTX[k]}" | bc -l)
		TRATE[k]=$(echo "scale=4; ${difTX[k]} / $segundos" | bc -l)

		difRX[k]=$(echo "scale=4; ${dados2RX[k]} - ${dadosRX[$k]}" | bc -l)
		RRATE[k]=$(echo "scale=4; ${difRX[k]}  / $segundos" | bc -l)
		i=$(($i+1))
	done

	if [[ $flagP == 1 ]]; then
		if [[  $i -lt $p ]]; then
			printf "\n	ERRO: Impossível mostrar %d processos com as opções selecionadas!" "$p"
			message; exit 1
		elif [[ $flagC == 1 ]]; then	# erro se houver mais processos pedidos em -p q retornados de -c
			if  [[ $cc -lt $p ]]; then 
				printf "\n	ERRO: Impossível mostrar %d processos com as opções selecionadas!" "$p"
			message; exit 1
			fi
		fi
	fi

	if [[ $flagL == 1 ]]; then
		printf "%10s %10s %10s %10s %10s %10s %10s \n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOT" "RXTOT"
		echo ""> dados.txt
		for ((k=0; k<${#rede[@]}; k++)); #percorrE
    	do 
			TXTOT[k]=$(echo "scale=4; ${TXTOT[k]} + ${difTX[k]}" | bc -l)
			RXTOT[k]=$(echo "scale=4; ${RXTOT[k]} + ${difRX[k]}" | bc -l)
			
        	printf "%10s %10s %10s %10s %10s %10s %10s \n" ${rede[$k]} ${difTX[$k]} ${difRX[$k]} ${TRATE[$k]} ${RRATE[$k]} ${TXTOT[$k]} ${RXTOT[$k]} >> dados.txt
		done
		if [[ $flagC == 1 && ! "${rede}" =~ ${c} ]]; then 		# verificar -c
			if [[ $flagP == 1 ]]; then 
				if [[ $flagSort == 1 && $flagReverse == 1 ]]; then
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} -n
				elif [[ $flagReverse == 1 ]]; then 
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} -r
				elif [[ $flagSort == 1 ]]; then
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} ${order}
				else
					cat dados.txt | grep -w $c | head -$((${p}+1))
				fi
			elif [[ $flagSort == 1 ]]; then
				if [[ $flagReverse == 1 ]]; then
					cat dados.txt | grep -w $c | ${sort} -n
				else
					cat dados.txt | grep -w $c | ${sort} ${order}
				fi
			elif [[ $flagReverse == 1 ]]; then
				cat dados.txt | grep -w $c | ${sort} -n
			else 
				cat dados.txt | grep -w $c	
			fi
		elif [[ $flagP == 1 ]]; then
			if [[ $flagSort == 1 && $flagReverse == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} -n
			elif [[ $flagReverse == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} -r
			elif [[ $flagSort == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} ${order}
			else
				cat dados.txt | head -$((${p}+1))
			fi
		elif [[ $flagSort == 1 ]]; then
			if [[ $flagReverse == 1 ]]; then
				cat dados.txt | ${sort} -n
			else 
				cat dados.txt | ${sort} -r
			fi  
		elif [[ $flagReverse == 1 ]]; then
			cat dados.txt | ${sort} -n 
		else
			cat dados.txt
		fi

		echo ""
	else
		printf "%10s %10s %10s %10s %10s \n" "NETIF" "TX" "RX" "TRATE" "RRATE"
		echo ""> dados.txt
		for ((k=0; k<${#rede[@]}; k++)); #percorrE
    	do 

        	printf "%10s %10s %10s %10s %10s \n" ${rede[$k]} ${difTX[$k]} ${difRX[$k]} ${TRATE[$k]} ${RRATE[$k]} >> dados.txt

		done
		if [[ $flagC == 1 && ! "${rede}" =~ ${c} ]]; then 		# verificar -c
			if [[ $flagP == 1 ]]; then 
				if [[ $flagSort == 1 && $flagReverse == 1 ]]; then
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} -n
				elif [[ $flagReverse == 1 ]]; then 
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} -r
				elif [[ $flagSort == 1 ]]; then
					cat dados.txt | grep -w $c | head -$((${p}+1)) | ${sort} ${order}
				else
					cat dados.txt | grep -w $c | head -$((${p}+1))
				fi
			elif [[ $flagSort == 1 ]]; then
				if [[ $flagReverse == 1 ]]; then
					cat dados.txt | grep -w $c | ${sort} -n
				else
					cat dados.txt | grep -w $c | ${sort} ${order}
				fi
			elif [[ $flagReverse == 1 ]]; then
				cat dados.txt | grep -w $c | ${sort} -n
			else 
				cat dados.txt | grep -w $c	
			fi
		elif [[ $flagP == 1 ]]; then
			if [[ $flagSort == 1 && $flagReverse == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} -n
			elif [[ $flagReverse == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} -r
			elif [[ $flagSort == 1 ]]; then
				cat dados.txt | head -$((${p}+1)) | ${sort} ${order}
			else
				cat dados.txt | head -$((${p}+1))
			fi
		elif [[ $flagSort == 1 ]]; then
			if [[ $flagReverse == 1 ]]; then
				cat dados.txt | ${sort} -n
			else 
				cat dados.txt | ${sort} ${order}
			fi  
		elif [[ $flagReverse == 1 ]]; then
			cat dados.txt | ${sort} -n
		else
			cat dados.txt
		fi


	fi
}


if [[ $flagL == 1 ]]; then
	while : ; do
    	get_dados
		
	done
else
	get_dados
fi