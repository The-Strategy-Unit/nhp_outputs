#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @noRd
app_server <- function(input, output, session) {
  user_allowed_datasets <- shiny::reactive({
    cosmos_get_user_allowed_datasets(session$user)
  })

  # this module returns a reactive which contains the data path
  selected_model_run <- mod_result_selection_server("result_selection", user_allowed_datasets)
  selected_model_run_id <- shiny::reactive({
    selected_model_run()$id
  })

  mod_params_upload_server("params_upload", user_allowed_datasets)
  mod_running_models_server("running_models")

  mod_principal_summary_server("principal_summary", selected_model_run_id)
  mod_principal_high_level_server("principal_high_level", selected_model_run_id)
  mod_principal_detailed_server("principal_detailed", selected_model_run_id)
  mod_principal_change_factor_effects_server("principal_change_factor_effects", selected_model_run_id)
  mod_principal_capacity_requirements_server("principal_capacity_requirements", selected_model_run_id)

  mod_model_core_activity_server("model_core_activity", selected_model_run_id)
  mod_model_results_distribution_server("model_results_distribution", selected_model_run_id)
  mod_model_results_capacity_server("model_results_capacity", selected_model_run_id)
}
