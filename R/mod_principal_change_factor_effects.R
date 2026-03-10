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
      md_file_to_html("app", "text", "notes-beddays.md"),
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
        mod_measure_selection_ui(ns("measure_selection"), width = 4)
      )
    ),
    bs4Dash::box(
      title = "Impact of changes",
      collapsible = FALSE,
      width = 12,
      shiny::checkboxInput(ns("include_baseline"), "Include baseline?", TRUE),
      shinycssloaders::withSpinner(
        shiny::plotOutput(ns("change_factors"), height = "600px")
      )
    ),
    bs4Dash::box(
      title = "Individual change factors",
      collapsible = FALSE,
      width = 12,
      shiny::selectInput(
        ns("sort_type"),
        "Sort By",
        c("Descending value" = "value", "Alphabetical" = "tpma_label")
      ),
      shinycssloaders::withSpinner(
        shiny::fluidRow(
          shiny::plotOutput(
            ns("individual_change_factors"),
            height = "1200px"
          )
        )
      )
    )
  )
}

#' principal_change_factor_effects Server Functions
#'
#' @noRd
mod_principal_change_factor_effects_server <- function(
  id,
  selected_data,
  selected_site
) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    output$change_factors <- shiny::renderPlot({
      shiny::req(selected_measure())

      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_change_factor_data(
          measure = selected_measure()$measure,
          activity_type = selected_measure()$activity_type,
          pods = selected_measure()$pods,
          sites = selected_site(),
          include_baseline = input$include_baseline
        ) |>
        require_rows() |>
        reskit::make_overall_cf_plot()
    })

    output$individual_change_factors <- shiny::renderPlot({
      shiny::req(selected_measure())

      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_indiv_change_factor_data(
          measure = selected_measure()$measure,
          activity_type = selected_measure()$activity_type,
          pods = selected_measure()$pods,
          sites = selected_site(),
          sort_by = input$sort_type
        ) |>
        require_rows() |>
        reskit::make_individual_cf_plot(
          x_axis_label = selected_measure()$measure
        )
    })
  })
}
