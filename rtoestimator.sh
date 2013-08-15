#!/bin/bash

# Criar aquivos vazios, mktemp
> srtt.txt
> svar.txt
> rto.txt
# Fator de suavização
ALFA=0.125 # 1/8
BETA=0.25  # 1/4

# Gerar o RTT
#ping -c $1 uw.edu > ping.txt 2>> log.txt
#if [ $? -ne 0 ]
#then
#   date >> log.txt
#   exit 1
#fi
#cat ping.txt | fgrep time= | cut -d' ' -f8 | cut -d'=' -f2 > rtt.txt
cat ping.txt | grep -Ewo "time\=[0-9\.]*" | sed 's/time=//g' > rtt.txt

#RTT inicial
RTT0=$(head -1 rtt.txt)

# Gerar o SRTT
SRTT=$RTT0
echo $SRTT >> srtt.txt

tail -n +2 rtt.txt | while read RTT
do
   SRTT=$(echo "(1-$ALFA)*$SRTT + $ALFA*$RTT" | bc)
   echo $SRTT >> srtt.txt
done

# Juntar RTT e SRTT em rtt_srtt.txt
#otimizar, maneira alternativa de fazer a junção linha a linha
cat -n rtt.txt > rtt_numered.txt
cat -n srtt.txt > srtt_numered.txt
join -j 1 rtt_numered.txt srtt_numered.txt > rtt_srtt.txt
rm rtt_numered.txt srtt_numered.txt

# Gerar o SVAR
let SVAR=$RTT0/2
echo $SVAR >> svar.txt

tail -n +2 rtt_srtt.txt | while read RTT_SRTT
do
   #otmizar, remover |, e.g. cut -d' ' -f2 $RTT_SRTT
   RTT=$(echo $RTT_SRTT | cut -d' ' -f2)
   SRTT=$(echo $RTT_SRTT | cut -d' ' -f3)
   VAR=$(echo "$RTT-$SRTT" | bc)
   #otmizar, maneira mais inteligente de remover sinal
   VAR=$(echo $VAR | sed 's/^-//g')
   #otimizar, remover |, e.g. let SVAR=(1-$BETA)*$SVAR + $BETA*$VAR
   SVAR=$(echo "(1-$BETA)*$SVAR + $BETA*$VAR" | bc)
   echo $SVAR >> svar.txt
done

# Juntar RTT, SRTT e SVAR em rtt_srtt_svar.txt
cat -n svar.txt > svar_numered.txt
join -j 1 rtt_srtt.txt svar_numered.txt > rtt_srtt_svar.txt
rm svar_numered.txt rtt_srtt.txt

# Gerar o RTO
while read RTT_SRTT_SVAR
do
   SRTT=$(echo $RTT_SRTT_SVAR | cut -d' ' -f3)
   SVAR=$(echo $RTT_SRTT_SVAR | cut -d' ' -f4)
   RTO=$(echo "$SRTT+4*$SVAR" | bc)
   echo $RTO >> rto.txt
done < rtt_srtt_svar.txt

# Juntar RTT, SRTT, SVAR e RTO em full_data.txt
cat -n rto.txt > rto_numered.txt
join -j 1 rtt_srtt_svar.txt rto_numered.txt > full_data.txt
rm rto_numered.txt rtt_srtt_svar.txt
rm rtt.txt srtt.txt svar.txt rto.txt

echo "Concluído"

#criar arquivos temporários em outro diretório, e.g. /tmp
#verificar quantidade de parametros
#considerar perdas
#implementar pacotes udp, tcp e icmp
#verificar jitter
# See more at: http://www.devin.com.br/shell_script/#sthash.tCFaYGI7.dpuf
