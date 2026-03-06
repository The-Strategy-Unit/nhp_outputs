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
        md_file_to_html("app", "text", "notes-beddays.md")
      ),
      bs4Dash::box(
        title = "Summary by activity type and measure",
        collapsible = FALSE,
        width = 12,
        bs4Dash::tabsetPanel(
          shiny::tabPanel(
            "Median",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("core_activity_median"))
            )
          ),
          shiny::tabPanel(
            "Principal",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("core_activity_principal"))
            )
          )
        )
      ),
      col_3()
    )
  )
}

#' model_core_activity Server Functions
#'
#' @noRd
mod_model_core_activity_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    output$core_activity_median <- gt::render_gt({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_distribution_summary_data(
          value_type = "median",
          sites = selected_site()
        ) |>
        reskit::make_distribution_summary_table()
    })

    output$core_activity_principal <- gt::render_gt({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_distribution_summary_data(
          value_type = "principal",
          sites = selected_site()
        ) |>
        reskit::make_distribution_summary_table()
    })
  })
}
