#' info_params Server Functions
#'
#' @noRd
mod_info_params_server <- function(id, selected_data) {
  shiny::moduleServer(id, function(input, output, session) {
    params_data <- shiny::reactive({
      get_params(selected_data())
    })

    # params

    output$params_demographic_factors <- gt::render_gt({
      info_params_table_demographic_adjustment(params_data())
    })

    output$params_baseline_adjustment <- gt::render_gt({
      info_params_table_baseline_adjustment(params_data())
    })

    output$params_waiting_list_adjustment <- gt::render_gt({
      info_params_table_waiting_list_adjustment(params_data())
    })

    output$params_inequalities <- gt::render_gt({
      info_params_table_inequalities(params_data())
    })

    output$params_expat <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "expat")
    })

    output$params_repat_local <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "repat_local")
    })

    output$params_repat_nonlocal <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "repat_nonlocal")
    })

    output$params_non_demographic_adjustment <- gt::render_gt({
      info_params_table_non_demographic_adjustment(params_data())
    })

    output$params_activity_avoidance <- gt::render_gt({
      info_params_table_activity_avoidance(params_data())
    })

    output$params_efficiencies <- gt::render_gt({
      info_params_table_efficiencies(params_data())
    })

    # NDG

    output$variant_non_demographic_adjustment <- shiny::renderText({
      params_data()[["non-demographic_adjustment"]][["variant"]]
    })

    output$value_type_non_demographic_adjustment <- shiny::renderText({
      params_data()[["non-demographic_adjustment"]][["value-type"]]
    })
  })
}
