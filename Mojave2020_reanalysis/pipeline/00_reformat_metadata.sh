#!/usr/bin/bash -l
#SBATCH -p short --out logs/00_reformat_metdata.log

module load csvkit
IN=lib/PRJNA544067_metadata_sra.csv
OUT=lib/PRJNA544067.csv
if [ ! -f lib/Mojave_mappingfile_8-Aug-2018.txt ]; then
	curl -o lib/Mojave_mappingfile_8-Aug-2018.txt https://raw.githubusercontent.com/stajichlab/MojaveCrusts_2019analysis/master/BiocrustDiv/Fungi/Mojave_mappingfile_8-Aug-2018.txt
fi
if [ ! -s $OUT ]; then
	csvcut -d, -c 1,6,10,15,23,25,37 $IN > $OUT
fi
