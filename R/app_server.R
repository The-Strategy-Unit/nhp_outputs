#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
app_server <- function(input, output, session) {
  data_cache <- get_data_cache()

  user_allowed_datasets <- reactive({
    cosmos_get_user_allowed_datasets(session$user)
  })

  # this module returns a reactive which contains the data path
  selected_model_run <- mod_result_selection_server("result_selection", user_allowed_datasets)
  selected_model_run_id <- reactive({
    selected_model_run()$id
  })

  mod_params_upload_server("params_upload_ui", user_allowed_datasets)
  mod_running_models_server("running_models")

  mod_principal_high_level_server("principal_high_level", selected_model_run_id, data_cache)
  mod_principal_detailed_server("principal_detailed", selected_model_run_id, data_cache)
  mod_principal_change_factor_effects_server("principal_change_factor_effects", selected_model_run_id, data_cache)

  mod_model_core_activity_server("model_core_activity", selected_model_run_id, data_cache)
  mod_model_results_distribution_server("model_results_distribution", selected_model_run_id, data_cache)

  mod_capacity_beds_server("capacity_beds", selected_model_run, data_cache)
}
