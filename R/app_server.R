#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
app_server <- function(input, output, session) {
  # this module returns a reactive which contains the data path
  selected_results <- mod_result_selection_server("result_selection")
  selected_data <- shiny::reactive({
    selected_results()$data
  })
  selected_site <- shiny::reactive({
    selected_results()$site
  })

  mod_principal_summary_server("principal_summary", selected_data, selected_site)
  mod_principal_high_level_server("principal_high_level", selected_data, selected_site)
  mod_principal_detailed_server("principal_detailed", selected_data, selected_site)
  mod_principal_change_factor_effects_server("principal_change_factor_effects", selected_data)
  mod_principal_capacity_requirements_server("principal_capacity_requirements", selected_data)

  mod_model_core_activity_server("model_core_activity", selected_data, selected_site)
  mod_model_results_distribution_server("model_results_distribution", selected_data, selected_site)
  mod_model_results_capacity_server("model_results_capacity", selected_data)

  if (!getOption("golem.app.prod", FALSE)) {
    session$allowReconnect("force")
  }

  shiny::observe({
    shiny::req("nhp_devs" %in% session$groups)

    u <- shiny::parseQueryString(session$clientData$url_search)

    shiny::req(!is.null(u$reset_cache))
    cat("reset cache\n")

    dc <- shiny::shinyOptions()$cache

    dc$reset()
  })
}
