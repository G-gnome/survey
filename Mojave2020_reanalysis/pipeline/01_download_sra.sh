#!/usr/bin/bash -l
#SBATCH -p short -c 48 --mem 64gb --out logs/01_download_sra.log

module load parallel-fastq-dump
module load workspace/scratch
CPU=2
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi

SRAFILE=lib/PRJNA544067.csv
FOLDER=input
mkdir -p $FOLDER

IFS=,
tail -n +2 $SRAFILE | while read SRA BIOSAMPLE DATE LOCATION GPS SOURCE_MATERIAL
do
  # unfortunately amptk wants uncompressed files... we can compress these back after or in use in qiime I believe
  if [ ! -s $FOLDER/${SRA}_R1.fastq ]; then
	time parallel-fastq-dump -T $SCRATCH -O $FOLDER --threads $CPU --split-files --sra-id $SRA
	mv $FOLDER/${SRA}_1.fastq $FOLDER/${SRA}_R1.fastq
	mv $FOLDER/${SRA}_2.fastq $FOLDER/${SRA}_R2.fastq
  fi
done
