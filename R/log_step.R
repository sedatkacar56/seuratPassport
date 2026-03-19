#' Log a Processing Step to a Seurat, SingleCellExperiment, or SummarizedExperiment Object
#'
#' @description
#' Appends a processing step entry to the object's processing log.
#' For Seurat objects the log is stored in \code{@misc$processing_log};
#' for \code{SingleCellExperiment} and \code{SummarizedExperiment} objects it
#' is stored in \code{metadata(obj)$processing_log}.
#' Each entry records the step name, timestamp, cell count, gene count,
#' and any parameters you pass.
#'
#' @param obj A Seurat, SingleCellExperiment, or SummarizedExperiment object.
#' @param step A character string describing the processing step
#'   (e.g. \code{"NormalizeData"}, \code{"ScaleData"}, \code{"Subset cluster 1"}).
#' @param params A named list of parameters used in this step. Default is
#'   an empty list.
#'
#' @return The same object with the new log entry appended to its processing log.
#'
#' @examples
#' # Log a step on a minimal SummarizedExperiment object
#' if (requireNamespace("SummarizedExperiment", quietly = TRUE)) {
#'     se <- SummarizedExperiment::SummarizedExperiment()
#'     se <- log_step(se, "example step")
#' }
#'
#' \donttest{
#' seu <- log_step(seu, "QC filter",
#'         params = list(min_cells = 3, min_features = 200))
#'
#' seu <- NormalizeData(seu)
#' seu <- log_step(seu, "NormalizeData",
#'         params = list(method = "LogNormalize", scale_factor = 10000))
#'
#' seu <- RunPCA(seu)
#' seu <- log_step(seu, "RunPCA", params = list(npcs = 30))
#'
#' # View all logs:
#' read_passport(seu)
#' }
#'
#' @seealso \code{\link{seuratPassport}}, \code{\link{read_passport}}
#'
#' @export
log_step <- function(obj, step, params = list()) {

  if (is.null(obj)) {
    stop("obj cannot be NULL.")
  }

  new_entry <- build_log_entry(
    step    = step,
    n_cells = ncol(obj),
    n_genes = nrow(obj),
    params  = params
  )

  current_log <- .get_processing_log(obj)
  updated_log <- append_log_entry(
    log       = current_log,
    new_entry = new_entry
  )

  return(.set_processing_log(obj, updated_log))
}
