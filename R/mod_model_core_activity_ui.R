#' model_core_activity UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_core_activity_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Distribution of projections: activity distribution summary"),
    shiny::fluidRow(
      col_3(),
      bs4Dash::box(
        title = "Notes",
        collapsible = FALSE,
        width = 12,
        md_file_to_html("app", "text", "notes_beddays.md")
      ),
      bs4Dash::box(
        title = "Summary by activity type and measure",
        collapsible = FALSE,
        width = 12,
        bs4Dash::tabsetPanel(
          shiny::tabPanel(
            "Median",
            shinycssloaders::withSpinner(
              shiny::htmlOutput(ns("core_activity_median"))
            )
          ),
          shiny::tabPanel(
            "Principal",
            shinycssloaders::withSpinner(
              shiny::htmlOutput(ns("core_activity_principal"))
            )
          )
        )
      ),
      col_3()
    )
  )
}
