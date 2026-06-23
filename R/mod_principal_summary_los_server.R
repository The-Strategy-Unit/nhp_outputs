#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_los_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    output$summary_los_table_beddays <- gt::render_gt({
      selected_data()[["results"]] |>
        reskit::compile_principal_los_data(
          measure = "beddays",
          sites = selected_site(),
          pod_lookup = get_pod_lookup()
        ) |>
        require_rows() |>
        reskit::make_principal_los_table()
    })

    output$summary_los_table_admissions <- gt::render_gt({
      selected_data()[["results"]] |>
        reskit::compile_principal_los_data(
          measure = "admissions",
          sites = selected_site(),
          pod_lookup = get_pod_lookup()
        ) |>
        require_rows() |>
        reskit::make_principal_los_table()
    })
  })
}
