library(shiny)
library(mockery)

test_that("it loads the module correctly: mod_model_core_activity_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", m)
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_core_activity", selected_model_run, selected_site)
  })
})

test_that("it loads the module correctly: mod_model_results_capacity_server", {
  m <- mock()

  stub(app_server, "mod_capacity_beds_server", "mod_capacity_beds_server")
  stub(app_server, "mod_model_results_capacity_server", m)
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_results_capacity", selected_model_run)
  })
})

test_that("it loads the module correctly: mod_model_results_distribution_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", m)
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_results_distribution", selected_model_run, selected_site)
  })
})

test_that("it loads the module correctly: mod_params_upload_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", m)
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "params_upload", user_allowed_datasets)
  })
})

test_that("it loads the module correctly: mod_principal_capacity_requirements_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", m)
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_capacity_requirements", selected_model_run)
  })
})

test_that("it loads the module correctly: mod_principal_change_factor_effects_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", m)
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_change_factor_effects", selected_model_run)
  })
})

test_that("it loads the module correctly: mod_principal_detailed_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", m)
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_detailed", selected_model_run, selected_site)
  })
})

test_that("it loads the module correctly: mod_principal_high_level_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", m)
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_high_level", selected_model_run, selected_site)
  })
})

test_that("it loads the module correctly: mod_principal_summary_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", m)
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_summary", selected_model_run, selected_site)
  })
})

test_that("it loads the module correctly: mod_result_selection_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", m)
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "result_selection", user_allowed_datasets)
  })
})

test_that("it loads the module correctly: mod_running_models_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")
  stub(app_server, "mod_running_models_server", m)

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "running_models")
  })
})

test_that("it gets the list of allowed datasets for the current user", {
  m <- mock("synthetic")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  stub(app_server, "cosmos_get_user_allowed_datasets", m)

  testServer(app_server, {
    expect_equal(user_allowed_datasets(), "synthetic")
    expect_called(m, 1)
    expect_args(m, 1, session$user)
  })
})

test_that("it sets up the selected_model_run reactive correctly", {
  m <- mock(\() list(id = 1))

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_params_upload_server", "mod_params_upload_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")
  stub(app_server, "mod_running_models_server", "mod_running_models_server")

  stub(app_server, "mod_result_selection_server", m)

  testServer(app_server, {
    expect_equal(selected_model_run(), 1)
  })
})
