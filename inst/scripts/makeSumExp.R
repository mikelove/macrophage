# Build two datasets for demonstrating Swish (fishpond) with
# inferential replicates, without shipping the full Salmon Gibbs samples:
#
# 'macro_txp_se': transcript-level SummarizedExperiment with 20 Gibbs
#   inferential replicates for all 24 samples, for all transcripts of
#   a random subset of 2000 expressed genes (plus the GBP gene family,
#   GBP1-GBP7, discussed in the fishpond vignette). 'counts' and 'infRep'
#   assays are rounded to 1 decimal to reduce size.
# 'macro_tx2gene': DataFrame mapping all Gencode v29 transcripts to genes,
#   for use with summarizeToGene(..., skipRanges=TRUE, tx2gene=).
#
# The full Salmon output including inferential replicates is archived on
# Zenodo: https://doi.org/10.5281/zenodo.22982581
# This script must be run with a version of macrophage that still
# includes the 'aux_info/bootstrap' directories (<= 1.29.0).
library(SummarizedExperiment)
library(tximeta)
library(org.Hs.eg.db)
library(macrophage)
dir <- system.file("extdata", package="macrophage")
coldata <- read.csv(file.path(dir, "coldata.csv"))
coldata <- coldata[,c(1,2,3,5)]
names(coldata) <- c("names","id","line","condition")
coldata$files <- file.path(dir, "quants", coldata$names, "quant.sf.gz")
stopifnot(all(file.exists(coldata$files)))
# 'LocalGENCODE' tells tximeta to build the TxDb from the local GTF
# (no AnnotationHub or FTP), while still allowing addIds() to work
makeLinkedTxome(
  indexDir=file.path(dir, "gencode.v29_salmon_0.12.0"),
  source="LocalGENCODE",
  organism="Homo sapiens",
  release="29",
  genome="GRCh38",
  fasta="ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.transcripts.fa.gz",
  gtf=file.path(dir, "gencode.v29.annotation.gtf.gz"),
  write=FALSE
)
se <- tximeta(coldata)
gene_id <- unlist(mcols(se)$gene_id)
stopifnot(length(gene_id) == nrow(se))

# transcript-to-gene table for all transcripts
macro_tx2gene <- DataFrame(tx_name=rownames(se), gene_id=gene_id)

# expressed genes: at least one transcript with a count of 10
# or more in 3 or more samples
txp_expr <- rowSums(assay(se, "counts") >= 10) >= 3
expr_genes <- unique(gene_id[txp_expr])
gbp <- mapIds(org.Hs.eg.db, paste0("GBP", 1:7), "ENSEMBL", "SYMBOL")
gbp_genes <- unique(gene_id[sub("\\..*", "", gene_id) %in% gbp])
set.seed(1)
genes <- union(gbp_genes, sample(expr_genes, 2000))
macro_txp_se <- se[gene_id %in% genes,]

# round counts and inferential replicates to reduce size
for (a in grep("^counts$|^infRep", assayNames(macro_txp_se), value=TRUE)) {
  assay(macro_txp_se, a) <- round(assay(macro_txp_se, a), 1)
}

save(macro_txp_se, file="macro_txp_se.rda", compress="xz")
save(macro_tx2gene, file="macro_tx2gene.rda", compress="xz")
