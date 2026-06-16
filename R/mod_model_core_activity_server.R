#' model_core_activity Server Functions
#'
#' @noRd
mod_model_core_activity_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    output$core_activity_median <- gt::render_gt({
      selected_data()[["results"]] |>
        reskit::compile_distribution_summary_data(
          value_type = "median",
          sites = selected_site(),
          pod_lookup = get_pod_lookup()
        ) |>
        reskit::make_distribution_summary_table()
    })

    output$core_activity_principal <- gt::render_gt({
      selected_data()[["results"]] |>
        reskit::compile_distribution_summary_data(
          value_type = "principal",
          sites = selected_site(),
          pod_lookup = get_pod_lookup()
        ) |>
        reskit::make_distribution_summary_table()
    })
  })
}
