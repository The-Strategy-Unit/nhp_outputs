library(shiny)
library(mockery)

test_that("it loads the module correctly: mod_model_core_activity_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", m)
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_core_activity", selected_data, selected_site)
  })
})

test_that("it loads the module correctly: mod_model_results_capacity_server", {
  m <- mock()

  stub(app_server, "mod_capacity_beds_server", "mod_capacity_beds_server")
  stub(app_server, "mod_model_results_capacity_server", m)
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_results_capacity", selected_data)
  })
})

test_that("it loads the module correctly: mod_model_results_distribution_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", m)
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "model_results_distribution", selected_data, selected_site)
  })
})

test_that("it loads the module correctly: mod_principal_capacity_requirements_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", m)
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_capacity_requirements", selected_data)
  })
})

test_that("it loads the module correctly: mod_principal_change_factor_effects_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", m)
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_change_factor_effects", selected_data)
  })
})

test_that("it loads the module correctly: mod_principal_detailed_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", m)
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_detailed", selected_data, selected_site)
  })
})

test_that("it loads the module correctly: mod_principal_high_level_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", m)
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_high_level", selected_data, selected_site)
  })
})

test_that("it loads the module correctly: mod_principal_summary_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", m)
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "principal_summary", selected_data, selected_site)
  })
})

test_that("it loads the module correctly: mod_result_selection_server", {
  m <- mock()

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", m)

  testServer(app_server, {
    expect_called(m, 1)
    expect_args(m, 1, "result_selection")
  })
})

test_that("it sets up the selected_data/site reactives correctly", {
  m <- mock(\() list(data = "data", site = "site"))

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_capacity_server", "mod_model_results_capacity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")
  stub(app_server, "mod_principal_capacity_requirements_server", "mod_principal_capacity_requirements_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_result_selection_server", "mod_result_selection_server")

  stub(app_server, "mod_result_selection_server", m)

  testServer(app_server, {
    expect_equal(selected_data(), "data")
    expect_equal(selected_site(), "site")
  })
})
