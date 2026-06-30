#' info_home UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_home_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("NHP Model Results"),
    shiny::fluidRow(
      bs4Dash::column(
        width = 6,
        bs4Dash::box(
          title = "About",
          collapsible = FALSE,
          width = 12,
          md_file_to_html("app", "text", "home_about.md")
        ),
        bs4Dash::box(
          title = "App notes",
          collapsible = FALSE,
          width = 12,
          md_file_to_html("app", "text", "home_app-notes.md")
        )
      ),
      bs4Dash::column(
        width = 6,
        bs4Dash::box(
          title = "Model run information",
          collapsible = FALSE,
          width = 12,
          htmltools::p(
            "This is a reminder of the metadata for the model run you selected."
          ),
          shinycssloaders::withSpinner(
            shiny::htmlOutput(ns("params_model_run"))
          )
        )
      )
    )
  )
}
