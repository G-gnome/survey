#!/usr/bin/bash -l
#SBATCH -p short -c 8 --mem 24gb --out Exophialabuild.%A.log

module load iqtree
module load muscle
module load mafft
module load samtools
module load clipkit
IN=../results/amptk/
TAX=Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt
DB=Mojave2020_KKelly202307.ASVs.otus.taxonomy.fa
samtools faidx $IN/$DB

for ASV in $(grep Exophiala $IN/Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt | cut -f1)
do
	sum=$(grep -P "^$ASV\t" $IN/Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt  | cut -f2-50 | perl -p -e '$sum = 0; for my $n ( split ) { $sum += $n }; $_ = "$sum\n"')
	samtools faidx $IN/$DB $ASV | perl -p -e "s/>(\S+)/>\$1.$sum/"
done >  Mojave2020.Exophiala.fas
cat ../lib/Exophiala_lib.fa >> Mojave2020.Exophiala.fas
mafft Mojave2020.Exophiala.fas > Mojave2020.Exophiala.fasaln
muscle -align Mojave2020.Exophiala.fas -output Mojave2020.Exophiala.muscle.fasaln
clipkit Mojave2020.Exophiala.fasaln
clipkit Mojave2020.Exophiala.muscle.fasaln
iqtree2 -nt AUTO -s Mojave2020.Exophiala.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
iqtree2 -nt AUTO -s Mojave2020.Exophiala.muscle.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP

