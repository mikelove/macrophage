# macrophage 1.29.1

## Reduced package size

The source tarball is now under 100 MB (94.8 MB), down from over
100 MB. The following files were removed. All of them are archived, with the full
Salmon output for all 24 samples, on Zenodo:
<https://doi.org/10.5281/zenodo.22982581>. The `with-inf-reps` branch
on GitHub is a frozen snapshot of the package that still includes them.

* The Gibbs inferential replicates
  (`inst/extdata/quants/*/aux_info/bootstrap/`, ~393 MB).
  `tximeta()` / `tximport()` on the files in `inst/extdata/quants` no
  longer imports inferential replicates.
* `aux_info/ambig_info.tsv.gz` for each sample.
* The full Gencode v29 GTF, `inst/extdata/gencode.v29.annotation.gtf.gz`.

## New files and datasets

* `inst/extdata/gencode.v29.annotation.slim.gtf.gz`: a slim Gencode v29
  GTF with only gene and transcript lines and 6 attributes (5 MB instead
  of 38 MB). It has no exon lines, so `tximeta::addExons()` will not
  work with it. It has a different filename from the full GTF on purpose:
  tximeta caches TxDbs by GTF filename, so this avoids clashing with a
  TxDb built from the full Gencode v29 GTF. Code that called
  `makeLinkedTxome(gtf=...)` with the full GTF path should switch to the
  slim filename. Built by `inst/scripts/makeSlimGTF.sh`.
* `data(macro_txp_se)`: a transcript-level `SummarizedExperiment` with
  20 inferential replicates, for all transcripts of 2000 random expressed
  genes plus GBP1-GBP7. The `counts` and `infRep` assays are rounded to
  1 decimal. This is now used by the fishpond `swish` vignette.
* `data(macro_tx2gene)`: a transcript-to-gene table for all Gencode v29
  transcripts, for use with
  `tximeta::summarizeToGene(se, skipRanges=TRUE, tx2gene=macro_tx2gene)`.
* Both datasets are built by `inst/scripts/makeSumExp.R`. The script
  needs a macrophage install that still has the inferential replicates
  (<= 1.29.0, or the `with-inf-reps` branch).

## Unchanged

* The gene-level `data(gse)` object and the quantification files
  (`quant.sf.gz`, etc.) in `inst/extdata/quants` are unchanged.
