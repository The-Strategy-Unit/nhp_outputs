#' principal_summary UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_summary_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: summary"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      "noot noot",
      md_file_to_html("app", "text", "notes_beddays.md"),
      htmltools::p("Bed-availability data is not available at site level.")
    ),
    bs4Dash::box(
      title = "Summary by point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        shiny::htmlOutput(ns("summary_table"))
      )
    )
  )
}
