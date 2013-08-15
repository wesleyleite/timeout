#!/bin/bash

if [ $# -eq 0 ]
then
   echo "É necessário escolher um timer: rtt, srtt, svar, rto"
   echo -e "\t$0 <timer>"
elif [ $# -eq 1 ]
then
   case $1 in
      rtt)  cat full_data.txt | cut -d' ' -f2 ;;
      srtt) cat full_data.txt | cut -d' ' -f3 ;;
      svar) cat full_data.txt | cut -d' ' -f4 ;;
      rto)  cat full_data.txt | cut -d' ' -f5 ;;
      *) echo "As opções são: rtt, srtt, svar, rto"
   esac
else
   echo "Por enquanto, só é suportado a visualização de um timer por vez"
fi
