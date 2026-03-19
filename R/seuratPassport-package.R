#' seuratPassport: Passport System for Seurat Objects
#'
#' @description
#' Stamps Seurat objects with a persistent metadata passport stored in
#' \code{@misc$passport}. Tracks animal info, experiment details, lineage
#' (parent/child relationships), RDS registry numbers, processing logs,
#' and custom fields. Includes an interactive Shiny popup to fill and
#' update the passport, and a read mode to print it to console.
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
