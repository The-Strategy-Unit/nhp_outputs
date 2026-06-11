#' info_downloads UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_downloads_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Information: downloads"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Notes",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "These files will download one at a time and may take a moment to be generated."
        )
      ),
      bs4Dash::box(
        title = "Download results data",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing results data for the selected model run.",
          "The data is provided for each site and for the overall trust level.",
          "See details of the content on",
          htmltools::a(
            href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/results.html",
            "the project information site."
          )
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_results_xlsx"),
            "Download results (.xlsx)"
          )
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_results_json"),
            "Download results (.json)"
          )
        )
      ),
      bs4Dash::box(
        title = "Download parameters report (Extract A)",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing the input parameters for",
          "the selected model run."
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_report_parameters_html"),
            "Download parameters report (.html)"
          )
        )
      ),
      bs4Dash::box(
        title = "Download summary outputs report (Extract B)",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Download a file containing the outputs (charts and tables) for the",
          "selected model run and selected sites. This will take a moment."
        ),
        shinyjs::disabled(
          shiny::downloadButton(
            ns("download_report_outputs_html"),
            "Download outputs report (.html)"
          )
        )
      )
    )
  )
}
