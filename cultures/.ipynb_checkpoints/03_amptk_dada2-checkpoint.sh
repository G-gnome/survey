#!/usr/bin/bash -l
#SBATCH -p batch -c 32 --mem 64gb -N 1 -n 1 --out logs/03_amptk_dada2.%A.log

CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

module load amptk
OUT=results/amptk
BASE=Mojave2020_KKelly202307

if [ ! -f $BASE.otu_table.taxonomy.txt ]; then
 amptk taxonomy -f $BASE.ASVs.fa -i $BASE.final.txt -d ITS
fi

if [ ! -f $BASE.taxonomy.fix.txt ]; then
perl rdp_taxonmy2mat.pl<$BASE.taxonomy.txt>$BASE.taxonomy.fix.txt
fi

popd
