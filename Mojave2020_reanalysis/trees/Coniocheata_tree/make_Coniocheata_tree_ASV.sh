#!/usr/bin/bash -l
#SBATCH -p short -c 8 --mem 24gb --out Coniochaetabuild.%A.log

module load iqtree
module load muscle
module load mafft
module load samtools
module load clipkit
IN=../results/amptk/
TAX=Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt
DB=Mojave2020_KKelly202307.ASVs.otus.taxonomy.fa
samtools faidx $IN/$DB

for ASV in $(grep Coniochaeta $IN/Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt | cut -f1)
do
	sum=$(grep -P "^$ASV\t" $IN/Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt  | cut -f2-50 | perl -p -e '$sum = 0; for my $n ( split ) { $sum += $n }; $_ = "$sum\n"')
	samtools faidx $IN/$DB $ASV | perl -p -e "s/>(\S+)/>\$1.$sum/"
done >  Mojave2020.Coniochaeta.fas
cat ../lib/Coniochaeta_lib_update.fa >> Mojave2020.Coniochaeta.fas
mafft Mojave2020.Coniochaeta.fas > Mojave2020.Coniochaeta.fasaln
muscle -align Mojave2020.Coniochaeta.fas -output Mojave2020.Coniochaeta.muscle.fasaln
clipkit Mojave2020.Coniochaeta.fasaln
clipkit Mojave2020.Coniochaeta.muscle.fasaln
iqtree2 -nt AUTO -s Mojave2020.Coniochaeta.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
iqtree2 -nt AUTO -s Mojave2020.Coniochaeta.muscle.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP

