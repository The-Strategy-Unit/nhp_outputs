#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      selected_data()[["results"]] |>
        reskit::compile_principal_pod_data(
          sites = selected_site(),
          pod_lookup = reskit::get_principal_pods()
        )
    })

    output$summary_table <- gt::render_gt({
      summary_data() |>
        reskit::make_principal_pod_table()
    })
  })
}
