#' Read the Passport of a Seurat Object
#'
#' @description
#' Prints the full passport stored in \code{@misc$passport} to the console,
#' including all known fields, any custom fields, and the processing log.
#'
#' @param seurat_obj A Seurat object with a passport stamped via
#'   \code{\link{stamp_seurat_interactive}}.
#'
#' @return Invisibly returns \code{NULL}. Output is printed to console.
#'
#' @examples
#' \dontrun{
#' read_passport(WTHeme)
#'
#' # Or via stamp_seurat_interactive:
#' stamp_seurat_interactive(WTHeme, read = TRUE)
#' }
#'
#' @seealso \code{\link{stamp_seurat_interactive}}, \code{\link{log_step}}
#'
#' @export
read_passport <- function(seurat_obj) {

  p <- seurat_obj@misc$passport

  if (is.null(p)) {
    message("No passport found. Use stamp_seurat_interactive() to create one.")
    return(invisible())
  }

  cat("========== PASSPORT ==========\n")
  cat("Object ID  :", if (!is.null(p$object_id))  p$object_id  else "not set", "\n")
  cat("RDS Self   :", if (!is.null(p$rds_self))    p$rds_self   else "not set", "\n")
  cat("Created    :", if (!is.null(p$created))     p$created    else "not set", "\n")

  cat("-------- Animal --------\n")
  cat("Animal ID  :", if (!is.null(p$animal_id))  p$animal_id  else "not set", "\n")
  cat("Species    :", if (!is.null(p$species))     p$species    else "not set", "\n")
  cat("Sex        :", if (!is.null(p$sex))         p$sex        else "not set", "\n")
  cat("Age        :", if (!is.null(p$age))         p$age        else "not set", "\n")
  cat("Condition  :", if (!is.null(p$condition))   p$condition  else "not set", "\n")
  cat("Tissue     :", if (!is.null(p$tissue))      p$tissue     else "not set", "\n")

  cat("-------- Experiment --------\n")
  cat("Project    :", if (!is.null(p$project))     p$project    else "not set", "\n")
  cat("Researcher :", if (!is.null(p$researcher))  p$researcher else "not set", "\n")
  cat("Date       :", if (!is.null(p$date))        p$date       else "not set", "\n")
  cat("Notes      :", if (!is.null(p$notes))       p$notes      else "not set", "\n")

  cat("-------- Lineage --------\n")
  cat("Parent     :", if (!is.null(p$parent_id))    p$parent_id   else "root", "\n")
  cat("RDS Parent :", if (!is.null(p$rds_parent))   p$rds_parent  else "root", "\n")
  cat("Chain      :", if (length(p$lineage) > 0)    paste(p$lineage, collapse = " -> ") else "root", "\n")
  cat("Children   :", if (length(p$children) > 0)   paste(p$children,     collapse = ", ") else "none", "\n")
  cat("RDS Children:", if (length(p$rds_children) > 0) paste(p$rds_children, collapse = ", ") else "none", "\n")

  # Custom fields
  known <- c("object_id", "rds_self", "created",
             "animal_id", "species", "sex", "age", "condition", "tissue",
             "project", "researcher", "date", "notes",
             "parent_id", "rds_parent", "lineage",
             "children", "rds_children")
  extras <- setdiff(names(p), known)
  if (length(extras) > 0) {
    cat("-------- Custom Fields --------\n")
    for (field in extras) {
      cat(sprintf("%-15s: %s\n", field, p[[field]]))
    }
  }

  # Processing log
  cat("======= PROCESSING LOG =======\n")
  if (length(seurat_obj@misc$processing_log) == 0) {
    cat("No processing steps logged yet.\n")
  } else {
    for (i in seq_along(seurat_obj@misc$processing_log)) {
      entry <- seurat_obj@misc$processing_log[[i]]
      cat(sprintf("[%d] %-25s | %s cells | %s\n",
                  i, entry$step, entry$n_cells, entry$time))
    }
  }

  cat("==============================\n")
  return(invisible())
}
