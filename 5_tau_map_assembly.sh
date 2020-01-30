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
	bwa mem -t ${THREADS} -M ${REFERENCE} ${PROJECT}'/fastq/mapped/'${line}'.aligned.unmapped_R1.fq' ${PROJECT}'/fastq/mapped/'${line}'.aligned.unmapped_R2.fq' >${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.sam'
done <"$samples"

echo 'samtools processing...'

# samtools sam to bam to fq

while IFS= read -r line
do
	samtools view -Sb ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.sam' >${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.bam'
	samtools flagstat ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.bam' >${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.bam.stats'
	samtools sort ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.bam' >${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.sorted.bam'
	samtools index ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.'${GENOME}'.sorted.bam'
done <"$samples"

echo 'DONE '${PROJECT}
