#!/usr/bin/bash -l
#SBATCH -p short -c 8 --mem 24gb --out alltaxabuild.%A.log

module load iqtree
module load muscle
module load mafft
module load samtools
module load clipkit

mafft Mojave2020.alltaxa.fas > Mojave2020.alltaxa.fasaln
muscle -align Mojave2020.alltaxa.fas -output Mojave2020.alltaxa.muscle.fasaln
clipkit Mojave2020.alltaxa.fasaln
clipkit Mojave2020.alltaxa.muscle.fasaln
iqtree2 -nt AUTO -s Mojave2020.alltaxa.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP
iqtree2 -nt AUTO -s Mojave2020.alltaxa.muscle.fasaln.clipkit -alrt 1000 -bb 1000 -m MFP

