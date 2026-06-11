#' principal_change_factor_effects UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_change_factor_effects_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: impact of changes"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes_beddays.md"),
      htmltools::p(
        "Regard these results as rough, high-level estimates of the number of",
        "rows added/removed due to each parameter."
      )
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        col_4(shiny::selectInput(ns("activity_type"), "Activity Type", NULL)),
        col_4(shiny::selectInput(
          ns("pods"),
          "Point of Delivery",
          NULL,
          multiple = TRUE
        )),
        col_4(shiny::selectInput(ns("measure"), "Measure", NULL))
      )
    ),
    bs4Dash::box(
      title = "Impact of changes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "principal_impact_waterfall.md"),
      shiny::checkboxInput(ns("include_baseline"), "Include baseline?", TRUE),
      shinycssloaders::withSpinner(
        shiny::plotOutput(ns("change_factors"), height = "600px")
      )
    ),
    bs4Dash::box(
      title = "Individual change factors",
      collapsible = FALSE,
      width = 12,
      md_file_to_html(
        "app",
        "text",
        "principal_impact_individual-change-factors.md"
      ),
      shiny::selectInput(
        ns("sort_type"),
        "Sort By",
        c("Descending value" = "value", "Alphabetical" = "tpma_label")
      ),
      shinycssloaders::withSpinner(
        shiny::fluidRow(
          shiny::plotOutput(ns("individual_change_factors"), height = "1200px")
        )
      )
    )
  )
}
