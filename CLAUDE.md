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

## Size reduction (done in 1.29.1, uncommitted as of 2026-09-28)

Goal: source tarball under 100 MB. Result: 94.8 MB, `R CMD check` OK.

- `git rm`'d: `inst/extdata/quants/*/aux_info/bootstrap/` (Gibbs inf reps,
  ~393 MB), `aux_info/ambig_info.tsv.gz` (7.9 MB), and the full
  `gencode.v29.annotation.gtf.gz` (38 MB). All are in the Zenodo archive.
- Added `inst/extdata/gencode.v29.annotation.slim.gtf.gz` (5.1 MB; gene and
  transcript lines only, 6 attributes), made by `inst/scripts/makeSlimGTF.sh`.
  The distinct filename is deliberate: tximeta caches TxDbs in BiocFileCache
  keyed on the GTF basename, so a slim file under the canonical name could
  collide with a user's full Gencode v29 TxDb.
- Added `data/macro_txp_se.rda` (11 MB) and `data/macro_tx2gene.rda`
  (0.9 MB), built by `inst/scripts/makeSumExp.R`. `macro_txp_se` holds all
  transcripts of 2000 random expressed genes plus GBP1-GBP7, with 20 inf reps,
  and `counts`/`infRep` rounded to 1 decimal. The script needs a macrophage
  install that still has the bootstraps (<= 1.29.0, or the `with-inf-reps`
  branch).
- Docs for the new datasets are roxygen2 blocks in `R/data.R`. Regenerate with
  `roxygen2::roxygenise(roclets="rd")`: only the Rd roclet, because
  `NAMESPACE` and `man/gse.Rd` are hand-written.
- The fishpond swish vignette (`~/bioc/fishpond/github/fishpond`, devel) now
  uses `data(macro_txp_se)` and
  `summarizeToGene(se, skipRanges=TRUE, tx2gene=macro_tx2gene)`, and needs
  macrophage (>= 1.29.1). Push macrophage to Bioconductor before fishpond.
- Size budget: ~3.4 KB per transcript in `macro_txp_se` unrounded, ~1 KB
  rounded. Measure with `R CMD build` before adding anything.

## Gotchas

- Downstream code that used the full GTF path (e.g. the tidyomics
  fluent-genomics tutorial's `makeLinkedTxome(gtf=...)`) must switch to the
  slim filename. The slim file has no exons, so `addExons()` won't work.
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
