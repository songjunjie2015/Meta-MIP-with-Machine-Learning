#!/bin/bash

#Please enter the name and mass of An, reference IOD and CN, separated by ","(same below)
ab0=Np01,237.000,0.251,9.00

#Please enter the parameters R0, kappa between An and OW, and the number of Cell grid points (the square of the number of parameters to be optimized) 
ac0=1.75575,0.05,4

#Please enter the interval factors for the parameters R0 and kappa to be optimized, the reference column for Meta-MIP, and the scaling factor
ad0=0.02,0.08,7,1.10

#Please enter the initial error limits for IOD and CN and their relaxation multiples
ae0=0.01,0.03,1.1,1.2

#Please enter the number of parallel scripts and the number of parallel cores
af0=4,24

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
nam=${ab0%%,*};ab1=${ab0#*,};mmm=${ab1%%,*};ab2=${ab1#*,};pos=${ab2%%,*};cnn=${ab2#*,};tR0=${ac0%%,*};ac1=${ac0#*,}
tkp=${ac1%%,*};tgd=${ac1#*,};fR0=${ad0%%,*};ad1=${ad0#*,};fkp=${ad1%%,*};ad2=${ad1#*,};row=${ad2%%,*};flp=${ad2#*,}
lps=${ae0%%,*};ae1=${ae0#*,};lcn=${ae1%%,*};ae2=${ae1#*,};fps=${ae2%%,*};fcn=${ae2#*,};npl=${af0%%,*};nds=${af0#*,}
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
if [ -e ./An_$nam ]; then echo "An_$nam already exists"\!; else cp -r start An_$nam; cd An_$nam/start; chmod +x ./*
sed -i "s/name/$nam/g" ./run?.sh; sed -i "s/grid/$tgd/g" ./run?.sh; sed -i "s/mmmm/$mmm/g" ./start/OPC3_MF.itp
sed -i "s/gfR0/$fR0/g" ./run?.sh; sed -i "s/gfkp/$fkp/g" ./run?.sh; sed -i "s/POS1/$pos/g" ./run?.sh
sed -i "s/CNCN/$cnn/g" ./run?.sh; sed -i "s/sl_p/$lps/g" ./run?.sh; sed -i "s/sl_c/$lcn/g" ./run?.sh
sed -i "s/F_PS/$fps/g" ./run?.sh; sed -i "s/F_CN/$fcn/g" ./run?.sh; sed -i "s/F_LP/$flp/g" ./run?.sh
sed -i "s/ROWX/$row/g" ./run?.sh; sed -i "s/node/$nds/g" ./run?.sh; cd ../; chmod +x ./*
R01=$(echo $tR0 $fR0 | awk '{ printf "%.5f",$1*(1-$2/2) }'); R02=$(echo $tR0 $fR0 | awk '{ printf "%.5f",$1*(1+$2/2) }')
kp1=$(echo $tkp $fkp | awk '{ printf "%.5f",$1*(1-$2/2) }'); kp2=$(echo $tkp $fkp | awk '{ printf "%.5f",$1*(1+$2/2) }')
for sR0 in {$R01,$R02}
do
    for skp in {$kp1,$kp2}
    do
        echo $sR0 $skp >> ./input_$nam.dat
    done
done
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
sed -i "s/node/$nds/g" ./run_start?; sed -i "s/name/$nam/g" ./run_start?
for par in $( seq 2 $npl )
do
cp -r ./run_start0 ./run_start$par; sed -i "s/run0/run$par/g" ./run_start$par; sed -i "s/0000/$par/g" ./run_start$par
cp -r ./start/run0.sh ./start/run$par.sh; sed -i "s/node/4/g" ./start/run$par.sh; sed -i "s/Do0/Do$par/g" ./start/run$par.sh
done
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# sbatch run_start1
# sleep 15s
# sbatch run_start2
# sleep 15s
# sbatch run_start3
# sleep 15s
# sbatch run_start4
cp -r ../start.sh ./start.dat
fi
