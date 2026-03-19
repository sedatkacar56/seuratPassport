#' Read the Passport of a Seurat Object
#'
#' @description
#' Prints the full passport stored in \code{@misc$passport} to the console,
#' including all known fields, any custom fields, and the processing log.
#'
#' @param seurat_obj A Seurat object with a passport stamped via
#'   \code{\link{seuratPassport}}.
#'
#' @return Invisibly returns \code{NULL}. Output is printed to console.
#'
#' @examples
#' \dontrun{
#' read_passport(WTHeme)
#'
#' # Or via seuratPassport with read = TRUE:
#' seuratPassport(WTHeme, read = TRUE)
#' }
#'
#' @seealso \code{\link{seuratPassport}}, \code{\link{log_step}}
#'
#' @export
read_passport <- function(seurat_obj) {

  p <- seurat_obj@misc$passport

  if (is.null(p)) {
    message("No passport found. Use seuratPassport() to create one.")
    return(invisible())
  }

  fld <- function(x) if (!is.null(x)) x else "not set"

  lines <- c(
    "========== PASSPORT ==========",
    paste("Object ID  :", fld(p$object_id)),
    paste("RDS Self   :", fld(p$rds_self)),
    paste("Created    :", fld(p$created)),
    "-------- Animal --------",
    paste("Animal ID  :", fld(p$animal_id)),
    paste("Species    :", fld(p$species)),
    paste("Sex        :", fld(p$sex)),
    paste("Age        :", fld(p$age)),
    paste("Condition  :", fld(p$condition)),
    paste("Tissue     :", fld(p$tissue)),
    "-------- Experiment --------",
    paste("Project    :", fld(p$project)),
    paste("Researcher :", fld(p$researcher)),
    paste("Date       :", fld(p$date)),
    paste("Notes      :", fld(p$notes)),
    "-------- Lineage --------",
    paste("Parent     :", if (!is.null(p$parent_id)) p$parent_id else "root"),
    paste("RDS Parent :", if (!is.null(p$rds_parent)) p$rds_parent else "root"),
    paste("Chain      :",
        if (length(p$lineage) > 0) paste(p$lineage, collapse = " -> ")
        else "root"),
    paste("Children   :",
        if (length(p$children) > 0) paste(p$children, collapse = ", ")
        else "none"),
    paste("RDS Children:",
        if (length(p$rds_children) > 0) paste(p$rds_children, collapse = ", ")
        else "none")
  )

  known <- c(
    "object_id", "rds_self", "created",
    "animal_id", "species", "sex", "age", "condition", "tissue",
    "project", "researcher", "date", "notes",
    "parent_id", "rds_parent", "lineage", "children", "rds_children"
  )
  extras <- setdiff(names(p), known)
  if (length(extras) > 0) {
    lines <- c(lines, "-------- Custom Fields --------")
    for (field in extras) {
        lines <- c(lines, sprintf("%-15s: %s", field, p[[field]]))
    }
  }

  log_lines <- c("======= PROCESSING LOG =======")
  if (length(seurat_obj@misc$processing_log) == 0) {
    log_lines <- c(log_lines, "No processing steps logged yet.")
  } else {
    for (i in seq_along(seurat_obj@misc$processing_log)) {
        entry <- seurat_obj@misc$processing_log[[i]]
        log_lines <- c(log_lines,
            sprintf("[%d] %-25s | %s cells | %s",
                i, entry$step, entry$n_cells, entry$time))
    }
  }

  message(paste(c(lines, log_lines, "=============================="),
                collapse = "\n"))
  return(invisible())
}
