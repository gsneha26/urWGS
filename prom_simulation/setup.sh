mv */fast5/* .
for i in `seq 1 48`; do mkdir $i; done
for i in *.fast5; do rand=$(((($RANDOM%48))+1)); mv $i $rand/; done
lin=0 && for i in {A..H}; do for j in `seq 1 6`; do fc=$(($j+$lin)); rand=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1); mv $fc ${rand}_${j}${i}; done; lin=$(($lin+6)); done
