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
for genome in /home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Selected_MAGS/*.fasta; do
    # Index the genome if not already indexed
    if ! bwa index "$genome" 2>> "$ERROR_LOG"; then
        log_error "Failed to index genome: $genome"
        continue
    fi
    
    # Extract genome name (without path and extension)
    genome_name=$(basename "$genome" .fasta)
    
    # Find all read files in the folder
    for reads in /home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/extract/*.fasta; do
        # Extract sample name (without path and extension)
        sample_name=$(basename "$reads" .fasta)
        
        # Perform alignment with unique read filtering
        if ! bwa mem -t 8 "$genome" "$reads" 2>> "$ERROR_LOG" | \
           samtools view -h -q 1 -F 4 -F 256 2>> "$ERROR_LOG" | \
           grep -v -E -e '\bXA:Z:' -e '\bSA:Z:' 2>> "$ERROR_LOG" | \
           samtools view -b 2>> "$ERROR_LOG" | \
           samtools sort -o "/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/${sample_name}_vs_${genome_name}.bam" 2>> "$ERROR_LOG"; then
            log_error "Alignment failed for sample $sample_name against genome $genome_name."
            continue
        fi
        
        # Index the filtered BAM file
        if ! samtools index "/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/${sample_name}_vs_${genome_name}.bam" 2>> "$ERROR_LOG"; then
            log_error "Failed to index BAM file for sample $sample_name against genome $genome_name."
        fi
    done
done

