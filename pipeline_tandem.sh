#!/bin/bash

# Variables
reference=$(ls *.fa)
index_prefix=$(echo "$reference" | sed 's/.fasta//g')

# Gestion des options
while getopts ":qi:" opt; do
  case $opt in
    q)
      # Utilisation de FastQC pour le contrôle qualité des données brutes
      fastqc -o ./fastqc_output "$fastq1" "$fastq2"
      ;;
    i)
      # Récupération des fichiers R1 et R2 en utilisant l'option -i
      input_files=(${OPTARG//,/ })
      fastq1="${input_files[0]}"
      fastq2="${input_files[1]}"
      ;;
    \?)
      echo "Option invalide: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Mise à jour des variables dérivées
sam=$(echo "$fastq1" | sed 's/_R1.fastq.gz/.sam/g')
sorted_bam=$(echo "$fastq1" | sed 's/_R1.fastq.gz/.sorted.bam/g')
marked_bam=$(echo "$fastq1" | sed 's/_R1.fastq.gz/.marked.bam/g')
coverage_file=$(echo "$fastq1" | sed 's/_R1.fastq.gz/.coverage/g')

# Filtrer les lectures contenant uniquement GGGGCC ainsi que celles contenant au moins trois répétitions en tandem de GGGGCC pour le fichier R1.
./filter_reads.sh "$fastq1" "$fastq2"

# Construire les index depuis la référence pour HISAT2
if [[ ! -f "$index_prefix".1.ht2 ]]; then
  # Utilisation de HISAT2 pour l'alignement des reads sur le génome de référence
  hisat2-build "$reference" "$index_prefix"
fi

# Alignement
# Utilisation de HISAT2 pour l'alignement des reads sur le génome de référence
hisat2 -x "$index_prefix" -1 "${fastq1%%.*}_filtered.fastq.gz" -2 "${fastq2%%.*}_filtered.fastq.gz" -S "$sam"

# Conversion du fichier SAM en fichier BAM, tri et indexation
samtools view -bS "$sam" | samtools sort -n -o "$sorted_bam" -
samtools index "$sorted_bam"

# Utilisation de Samtools pour le marquage des duplicatas et l'indexation
samtools markdup -r -s "$sorted_bam" "$marked_bam"
samtools index "$marked_bam"

# Utilisation de Samtools pour le calcul de la couverture du génome
samtools coverage "$marked_bam" > "$coverage_file"

# Utilisation de ExpansionHunter pour l'analyse des variants
./ExpansionHunter --reads "$marked_bam" --reference "$reference" --variant-catalog ../../../variant_catalog/hg38/variant_catalog.json --output-prefix "$(basename "$marked_bam" .marked.bam)_exphunt"

# Indexation du fichier BAM de sortie
samtools index "$(basename "$marked_bam" .marked.bam)_exphunt_realigned.bam"

# Utilisation de REViewer pour l'affichage graphique des expansions en tandem
./REViewer --reads "$(basename "$marked_bam" .marked.bam)_exphunt_realigned.bam" --vcf "$(basename "$marked_bam" .marked.bam)_exphunt.vcf" --reference "$reference" --catalog ../../../variant_catalog

