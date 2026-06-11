#' model_results_distribution UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_results_distribution_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h1("Distribution of projections: activity distribution"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html(
        "app",
        "text",
        "distribution_activity-distribution_notes.md"
      ),
      md_file_to_html("app", "text", "notes_beddays.md")
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(mod_measure_selection_ui(ns("measure_selection"), 4)),
      shiny::checkboxInput(ns("show_origin"), "Show Origin (zero)?")
    ),
    bs4Dash::box(
      title = "Beeswarm (model-run distribution)",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "distribution_beeswarm.md"),
      shiny::htmlOutput(ns("beeswarm_text")),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("beeswarm"), height = "400px")
      )
    ),
    bs4Dash::box(
      title = "S-curve (empirical cumulative distribution function)",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "distribution_s-curve.md"),
      shiny::htmlOutput(ns("ecdf_text")),
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("ecdf"), height = "400px")
      )
    )
  )
}
