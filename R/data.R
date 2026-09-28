#' Macrophage dataset - transcript-level quantification with inferential replicates
#'
#' Salmon quantification of 24 RNA-seq samples from Alasoo, et al. (2018),
#' imported with \code{tximeta}, including the 20 inferential replicates
#' from Salmon's Gibbs sampler (assays \code{infRep1}, ..., \code{infRep20}).
#' It is used in the \code{swish} vignette of the \code{fishpond} package.
#'
#' To reduce size, the object contains all transcripts of a random subset
#' of 2000 expressed genes (at least one transcript with a count of 10 or
#' more in 3 or more samples) plus the GBP gene family (GBP1-GBP7), and the
#' \code{counts} and \code{infRep} assays are rounded to 1 decimal.
#' The full Salmon output for all transcripts, including the inferential
#' replicates, is archived on Zenodo:
#' \doi{10.5281/zenodo.22982581}.
#' For the script used to build this object, see \code{makeSumExp.R}
#' in the \code{scripts} directory of the installed package.
#'
#' @format A \code{RangedSummarizedExperiment} with 15294 transcripts
#' and 24 samples. Assays: \code{counts}, \code{abundance},
#' \code{length}, and \code{infRep1}, ..., \code{infRep20}.
#' \code{colData} columns: \code{names}, \code{id}, \code{line},
#' \code{condition}.
#'
#' @source FASTQ files from ENA
#'
#' @references Alasoo, et al. "Shared genetic effects on chromatin and gene
#' expression indicate a role for enhancer priming in immune response",
#' Nature Genetics, January 2018 \doi{10.1038/s41588-018-0046-7}.
#'
#' @seealso \code{\link{macro_tx2gene}}
#'
#' @usage data("macro_txp_se")
#' @keywords datasets
"macro_txp_se"

#' Macrophage dataset - transcript-to-gene table
#'
#' A table mapping all transcripts of the Gencode v29 human reference
#' (as indexed by Salmon for the macrophage dataset) to genes. It can be
#' used to summarize \code{\link{macro_txp_se}} to the gene level with
#' \code{tximeta::summarizeToGene(se, skipRanges=TRUE, tx2gene=macro_tx2gene)},
#' which does not require the GTF file. For the script used to build this
#' object, see \code{makeSumExp.R} in the \code{scripts} directory of the
#' installed package.
#'
#' @format A \code{DataFrame} with 205870 rows and columns
#' \code{tx_name} and \code{gene_id}.
#'
#' @source Gencode v29 human reference transcripts
#'
#' @seealso \code{\link{macro_txp_se}}
#'
#' @usage data("macro_tx2gene")
#' @keywords datasets
"macro_tx2gene"
