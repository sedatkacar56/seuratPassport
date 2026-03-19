#' Log a Processing Step to a Seurat Object
#'
#' @description
#' Appends a processing step entry to \code{@misc$processing_log} inside
#' the Seurat object. Each entry records the step name, timestamp, cell count,
#' gene count, and any parameters you pass.
#'
#' @param seurat_obj A Seurat object.
#' @param step A character string describing the processing step
#'   (e.g. \code{"NormalizeData"}, \code{"ScaleData"}, \code{"Subset cluster 1"}).
#' @param params A named list of parameters used in this step. Default is
#'   an empty list.
#'
#' @return The same Seurat object with the new log entry appended to
#'   \code{@misc$processing_log}.
#'
#' @examples
#' \dontrun{
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
#' @seealso \code{\link{stamp_seurat_interactive}}, \code{\link{read_passport}}
#'
#' @export
log_step <- function(seurat_obj, step, params = list()) {

  if (is.null(seurat_obj)) stop("seurat_obj is NULL.")

  new_entry <- list(
    step    = step,
    time    = as.character(Sys.time()),
    n_cells = ncol(seurat_obj),
    n_genes = nrow(seurat_obj),
    params  = params
  )

  seurat_obj@misc$processing_log <- c(
    seurat_obj@misc$processing_log,
    list(new_entry)
  )

  return(seurat_obj)
}
