#' principal_detailed UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_detailed_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity in detail"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes_beddays.md")
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        mod_measure_selection_ui(ns("measure_selection"), width = 3),
        col_3(shiny::selectInput(ns("aggregation"), "Show Results By", NULL))
      )
    ),
    bs4Dash::box(
      title = "Activity by sex and age or treatment specialty",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        shiny::htmlOutput(ns("results"))
      )
    )
  )
}
