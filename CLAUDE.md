# CLAUDE.md

Bioconductor ExperimentData package `macrophage`: Salmon 0.12.0 quantifications
(Gencode v29, `--numGibbsSamples 20`) for 24 RNA-seq samples from Alasoo et al.
(2018). No R code — only data, docs (`man/`), a vignette, and build scripts in
`inst/scripts/`.

## Branches

- Work only on `devel`. On this machine `devel` tracks `origin/devel` (GitHub);
  to send changes to Bioconductor, run `git push upstream devel`. `master` is
  stale (Bioconductor 3.13 era), so don't use it.
- `with-inf-reps` (on GitHub) is a frozen snapshot that still has the full
  inferential replicates. It has been released on Zenodo; point users there for
  the full inf reps.

## Current goal: get the source tarball under 100 MB

Most of the size is the Gibbs inferential replicates:

| Path | Size |
|---|---|
| `inst/extdata/quants/*/aux_info/bootstrap/` | ~15 MB × 24 samples ≈ 360 MB |
| `inst/extdata/quants/*/quant.sf.gz` | ~2.7 MB × 24 ≈ 66 MB |
| `inst/extdata/gencode.v29.annotation.gtf.gz` | 38 MB |
| `data/gse.rda` | 8.5 MB |

The plan is to delete the `bootstrap/` directories. That breaks the fishpond
`swish` vignette, which reads the inf reps with `tximeta()` from this package's
`extdata`. So **before** removing anything:

1. Write `inst/scripts/makeSumExp.R`. It builds a transcript-level
   `SummarizedExperiment` **with** inf reps (`infRep1`..`infRep20`) from the
   current `quants/`, using the same import steps as the fishpond vignette
   (`../fishpond/fishpond/vignettes/swish.Rmd`):
   - `coldata <- read.csv(file.path(dir, "coldata.csv"))[, c(1,2,3,5)]`,
     renamed to `names, id, line, condition`, plus
     `files = file.path(dir, "quants", names, "quant.sf.gz")`.
   - Register the linkedTxome with `makeLinkedTxome()` pointing at the local
     GTF (source `"myGENCODE"`, as in the vignette's hidden chunk), then call
     `tximeta(coldata)`, then set `metadata(se)$txomeInfo$source <- "GENCODE"`.
   - Load all 24 samples. The vignette uses the naive/IFNg subset for the
     two-group analysis and all four conditions for the interaction analysis.
   - Keep only transcripts on the chromosomes the vignette uses (chr1 and chr4)
     to keep the object small. Keep the `rowRanges`, `mcols` (`gene_id`,
     `tx_id`, ...), and `metadata` that `summarizeToGene`, `addIds`, and
     `isoformProportions` need.
   - Save with `save(..., compress="xz")` into `data/`. Pick the object name
     now: the fishpond vignette will call `data(<name>, package="macrophage")`.
2. Document the new dataset in `man/<name>.Rd`, following `man/gse.Rd`. Say
   which chromosomes and samples it contains, that the assays include 20 Gibbs
   inf reps, and that `inst/scripts/makeSumExp.R` builds it.
3. Check that the swish vignette's steps run on the saved object (subsetting,
   `scaleInfReps`, `labelKeep`, `swish`, `summarizeToGene`, `addIds`,
   `isoformProportions`, `computeInfRV`). Only then remove the
   `aux_info/bootstrap/` directories. Mention the Zenodo release (DOI) in
   the vignette and `.Rd` as the place to get the full inf reps.
4. Update the fishpond vignette (a separate repo) to load the object instead of
   calling `tximeta()`.
5. Rebuild and check the tarball size: `R CMD build .`, then `ls -lh macrophage_*.tar.gz`.

## Gotchas

- `summarizeToGene()` looks up the TxDb through the linkedTxome/BiocFileCache,
  so it may still need the GTF (or internet access) when the vignette runs.
  Confirm this before assuming the GTF can be dropped. If the GTF is dropped,
  the bioc build machines will need another route.
- Without the inf reps, the tarball is still roughly 66 + 38 + 8.5 MB plus the
  new `.rda`. The `.gz` files barely compress further, so the result may be
  close to the 100 MB limit. Measure it; don't assume.
- `inst/scripts/gse_create.R` builds the existing gene-level `gse` (with
  `dropInfReps=TRUE`). Leave it and `data/gse.rda` alone; other packages and
  vignettes use them.
- Scripts in `inst/scripts/` are provenance records that are run manually
  from the installed package (`system.file("extdata", package="macrophage")`).
  They are not run during build or check.
- The package version follows Bioconductor's odd/even scheme (devel is odd
  `y`). Bump `z` in `DESCRIPTION` when making changes.
- `external_data_store.txt` lists `data` and `inst/extdata`. Bioc stores these
  directories outside git, so deleting files there has to be pushed to the
  data store as well.
