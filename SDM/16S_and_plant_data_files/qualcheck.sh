#!/bin/bash

#Author: Ioannis Kampouris
#Purpose: Use fastqc and multiqc in the R Server (UBUNTU OS)
#Dependencies a path for fastqc and 

export PATH=$PATH:"/home/ioannis.kampouris/fastqc/FastQC" #Change accordingly to your path 
export PATH=$PATH:"/home/ioannis.kampouris/fastqc/MultiQC" #Change accordingly to your path 

cd result_X208SC24106916-Z01-F001/01.RawData
find -name  "*raw_1*"|sed 's/^..//'  > s_N_sample_list.txt #Change accordingly to your path 

mkdir QC

filename='s_N_sample_list.txt'
mkdir 
while read i;
   do 
   SAMPLE=$(echo ${i} | sed "s/.raw_1\.fastq\.gz//")
      echo "$SAMPLE"
  fastqc  ${SAMPLE}.raw_1.fastq.gz -o QC #You can remove the "RAW" if you want your files with NOVOGENE cleaning
   fastqc  ${SAMPLE}.raw_2.fastq.gz -o QC
     
done <"$filename"
 
 mkdir -p QC/FW
 mkdir -p  QC/RE

mv QC/*fastq* QC/FW
mv QC/*fastq* QC/RE

mv QC/*fastq*/QC/FW
mv QC/*fastq* QC/RE
cd QC/FW
python3 -m multiqc  .
cd ..
cd RE
python3 -m multiqc  .

