#!/bin/bash

# Define error log file
ERROR_LOG="/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/error.log"

# Function to log errors with timestamp
log_error() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[${timestamp}] ERROR: ${message}" >> "$ERROR_LOG"
}

# Create an output directory for BAM files
mkdir -p /home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output

# Loop through contigs and reads
for genome in /home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/contigs/*.fasta; do
    # Index the genome if not already indexed
    if ! bwa index "$genome" 2>> "$ERROR_LOG"; then
        log_error "Failed to index genome: $genome"
        continue
    fi
    
    # Extract genome name (without path and extension)
    genome_name=$(basename "$genome" .fasta)
    
    # Find all forward reads in the folder
    for forward_reads in /home/ubuntu/Desktop/space/Data_MS5/Illumina_CT202122_all/All/*_forward.fastqsanger.gz; do
        # Extract sample name (without path and "_forward.fastqsanger.gz")
        sample_name=$(basename "$forward_reads" _forward.fastqsanger.gz)
        
        # Construct the path to the corresponding reverse reads
        reverse_reads="${forward_reads/_forward/_reverse}"
        
        # Check if the reverse reads file exists
        if [[ ! -f "$reverse_reads" ]]; then
            log_error "Reverse reads file for $forward_reads not found."
            continue
        fi
        
        # Perform alignment and convert to sorted BAM in one step
        if ! bwa mem -t 8 "$genome" "$forward_reads" "$reverse_reads" 2>> "$ERROR_LOG" | \
           samtools view -b 2>> "$ERROR_LOG" | \
           samtools sort -o "/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/${sample_name}_vs_${genome_name}.bam" 2>> "$ERROR_LOG"; then
            log_error "Alignment failed for sample $sample_name against genome $genome_name."
            continue
        fi
        
        # Index the BAM file for downstream analysis
        if ! samtools index "/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/${sample_name}_vs_${genome_name}.bam" 2>> "$ERROR_LOG"; then
            log_error "Failed to index BAM file for sample $sample_name against genome $genome_name."
        fi
    done
done
