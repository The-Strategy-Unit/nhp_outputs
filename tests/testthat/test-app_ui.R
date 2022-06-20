library(shiny)
library(mockery)

test_that("ui is created correctly", {
  m <- mock(
    "result_selection",
    "params_upload",
    "running_models",
    "principal_high_level",
    "principal_detailed",
    "principal_change_factor_effects",
    "model_core_activity",
    "model_results_distribution",
    "capacity_beds"
  )

  stub(app_ui, "mod_result_selection_ui", m)
  stub(app_ui, "mod_params_upload_ui", m)
  stub(app_ui, "mod_running_models_ui", m)
  stub(app_ui, "mod_principal_high_level_ui", m)
  stub(app_ui, "mod_principal_detailed_ui", m)
  stub(app_ui, "mod_principal_change_factor_effects_ui", m)
  stub(app_ui, "mod_model_core_activity_ui", m)
  stub(app_ui, "mod_model_results_distribution_ui", m)
  stub(app_ui, "mod_capacity_beds_ui", m)

  expect_snapshot(app_ui())

  expect_called(m, 9)
  expect_args(m, 1, "result_selection")
  expect_args(m, 2, "params_upload")
  expect_args(m, 3, "running_models")
  expect_args(m, 4, "principal_high_level")
  expect_args(m, 5, "principal_detailed")
  expect_args(m, 6, "principal_change_factor_effects")
  expect_args(m, 7, "model_core_activity")
  expect_args(m, 8, "model_results_distribution")
  expect_args(m, 9, "capacity_beds")
})
