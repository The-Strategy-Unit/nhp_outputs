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
      md_file_to_html("app", "text", "notes-beddays.md"),
      htmltools::p("Bed-availability data is not available at site level.")
    ),
    bs4Dash::box(
      title = "Summary by point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_table"))
      )
    )
  )
}

#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_principal_pod_data(sites = selected_site())
    })

    output$summary_table <- gt::render_gt({
      summary_data() |>
        reskit::make_principal_pod_table()
    })
  })
}
