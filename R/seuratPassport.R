#' Stamp a Seurat Object with a Passport
#'
#' @description
#' Opens an interactive Shiny popup that allows you to fill in metadata
#' (animal info, experiment details, lineage, RDS numbers, and custom fields)
#' and stamps it directly into the Seurat object's \code{@misc$passport} slot.
#' All information persists inside the object when saved as \code{.rds}.
#'
#' If a passport already exists in the object, all previously filled fields
#' are pre-loaded into the popup so you only need to update what changed.
#'
#' @param seurat_obj A Seurat object to stamp. Must not be NULL.
#' @param parent A parent Seurat object that this object was subset from.
#'   If provided, \code{parent_id} and \code{lineage} are automatically
#'   populated from the parent's passport — no typing needed.
#'   Default is \code{NULL} (root object).
#' @param read Logical. If \code{TRUE}, prints the existing passport to the
#'   console instead of opening the popup. Default is \code{FALSE}.
#'
#' @return The same Seurat object with \code{@misc$passport} filled in.
#'   If cancelled or an error occurs, the original object is returned unchanged
#'   — it will never return \code{NULL}.
#'
#' @details
#' The passport stored in \code{@misc$passport} contains the following fields:
#'
#' \strong{Identity:}
#' \itemize{
#'   \item \code{object_id}  — Name/ID of this Seurat object (e.g. "WTHeme")
#'   \item \code{rds_self}   — RDS registry number of this object (e.g. 224)
#'   \item \code{created}    — Timestamp of when passport was stamped
#' }
#'
#' \strong{Animal Info:}
#' \itemize{
#'   \item \code{animal_id}  — Individual animal identifier (e.g. "M01")
#'   \item \code{species}    — Species name (e.g. "Mus musculus")
#'   \item \code{sex}        — Sex of the animal (e.g. "male", "female")
#'   \item \code{age}        — Age of the animal (e.g. "P60")
#'   \item \code{condition}  — Experimental condition (e.g. "control", "treated")
#'   \item \code{tissue}     — Tissue of origin (e.g. "prefrontal cortex")
#' }
#'
#' \strong{Experiment Info:}
#' \itemize{
#'   \item \code{project}    — Project name (e.g. "memory_study")
#'   \item \code{researcher} — Name of the researcher
#'   \item \code{date}       — Date of the experiment
#'   \item \code{notes}      — Any free-text notes
#' }
#'
#' \strong{Lineage:}
#' \itemize{
#'   \item \code{parent_id}    — Object ID of the direct parent (or "root")
#'   \item \code{rds_parent}   — RDS number of the parent object (or "root")
#'   \item \code{lineage}      — Full ancestry chain as a character vector
#'   \item \code{children}     — Object IDs of children subset from this object
#'   \item \code{rds_children} — RDS numbers of children objects
#' }
#'
#' \strong{Custom Fields:}
#' Any additional fields typed into the Custom Fields section of the popup
#' are automatically appended to the passport and displayed when \code{read = TRUE}.
#'
#' \strong{Safety:}
#' The function will never overwrite your object with \code{NULL}.
#' Cancelling the popup or any error returns the original object unchanged.
#'
#' @examples
#' \dontrun{
#' # --- Stamp a root object (no parent) ---
#' WTHeme <- seuratPassport (WTHeme)
#'
#' # --- Stamp a child subset, linking to parent automatically ---
#' EndofrHeme <- seuratPassport (EndofrHeme, parent = WTHeme)
#'
#' # --- Read existing passport without opening popup ---
#' seuratPassport (WTHeme, read = TRUE)
#'
#' # --- Or use the dedicated read function ---
#' read_passport(WTHeme)
#' }
#'
#' @seealso \code{\link{read_passport}}, \code{\link{log_step}}
#'
#' @importFrom shiny observeEvent stopApp runGadget dialogViewer textInput
#'   textAreaInput dateInput fluidRow column tags h4 p
#' @importFrom miniUI miniPage gadgetTitleBar miniContentPanel
#'
#' @export
seuratPassport  <- function(seurat_obj, parent = NULL, read = FALSE) {

  # Safety check
  if (is.null(seurat_obj)) {
    stop("seurat_obj cannot be NULL. Please reload your object first.")
  }

  p        <- seurat_obj@misc$passport
  existing <- function(field) if (!is.null(p[[field]])) p[[field]] else ""

  known <- c("object_id", "rds_self", "created",
             "animal_id", "species", "sex", "age", "condition", "tissue",
             "project", "researcher", "date", "notes",
             "parent_id", "rds_parent", "lineage",
             "children", "rds_children")

  existing_customs <- if (!is.null(p)) setdiff(names(p), known) else c()
  custom_keys      <- c(existing_customs, rep("", max(0, 5 - length(existing_customs))))

  # ---- READ MODE ----
  if (read) {
    read_passport(seurat_obj)
    return(invisible())
  }

  # ---- UI ----
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("\U0001F9EC Seurat Passport"),
    miniUI::miniContentPanel(

      shiny::h4("Identity"),
      shiny::fluidRow(
        shiny::column(8, shiny::textInput("object_id", "Object ID",
                                          value = existing("object_id"),
                                          placeholder = "e.g. WTHeme")),
        shiny::column(4, shiny::textInput("rds_self", "Self RDS No.",
                                          value = if (!is.null(p$rds_self)) p$rds_self else "",
                                          placeholder = "e.g. 224"))
      ),

      shiny::h4("Animal Info"),
      shiny::fluidRow(
        shiny::column(6, shiny::textInput("animal_id", "Animal ID",
                                          value = existing("animal_id"), placeholder = "M01")),
        shiny::column(6, shiny::textInput("species", "Species",
                                          value = existing("species"), placeholder = "Mus musculus"))
      ),
      shiny::fluidRow(
        shiny::column(4, shiny::textInput("sex", "Sex",
                                          value = existing("sex"), placeholder = "male/female")),
        shiny::column(4, shiny::textInput("age", "Age",
                                          value = existing("age"), placeholder = "P60")),
        shiny::column(4, shiny::textInput("condition", "Condition",
                                          value = existing("condition"), placeholder = "control/treated"))
      ),
      shiny::textInput("tissue", "Tissue",
                       value = existing("tissue"), placeholder = "e.g. prefrontal cortex"),

      shiny::h4("Experiment Info"),
      shiny::fluidRow(
        shiny::column(6, shiny::textInput("project", "Project",
                                          value = existing("project"), placeholder = "memory_study")),
        shiny::column(6, shiny::textInput("researcher", "Researcher",
                                          value = existing("researcher"), placeholder = "Your name"))
      ),
      shiny::dateInput("date", "Date",
                       value = if (!is.null(p$date)) as.Date(p$date) else Sys.Date()),
      shiny::textAreaInput("notes", "Notes",
                           value = existing("notes"),
                           placeholder = "Any extra notes...", rows = 2),

      shiny::h4("Lineage"),
      shiny::fluidRow(
        shiny::column(12, shiny::textInput("parent_id", "Parent Object ID",
                                           value = existing("parent_id"),
                                           placeholder = "e.g. WTHeme — leave blank if root"))
      ),
      shiny::fluidRow(
        shiny::column(6, shiny::textInput("rds_parent", "RDS No. of Parent",
                                          value = if (!is.null(p$rds_parent)) p$rds_parent else "",
                                          placeholder = "e.g. 224")),
        shiny::column(6, shiny::textInput("rds_children", "RDS No. of Children",
                                          value = if (!is.null(p$rds_children)) paste(p$rds_children, collapse = ", ") else "",
                                          placeholder = "e.g. 225, 226"))
      ),
      shiny::tags$small("\U0001F4A1 Use RDS numbers directly with rds_function()"),
      shiny::tags$br(),
      shiny::tags$small(shiny::tags$b("Full chain: "),
                        if (length(p$lineage) > 0) paste(p$lineage, collapse = " \u2192 ") else "root"),
      shiny::tags$br(),
      shiny::fluidRow(
        shiny::column(12, shiny::textInput("children", "Child Objects (comma separated)",
                                           value = if (!is.null(p$children)) paste(p$children, collapse = ", ") else "",
                                           placeholder = "e.g. EndofrHeme224, gCapC, gCapB"))
      ),
      shiny::tags$small("\U0001F4DD Record any subsets/children created FROM this object"),
      shiny::tags$br(), shiny::tags$br(),

      shiny::h4("\u2795 Custom Fields"),
      shiny::p("Add any extra fields below (name = value):"),
      lapply(seq_along(custom_keys), function(i) {
        key <- custom_keys[i]
        shiny::fluidRow(
          shiny::column(5, shiny::textInput(paste0("custom_key", i), "Field name", value = key)),
          shiny::column(5, shiny::textInput(paste0("custom_val", i), "Value",      value = existing(key)))
        )
      })
    )
  )

  # ---- SERVER ----
  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {

      ckeys <- character(0)
      cvals <- character(0)
      for (i in seq_along(custom_keys)) {
        k <- trimws(input[[paste0("custom_key", i)]])
        v <- trimws(input[[paste0("custom_val", i)]])
        if (nchar(k) > 0 && nchar(v) > 0) { ckeys <- c(ckeys, k); cvals <- c(cvals, v) }
      }

      parent_id_val <- if (!is.null(parent)) parent@misc$passport$object_id
                       else if (nchar(trimws(input$parent_id)) > 0) trimws(input$parent_id)
                       else "root"

      lineage_val <- if (!is.null(parent)) c(parent@misc$passport$lineage, parent@misc$passport$object_id)
                     else if (nchar(trimws(input$parent_id)) > 0) c(p$lineage, trimws(input$parent_id))
                     else character(0)

      children_val    <- if (nchar(trimws(input$children)) > 0)
                           strsplit(trimws(input$children), ",\\s*")[[1]]
                         else character(0)

      rds_children_val <- if (nchar(trimws(input$rds_children)) > 0)
                            strsplit(trimws(input$rds_children), ",\\s*")[[1]]
                          else character(0)

      passport <- build_passport(
        object_id    = input$object_id,
        rds_self     = if (nchar(trimws(input$rds_self)) > 0) trimws(input$rds_self) else "not set",
        animal_id    = input$animal_id,
        species      = input$species,
        sex          = input$sex,
        age          = input$age,
        condition    = input$condition,
        tissue       = input$tissue,
        project      = input$project,
        researcher   = input$researcher,
        date         = as.character(input$date),
        notes        = input$notes,
        parent_id    = parent_id_val,
        rds_parent   = if (nchar(trimws(input$rds_parent)) > 0) trimws(input$rds_parent) else "root",
        lineage      = lineage_val,
        children     = children_val,
        rds_children = rds_children_val,
        custom_keys  = ckeys,
        custom_vals  = cvals
      )

      seurat_obj@misc$passport <- passport
      shiny::stopApp(seurat_obj)
    })

    shiny::observeEvent(input$cancel, {
      message("Cancelled — original object returned unchanged")
      shiny::stopApp(seurat_obj)
    })
  }

  # ---- RUN with safety net ----
  result <- tryCatch(
    shiny::runGadget(ui, server,
                     viewer = shiny::dialogViewer("Seurat Passport", width = 600, height = 850)),
    error = function(e) {
      message("Gadget error: ", e$message, " — original object returned unchanged")
      return(seurat_obj)
    }
  )

  if (is.null(result)) {
    message("Returned NULL — original object returned unchanged")
    return(seurat_obj)
  }

  return(result)
}
