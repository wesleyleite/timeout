#!/bin/bash

# Criar arquivos vazios
> full_data.txt
# Fator de suavização
ALFA=0.125 # 1/8
BETA=0.25  # 1/4
flag=0

[ $# -ne 1 ] && {
   echo "$0 NUM"
} || {
   for RTT in $( ping -c $1 uw.edu 2>> log.txt | grep -Ewo 'time\=[0-9\.]*' | sed 's/time\=//g' )
   #for RTT in $( cat ping.txt | grep -Ewo 'time\=[0-9\.]*' | sed 's/time\=//g' )
   do
      if [ $flag -eq 1 ]
      then
         #otimizar, remover |, e.g. let SRTT=(1-$ALFA)*$SRTT + $ALFA*$RTT
         SRTT=$(echo "(1-$ALFA)*$SRTT + $ALFA*$RTT" | bc)
         VAR=$(echo "$RTT-$SRTT" | bc)
         #otmizar, maneira mais inteligente de remover sinal
         VAR=$(echo $VAR | sed 's/^-//g')
         SVAR=$(echo "(1-$BETA)*$SVAR + $BETA*$VAR" | bc)
         RTO=$(echo "$SRTT+4*$SVAR" | bc)
      else
         RTT0=$RTT
         SRTT=$RTT0
         let SVAR=$RTT0/2
         RTO=0
         flag=1
      fi
      echo $((i++)) $RTT $SRTT $SVAR $RTO >> full_data.txt
   done
}

#verificar quantidade de parametros
#considerar perdas
#permitir a passagem do host de forma opcional
#implementar pacotes udp, tcp e icmp
#verificar jitter
# See more at: http://www.devin.com.br/shell_script/#sthash.tCFaYGI7.dpuf
