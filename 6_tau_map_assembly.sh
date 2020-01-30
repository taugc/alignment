#!/bin/bash

## INPUT PAR ############################
#nome do PROJECT
PROJECT=$1

samples=$PROJECT'_sample.txt'

THREADS=$2

REFERENCE='/home/user/references/genomes.fasta'

GENOME='genome_name'


#########################################
echo 'BWA mapping...'
## BWA mapping ##
## run bwa
while IFS= read -r line
do
	bwa mem -t ${THREADS} -M ${REFERENCE} ${PROJECT}'/fastq/'${line}'_L001_R1_001.fastq.gz' ${PROJECT}'/fastq/'${line}'_L001_R2_001.fastq.gz' >${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.sam'
done <"$samples"

echo 'samtools processing...'

# samtools sam to bam to fq

while IFS= read -r line
do
	samtools view -Sb ${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.sam' >${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.bam'
	samtools flagstat ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${VIRUS}'.bam' >${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.bam.stats'
	samtools sort ${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.bam' >${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.sorted.bam'
	samtools index ${PROJECT}'/fastq/bwa/'${line}'/'${line}'.'${GENOME}'.sorted.bam'
done <"$samples"

echo 'DONE '${PROJECT}
