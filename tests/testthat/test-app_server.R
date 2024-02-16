library(shiny)
library(mockery)

test_that("it loads the modules correctly", {
  m <- mock()

  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", m)
  stub(app_server, "mod_info_params_server", m)

  stub(app_server, "mod_principal_summary_server", m)
  stub(app_server, "mod_principal_change_factor_effects_server", m)
  stub(app_server, "mod_principal_high_level_server", m)
  stub(app_server, "mod_principal_detailed_server", m)

  stub(app_server, "mod_model_core_activity_server", m)
  stub(app_server, "mod_model_results_distribution_server", m)

  testServer(app_server, {
    expect_called(m, 8)
    expect_args(m, 1, "home", selected_data)
    expect_args(m, 2, "info_params", selected_data)

    expect_args(m, 3, "principal_summary", selected_data, selected_site)
    expect_args(m, 4, "principal_change_factor_effects", selected_data)
    expect_args(m, 5, "principal_high_level", selected_data, selected_site)
    expect_args(m, 6, "principal_detailed", selected_data, selected_site)

    expect_args(m, 7, "model_core_activity", selected_data, selected_site)
    expect_args(m, 8, "model_results_distribution", selected_data, selected_site)
  })
})

test_that("it gets the selected file from the url", {
  m <- mock("file")

  stub(app_server, "get_selected_file_from_url", m)
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  testServer(app_server, {
    expect_equal(selected_file(), "file")

    expect_called(m, 1)
    expect_call(m, 1, get_selected_file_from_url(session))
  })
})

test_that("if file isn't entered/valid it exits the app", {
  m <- mock()

  stub(app_server, "get_selected_file_from_url", NULL)
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "shiny::showModal", m)

  testServer(app_server, {
    expect_error(selected_file())

    session$private$flush()
    expect_called(m, 1)

    expect_snapshot(mock_args(m)[[1]][[1]])
    expect_true(session$isClosed())
  })
})

test_that("it gets the results from the selected file", {
  m <- mock("results")

  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", m)
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  testServer(app_server, {
    expect_equal(selected_data(), "results")

    expect_called(m, 1)
    expect_args(m, 1, "file")
  })
})


test_that("it file can't be loaded from azure it exits the app", {
  m <- mock()

  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", stop)
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "shiny::showModal", m)

  testServer(app_server, {
    expect_error(selected_data())

    session$private$flush()
    expect_called(m, 1)

    expect_snapshot(mock_args(m)[[1]][[1]])
    expect_true(session$isClosed())
  })
})

test_that("selected_site uses the inputs values", {
  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  testServer(app_server, {
    session$setInputs("site_selection" = "a")

    expect_equal(selected_site(), "a")
  })
})

test_that("it gets the trust sites from the results", {
  m <- mock("trust_sites")

  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", m)

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  testServer(app_server, {
    expect_equal(trust_sites(), "trust_sites")

    expect_called(m, 1)
    expect_args(m, 1, "results")
  })
})

test_that("it updates the site selection drop down", {
  m <- mock()

  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", c("a", "b", "c"))

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "jsonlite::read_json", list("a" = "A", "b" = "B"))
  stub(app_server, "shiny::updateSelectInput", m)

  session <- MockShinySession$new()
  testServer(app_server, session = session, {
    session$private$flush()

    expect_called(m, 1)
    expect_args(
      m, 1, session, "site_selection",
      choices = c(
        "A (a)" = "a",
        "B (b)" = "b",
        "Unknown (c)" = "c"
      )
    )
  })
})

test_that("it can reset the cache", {
  stub(app_server, "get_selected_file_from_url", "file")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", c("a", "b", "c"))

  stub(app_server, "mod_info_home_server", "mod_info_home_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  m <- mock()
  stub(app_server, "user_requested_cache_reset", TRUE)
  stub(app_server, "shiny::shinyOptions", \() list(cache = list(reset = m)))

  testServer(app_server, {
    session$private$flush()
    expect_called(m, 1)
  })
})
