#!/usr/bin/bash -l
#SBATCH -p short -c 8 --mem 24gb --out mortbuild.%A.log

module load iqtree
module load muscle
module load mafft
module load samtools
module load clipkit
IN=../results/amptk.OTU/
TAX=Mojave2020.ASVs.otu_table.taxonomy.txt
DB=Mojave2020.ASVs.otus.taxonomy.fa
samtools faidx $IN/$DB

for ASV in $(grep Mort $IN/Mojave2020.ASVs.otu_table.taxonomy.txt | cut -f1)
do
	sum=$(grep -P "^$ASV\t" $IN/Mojave2020.ASVs.otu_table.taxonomy.txt  | cut -f2-50 | perl -p -e '$sum = 0; for my $n ( split ) { $sum += $n }; $_ = "$sum\n"')
	samtools faidx $IN/$DB $ASV | perl -p -e "s/>(\S+)/>\$1.$sum/"
done >  Mojave2020.Mort.fas
cat ../lib/Mort_ITS1.update.fa >> Mojave2020.Mort.fas
mafft Mojave2020.Mort.fas > Mojave2020.Mort.fasaln
muscle -align Mojave2020.Mort.fas -output Mojave2020.Mort.muscle.fasaln
clipkit Mojave2020.Mort.fasaln
clipkit Mojave2020.Mort.muscle.fasaln
iqtree2 -nt AUTO -s Mojave2020.Mort.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
iqtree2 -nt AUTO -s Mojave2020.Mort.muscle.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP

