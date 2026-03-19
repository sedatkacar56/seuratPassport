# seuratPassport 0.99.0

## New Features

* Initial Bioconductor submission version.
* `seuratPassport()`: interactive Shiny gadget to stamp a Seurat object with
  a persistent metadata passport stored in `@misc$passport`.
* `read_passport()`: prints the full passport and processing log to console.
* `log_step()`: appends a processing step entry to `@misc$processing_log`.
* Core passport and log logic implemented in C++ via Rcpp for performance.
* Lineage tracking: parent/child relationships propagated automatically when
  `parent` argument is supplied to `seuratPassport()`.
* Custom fields: any extra key-value metadata can be added through the Shiny
  popup and persists inside the `.rds` file.
