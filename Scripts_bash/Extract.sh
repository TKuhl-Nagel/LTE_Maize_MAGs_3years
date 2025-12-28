#!/bin/bash

# Set input/output directories
bam_dir="/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/Output/fertig"
output_dir="/home/ubuntu/Desktop/space/MAGS_MS5/Backmapping_diff_genes/extract"
log_file="${output_dir}/processing_log.txt"

# Create output directory if missing
mkdir -p "$output_dir"

# Process each BAM file
for bam_file in "$bam_dir"/*.bam; do
    # Get base name without extension
    base_name=$(basename "$bam_file" .bam)
    
    # Index BAM file (if not already indexed)
    samtools index "$bam_file" 2>&1
    
    # Extract mapped reads to FASTA
    samtools fasta -F 4 "$bam_file" > "${output_dir}/${base_name}_mapped.fasta" 2>&1
    
    # Count mapped reads for logging
    mapped_count=$(samtools view -c -F 4 "$bam_file")
    
    # Log results
    echo "Processed: $base_name | Mapped reads: $mapped_count" >> "$log_file"
done

echo "Processing complete. Log saved to: $log_file"
