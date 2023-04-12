# SearchTandem
SearchTandem is a pipeline for processing paired-end FASTQ sequencing files to detect tandem repeats at the C9ORF72 locus, developed for CHU de Nîmes. Please note that this script is designed for the specific use of the Laboratoire de Biochimie et de Biologie Moléculaire at CHU de Nîmes. It is possible that adaptations (such as file paths) may need to be made for the program to work in another work environment.

## **Introduction**

This repository contains scripts for the detection of tandem repeats in FASTQ files of paired-end sequencing data, and the subsequent analysis of these repeats. This pipeline was designed for the detection of C9ORF72 tandem repeat expansions, which are associated with amyotrophic lateral sclerosis (ALS) and frontotemporal dementia (FTD).

The main script performs the following tasks:

    Parses input options to receive paired-end fastq files.
    Runs FastQC for quality control of raw data (optional).
    Filters reads containing pure GGGGCC sequences or at least three tandem repeats of GGGGCC using the secondary script filter_reads.sh.
    Builds a HISAT2 index from a reference genome.
    Aligns filtered reads to the reference genome using HISAT2.
    Converts the SAM output to a sorted and indexed BAM file using Samtools.
    Marks duplicates and calculates genome coverage using Samtools.
    Analyzes variants with ExpansionHunter.
    Indexes the output BAM file.
    Displays graphical representations of tandem expansions using REViewer.

The filter_reads.sh script, which is called within the main script, performs the following tasks:

    Extracts pure GGGGCC reads from input files R1 and R2.
    Extracts reads with at least three tandem repeats of GGGGCC from input files R1 and R2.
    Concatenates the extracted reads from each input file and compresses them into new output files.

## **Prerequisites**

The scripts have the following dependencies:

    HISAT2 v2.1.0
    Samtools v1.10
    FastQC v0.11.9
    ExpansionHunter v5.0.0
    REViewer v0.2.7
    
## **Input**

The script requires the following files in the same directory:

    Two FASTQ files R1 and R2 for each sample and compressed by using gzip.
    
    -i: Provide the input paired-end fastq files separated by a comma (required).
    -q: Run FastQC for quality control (optional).

Make sure the reference genome (in FASTA format) is present in the same directory as the main script. Both the main script and the filter_reads.sh script should be executable (chmod +x script_name.sh).

## **Usage**

Make sure that the FASTQ R1 and R2 files are in gzip format and in the same directory as the scripts, avoid using shortcuts.

Run the script in a terminal by navigating to the directory containing the script by the following command :

    ./ main_pipeline_tandem.sh -i input_file_R1.fastq.gz,input_file_R2.fastq.gz [-q]

The output of the script will be saved in a CSV file with the format cnv_listing_yyyy-mm-dd_HH-MM-SS.csv where yyyy-mm-dd_HH-MM-SS is the current date and time. If the output file already exists, you will be prompted to overwrite it or choose a different name.
    
## **Output**

The graphical visualisation of repetitions is possible with the output SVG file from REViewer; here is an example of visualisation :
![1603181267_reviewer C9ORF72](https://user-images.githubusercontent.com/130393309/231401429-7f977680-2674-44c9-8339-24f186fdcdc9.svg)


