library(mockery)

test_that("server loads modules correctly", {
  m <- mock()

  stub(app_server, "get_data_cache", "data_cache")

  stub(app_server, "mod_result_selection_server", m)

  stub(app_server, "mod_params_upload_server", m)
  stub(app_server, "mod_running_models_server", m)

  stub(app_server, "mod_principal_high_level_server", m)
  stub(app_server, "mod_principal_detailed_server", m)
  stub(app_server, "mod_principal_change_factor_effects_server", m)

  stub(app_server, "mod_model_core_activity_server", m)
  stub(app_server, "mod_model_results_distribution_server", m)

  stub(app_server, "mod_capacity_beds_server", m)

  testServer(app_server, {
    expect_equal(data_cache, "data_cache")

    expect_called(m, 9)
    expect_args(m, 1, "result_selection", user_allowed_datasets)

    expect_args(m, 2, "params_upload_ui", user_allowed_datasets)
    expect_args(m, 3, "running_models")

    expect_args(m, 4, "principal_high_level", selected_model_run_id, data_cache)
    expect_args(m, 5, "principal_detailed", selected_model_run_id, data_cache)
    expect_args(m, 6, "principal_change_factor_effects", selected_model_run_id, data_cache)

    expect_args(m, 7, "model_core_activity", selected_model_run_id, data_cache)
    expect_args(m, 8, "model_results_distribution", selected_model_run_id, data_cache)

    expect_args(m, 9, "capacity_beds", selected_model_run, data_cache)
  })
})

test_that("it gets the list of allowed datasets for the current user", {
  m <- mock("synthetic")
  stub(app_server, "get_data_cache", "data_cache")

  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_capacity_beds_server", "mod_capacity_beds_server")

  stub(app_server, "cosmos_get_user_allowed_datasets", m)

  testServer(app_server, {
    expect_equal(user_allowed_datasets(), "synthetic")
    expect_called(m, 1)
    expect_args(m, 1, session$user)
  })
})

test_that("it sets up the selected_model_run_id reactive correctly", {
  m <- mock(\() list(id = 1))
  stub(app_server, "get_data_cache", "data_cache")

  stub(app_server, "mod_result_selection_server", m)

  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_capacity_beds_server", "mod_capacity_beds_server")

  testServer(app_server, {
    expect_equal(selected_model_run_id(), 1)
  })
})
