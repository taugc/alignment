#!/bin/bash

## INPUT PAR ############################
#nome do PROJECT
PROJECT=$1

samples=$PROJECT'_sample.txt'

THREADS=$2

REFERENCE='/home/user/fastq/mapped/assembly'

#########################################
echo 'BWA mapping...'
## BWA mapping ##
## run bwa
while IFS= read -r line
do
	bwa index -a bwtsw ${PROJECT}'/fastq/mapped/assembly/'${line}'/contigs.fasta'
	samtools faidx ${PROJECT}'/fastq/mapped/assembly/'${line}'/contigs.fasta'
	java -jar ~/tools/picard.jar CreateSequenceDictionary REFERENCE=${PROJECT}'/fastq/mapped/assembly/'${line}'/contigs.fasta' OUTPUT=${PROJECT}'/fastq/mapped/assembly/'${line}'/contigs.dict' 
	mkdir ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa'
	bwa mem -t ${THREADS} -M ${PROJECT}'/fastq/mapped/assembly/'${line}'/contigs.fasta' ${PROJECT}'/fastq/mapped/'${line}'.aligned.unmapped_R1.fq' ${PROJECT}'/fastq/mapped/'${line}'.aligned.unmapped_R2.fq' >${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.sam'
done <"$samples"

echo 'samtools processing...'

# samtools sam to bam to fq

while IFS= read -r line
do
	samtools view -Sb ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.sam' >$PROJECT'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.bam'
	samtools flagstat ${PROJECT}'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.bam' >$PROJECT'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.bam.stats'
	samtools sort $PROJECT'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.bam' >$PROJECT'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.sorted.bam'
	samtools index $PROJECT'/fastq/mapped/assembly/'${line}'/bwa/'${line}'.sorted.bam'
done <"$samples"

echo 'DONE '${PROJECT}