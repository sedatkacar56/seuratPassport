#' seuratPassport: Passport System for Single-Cell Objects
#'
#' @description
#' Stamps Seurat, SingleCellExperiment, and SummarizedExperiment objects
#' with a persistent metadata passport. For Seurat objects the passport is
#' stored in \code{@misc$passport}; for SingleCellExperiment and
#' SummarizedExperiment objects it is stored in \code{metadata(obj)$passport}.
#' Tracks animal info, experiment details, lineage (parent/child relationships),
#' RDS registry numbers, processing logs, and custom fields. Includes an
#' interactive Shiny popup to fill and update the passport, and a read mode
#' to print it to console.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{seuratPassport}} — Open popup to fill/update passport
#'   \item \code{\link{read_passport}}            — Print passport to console
#'   \item \code{\link{log_step}}                 — Log a processing step
#' }
#'
#' @section Typical Workflow:
#' \preformatted{
#' # 1. Stamp your root object
#' WTHeme <- seuratPassport(WTHeme)
#'
#' # 2. Log processing steps
#' WTHeme <- NormalizeData(WTHeme)
#' WTHeme <- log_step(WTHeme, "NormalizeData")
#'
#' # 3. Subset and stamp child, linking to parent
#' EndofrHeme <- subset(WTHeme, subset = cell_type == "Endothelial")
#' EndofrHeme <- seuratPassport(EndofrHeme, parent = WTHeme)
#'
#' # 4. Read passport anytime
#' read_passport(EndofrHeme)
#' }
#'
#' @docType package
#' @name seuratPassport
"_PACKAGE"

#' @importFrom S4Vectors metadata metadata<-
#' @importFrom Rcpp evalCpp
#' @useDynLib seuratPassport, .registration = TRUE
NULL

# ---- Internal helpers: object-type-agnostic passport access ----

.is_seurat <- function(obj) inherits(obj, "Seurat")
.is_sce    <- function(obj) inherits(obj, "SingleCellExperiment")
.is_se     <- function(obj) inherits(obj, "SummarizedExperiment")

.get_passport <- function(obj) {
  if (.is_seurat(obj)) return(obj@misc$passport)
  if (.is_sce(obj) || .is_se(obj)) return(metadata(obj)$passport)
  stop("obj must be a Seurat, SingleCellExperiment, or SummarizedExperiment object.")
}

.set_passport <- function(obj, passport) {
  if (.is_seurat(obj)) {
    obj@misc$passport <- passport
    return(obj)
  }
  if (.is_sce(obj) || .is_se(obj)) {
    md <- metadata(obj)
    md$passport <- passport
    metadata(obj) <- md
    return(obj)
  }
  stop("obj must be a Seurat, SingleCellExperiment, or SummarizedExperiment object.")
}

.get_processing_log <- function(obj) {
  if (.is_seurat(obj)) {
    log <- obj@misc$processing_log
    return(if (is.null(log)) list() else log)
  }
  if (.is_sce(obj) || .is_se(obj)) {
    log <- metadata(obj)$processing_log
    return(if (is.null(log)) list() else log)
  }
  stop("obj must be a Seurat, SingleCellExperiment, or SummarizedExperiment object.")
}

.set_processing_log <- function(obj, log) {
  if (.is_seurat(obj)) {
    obj@misc$processing_log <- log
    return(obj)
  }
  if (.is_sce(obj) || .is_se(obj)) {
    md <- metadata(obj)
    md$processing_log <- log
    metadata(obj) <- md
    return(obj)
  }
  stop("obj must be a Seurat, SingleCellExperiment, or SummarizedExperiment object.")
}
