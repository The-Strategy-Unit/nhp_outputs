#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    output$summary_table <- gt::render_gt({
      selected_data()[["results"]] |>
        reskit::compile_principal_pod_data(
          pod_lookup = get_condensed_pod_lookup(),
          sites = selected_site()
        ) |>
        reskit::make_principal_pod_table()
    })
  })
}
