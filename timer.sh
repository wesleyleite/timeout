#!/bin/bash

# exportando padrao numerico 
# Fator de suavização
export LC_NUMERIC="POSIX"

ALFA=0.125 # 1/8
BETA=0.25  # 1/4
MS=""
TPKTS=0
DHOST=""

CMD_PING=$(which ping)
[ -z "${CMD_PING}" ] && { 
    echo "O Comando ${CMD_PING} não foi encontrado" 
    exit
}

ajuda() {
    echo 
    echo "Desenvolvido por Rodrigo Martins"
    echo
    echo "$0 NUM HOST"
    echo "NUM   =   Total de pacotes que esperar retorno MIN=2"
    echo "HOST  =   Opcional mas pode ser informado um host para disparo"
    echo
    exit
}

disparar() {

    local pkts=$1
    local destino=$2
    echo
    [ -z "${destino}" ] && destino="uw.edu"
    echo ">> Disparando contra [ ${destino} ( ${pkts} ) ]"
    MS=$( ping -c ${pkts} ${destino} 2>> log.txt | 
        grep -Ewo 'time=([0-9]){1,}\ ms' | 
        sed -r 's/time=|ms//g' )
}

gerar() {
    
    local i=1
    local RTT
    local SRTT
    local VAR
    local SVAR
    local RTO
    local flag=0

    echo "     RTT                 SRTT                SVAR                RTO"
    for RTT in ${MS}
    do
        [ ${flag} -eq 1 ] && { 
            #otimizar, remover |, e.g. let SRTT=(1-$ALFA)*$SRTT + $ALFA*$RTT
            #SRTT=$(((1-ALFA)*SRTT+ALFA*RTT))
            SRTT=$(echo "(1-${ALFA})*$SRTT+${ALFA}*${RTT}" | bc)
            VAR=$(echo "${RTT} - ${SRTT}" | bc )
            #otmizar, maneira mais inteligente de remover sinal
            VAR=$(echo $VAR | sed 's/^-//')
            SVAR=$(echo "(1-${BETA})*${SVAR}+${BETA}*${VAR}" | bc )
            RTO=$(echo "${SRTT}+4*${SVAR}" | bc)
        } || {
            RTT0=$RTT
            SRTT=$RTT0
            let SVAR=$RTT0/2
            RTO=0
            flag=1
        }
        printf "%04d %07d %20f %20f %20f\n" $((i++)) ${RTT} ${SRTT} ${SVAR} ${RTO}
    done
}

# main


# validar se quantidade de pacotes enviadas é numerico
TPKTS=$1
TPKTS=$( echo ${TPKTS} | 
        grep -Ewo '^[0-9]+$' )

[ $# -le 0 ] || [ -z ${TPKTS} ] || [ ${TPKTS} -le 1 ] && ajuda 

DHOST=$2


disparar ${TPKTS} $2
gerar

 
#considerar perdas
#implementar pacotes udp, tcp e icmp
#verificar jitter
# See more at: http://www.devin.com.br/shell_script/#sthash.tCFaYGI7.dpuf


