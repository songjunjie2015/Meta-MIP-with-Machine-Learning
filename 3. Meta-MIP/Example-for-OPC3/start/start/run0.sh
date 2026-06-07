#!/bin/bash


for tt in $(seq 1 1 grid)
do
    R0=$(cat ../input_name.dat | awk NR==$tt'{ print $1 }')
    kp=$(cat ../input_name.dat | awk NR==$tt'{ print $2 }')
    Rmetal=$(awk -v r0="$R0" 'BEGIN {print 2 * r0 - 1.7815}')
    ep=$(echo "$Rmetal" | awk '{printf "%.5f", sqrt(0.16341 * (10^(-57.36*exp(-2.471*$1)))) }')
    if [ ! -e $tt-$R0-$kp ]; then touch Do0_$tt-$R0-$kp; cp -r start $tt-$R0-$kp; cd $tt-$R0-$kp
    chmod +x ./*; echo -e "$ep $R0 $kp 1.01 2" | ./table; cp -r ./table.xvg table_OW_MM.xvg
    gmx grompp -f em.mdp -c OPC3_MF.gro -n OPC3_MF.ndx -p OPC3_MF.top -o OPC3_MFem
    gmx mdrun -nt 1 -v -deffnm OPC3_MFem -table table.xvg
    gmx grompp -f OPC3_MF.mdp -c OPC3_MFem.gro -n OPC3_MF.ndx -p OPC3_MF.top -o OPC3_MFmd -maxwarn 1
    gmx mdrun -nt node -v -deffnm OPC3_MFmd -table table.xvg
    echo -e "0\n 2\n" | gmx rdf -f OPC3_MFmd.xtc -n OPC3_MF.ndx -o a1.xvg -cn a2.xvg -bin 0.0005 -b 2000
    cp -r a1.xvg a1.dat; cp -r a2.xvg a2.dat; sed -i '/@/d' a?.dat; sed -i '/nan/d' a?.dat; sed -i '/#/d' a?.dat
    echo -e "a1 a2\n" | ../R0CN > aa.dat; PS1=$(cat ./aa.dat | awk NR==3'{ print $1 }'); aaa=N
    PK1=$(cat ./aa.dat | awk NR==3'{ print $2 }');CNn=$(cat ./aa.dat | awk NR==3'{ print $6 }')
    if [ -s OPC3_MFmd.gro ]; then aaa=Y; echo "$R0 $kp $PS1 $CNn" >> ../LMIP_input.dat; fi
    PS2=$(cat ./aa.dat | awk NR==3'{ print $3 }'); PK2=$(cat ./aa.dat | awk NR==3'{ print $4 }')
    PS3=$(cat ./aa.dat | awk NR==3'{ print $5 }'); echo "$ep $R0 $kp $PS1 $PK1 $PS2 $PK2 $PS3 $CNn" >> ../ana_grids.dat
    ePS1=$(echo $PS1 | awk '{ printf "%.5f",($1-POS1)/POS1 }'); eCNn=$(echo $CNn | awk '{ printf "%.5f",($1-CNCN)/CNCN }')
    echo "NO.numb: $aaa $ep $R0 $kp $PS1 POS1 $ePS1 $CNn CNCN $eCNn" >> ../../ag_name.dat; rm -r *{#,mdout*,prev*,pdb,core*}
    rm -r ../Do0_$tt-$R0-$kp; cd ../; fi
done
