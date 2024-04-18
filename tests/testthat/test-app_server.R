library(shiny)
library(mockery)

test_that("it loads the modules correctly", {
  m <- mock()

  stub(app_server, "server_get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", m)

  stub(app_server, "mod_principal_summary_server", m)
  stub(app_server, "mod_principal_change_factor_effects_server", m)
  stub(app_server, "mod_principal_high_level_server", m)
  stub(app_server, "mod_principal_detailed_server", m)

  stub(app_server, "mod_model_core_activity_server", m)
  stub(app_server, "mod_model_results_distribution_server", m)

  stub(app_server, "mod_info_downloads_server", m)
  stub(app_server, "mod_info_params_server", m)

  testServer(app_server, {
    expect_called(m, 9)
    expect_args(m, 1, "home", selected_data)

    expect_args(m, 2, "principal_summary", selected_data, selected_site)
    expect_args(m, 3, "principal_change_factor_effects", selected_data, selected_site)
    expect_args(m, 4, "principal_high_level", selected_data, selected_site)
    expect_args(m, 5, "principal_detailed", selected_data, selected_site)

    expect_args(m, 6, "model_core_activity", selected_data, selected_site)
    expect_args(m, 7, "model_results_distribution", selected_data, selected_site)

    expect_args(m, 8, "info_downloads", selected_data, selected_site)
    expect_args(m, 9, "info_params", selected_data)
  })
})

test_that("selected_data calls server_get_results", {
  m <- mock("results")

  stub(app_server, "server_get_results", m)
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  testServer(app_server, {
    expect_equal(selected_data(), "results")

    expect_called(m, 1)
    expect_call(m, 1, server_get_results(session))
  })
})

test_that("if server_get_results errors the app exits", {
  m <- mock()

  stub(app_server, "server_get_results", \(...) stop("error occured"))
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  stub(app_server, "shiny::showModal", m)

  testServer(app_server, {
    selected_data()

    expect_called(m, 1)

    expect_snapshot(mock_args(m)[[1]][[1]])
    expect_true(session$isClosed())
  })
})

test_that("selected_site uses the inputs values", {
  stub(app_server, "server_get_results", "results")
  stub(app_server, "get_trust_sites", "trust_sites")

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  testServer(app_server, {
    session$setInputs("site_selection" = "a")

    expect_equal(selected_site(), "a")
  })
})

test_that("it gets the trust sites from the results", {
  m <- mock("trust_sites")

  stub(app_server, "server_get_results", "results")
  stub(app_server, "get_results", "results")
  stub(app_server, "get_trust_sites", m)

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  testServer(app_server, {
    expect_equal(trust_sites(), "trust_sites")

    expect_called(m, 1)
    expect_args(m, 1, "results")
  })
})

test_that("it updates the site selection drop down", {
  m <- mock()

  stub(app_server, "server_get_results", "results")
  stub(app_server, "get_trust_sites", c("a", "b", "c"))

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

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
  stub(app_server, "server_get_results", "results")
  stub(app_server, "get_trust_sites", c("a", "b", "c"))

  stub(app_server, "mod_info_home_server", "mod_info_home_server")

  stub(app_server, "mod_principal_summary_server", "mod_principal_summary_server")
  stub(app_server, "mod_principal_change_factor_effects_server", "mod_principal_change_factor_effects_server")
  stub(app_server, "mod_principal_high_level_server", "mod_principal_high_level_server")
  stub(app_server, "mod_principal_detailed_server", "mod_principal_detailed_server")

  stub(app_server, "mod_model_core_activity_server", "mod_model_core_activity_server")
  stub(app_server, "mod_model_results_distribution_server", "mod_model_results_distribution_server")

  stub(app_server, "mod_info_downloads_server", "mod_info_downloads_server")
  stub(app_server, "mod_info_params_server", "mod_info_params_server")

  m <- mock()
  stub(app_server, "user_requested_cache_reset", TRUE)
  stub(app_server, "shiny::shinyOptions", \() list(cache = list(reset = m)))

  testServer(app_server, {
    session$private$flush()
    expect_called(m, 1)
  })
})
