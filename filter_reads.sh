#!/bin/bash

# Variables
input_r1="$1"
input_r2="$2"
output_r1="${input_r1%%.*}_filtered.fastq.gz"
output_r2="${input_r2%%.*}_filtered.fastq.gz"

# Extraire les reads purs GGGGCC pour le fichier R1
grep -A 3 -B 1 '^GGGGCC$' <(zcat "$input_r1") > "${input_r1%%.*}_GGGGCC.fastq"
grep -c '^@' "${input_r1%%.*}_GGGGCC.fastq" > "${input_r1%%.*}_GGGGCC_count.txt"

# Extraire les reads contenant au moins 3 répétitions en tandem GGGGCC du fichier R1
grep -A 1 -B 2 -E '^.{0,}GGGGCCGGGGCCGGGGCC.{0,}$' <(zcat "$input_r1") > "${input_r1%%.*}_3repeats.fastq"
grep -c '^@' "${input_r1%%.*}_3repeats.fastq" > "${input_r1%%.*}_3repeats_count.txt"

# Concaténer les reads dans un gros fichier R1
cat "${input_r1%%.*}_GGGGCC.fastq" "${input_r1%%.*}_3repeats.fastq" | gzip > "$output_r1"

# Extraire les reads purs GGGGCC pour le fichier R2
grep -A 3 -B 1 '^GGGGCC$' <(zcat "$input_r2") > "${input_r2%%.*}_GGGGCC.fastq"
grep -c '^@' "${input_r2%%.*}_GGGGCC.fastq" > "${input_r2%%.*}_GGGGCC_count.txt"

# Extraire les reads contenant au moins 3 répétitions en tandem GGGGCC du fichier R2
grep -A 1 -B 2 -E '^.{0,}GGGGCCGGGGCCGGGGCC.{0,}$' <(zcat "$input_r2") > "${input_r2%%.*}_3repeats.fastq"
grep -c '^@' "${input_r2%%.*}_3repeats.fastq" > "${input_r2%%.*}_3repeats_count.txt"

# Concaténer les reads dans un gros fichier R2
cat "${input_r2%%.*}_GGGGCC.fastq" "${input_r2%%.*}_3repeats.fastq" | gzip > "$output_r2"

