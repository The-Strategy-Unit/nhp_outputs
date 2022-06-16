library(mockery)

test_that("ui is created correctly", {
  stub(app_ui, "mod_result_selection_ui", "result_selection")
  stub(app_ui, "mod_params_upload_ui", "params_upload_ui")
  stub(app_ui, "mod_running_models_ui", "running_models")
  stub(app_ui, "mod_principal_high_level_ui", "principal_high_level")
  stub(app_ui, "mod_principal_detailed_ui", "principal_detailed")
  stub(app_ui, "mod_principal_change_factor_effects_ui", "principal_change_factor_effects")
  stub(app_ui, "mod_model_core_activity_ui", "model_core_activity")
  stub(app_ui, "mod_model_results_distribution_ui", "model_results_distribution")
  stub(app_ui, "mod_capacity_beds_ui", "capacity_beds")
  expect_snapshot(app_ui())
})
