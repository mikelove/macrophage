#!/bin/sh
# Create a reduced version of the Gencode v29 GTF, keeping only the
# 'gene' and 'transcript' features (no exon, CDS, UTR, codon lines)
# and only the attributes: gene_id, transcript_id, gene_type,
# gene_name, transcript_type, transcript_name.
# txdbmaker::makeTxDbFromGFF() can build transcript and gene ranges
# from this file (each transcript is represented by a single exon
# spanning the transcript), but it does not contain exon structure.
# The original GTF (38 Mb) was downloaded from:
# ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.annotation.gtf.gz
# A distinct filename is used so that tximeta's BiocFileCache entries
# (keyed on the GTF basename) do not collide with the full GTF.
gzip -dc gencode.v29.annotation.gtf.gz |
  awk -F'\t' 'BEGIN{OFS="\t"}
    /^#/ {print; next}
    $3=="gene" || $3=="transcript" {
      n=split($9,a,"; *"); s=""
      for (i=1;i<=n;i++) {
        if (a[i] ~ /^(gene_id|transcript_id|gene_type|gene_name|transcript_type|transcript_name) /)
          s=s a[i] "; "
      }
      sub(/ $/,"",s); $9=s; print
    }' |
  gzip -9 > gencode.v29.annotation.slim.gtf.gz
