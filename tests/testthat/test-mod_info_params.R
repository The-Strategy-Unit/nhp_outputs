library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(1)
  expect_snapshot(mod_info_params_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls get_params correctly", {
  selected_data <- shiny::reactiveVal("data")

  m <- mock("params_data")

  stub(mod_info_params_server, "get_params", m)

  stub(
    mod_info_params_server,
    "info_params_table_demographic_adjustment",
    "demographic_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_baseline_adjustment",
    "baseline_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_covid_adjustment",
    "covid_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_waiting_list_adjustment",
    "waiting_list_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_expat_repat_adjustment",
    "expat_repat_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_non_demographic_adjustment",
    "non_demographic_adjustment"
  )
  stub(
    mod_info_params_server,
    "info_params_table_activity_avoidance",
    "activity_avoidance"
  )
  stub(mod_info_params_server, "info_params_table_efficiencies", "efficiencies")

  testServer(
    mod_info_params_server,
    args = list(selected_data = selected_data),
    {
      expect_equal(params_data(), "params_data")
      expect_called(m, 1)
      expect_args(m, 1, "data")
    }
  )
})

test_that("outputs are set correctly", {
  expected_data <- list(
    time_profile_mappings = list(
      "waiting_list_adjustment" = "linear",
      "expat" = "linear",
      "repat_local" = "linear",
      "repat_nonlocal" = "linear"
    )
  )
  selected_data <- shiny::reactiveVal()

  m <- mock()

  stub(mod_info_params_server, "get_params", expected_data)

  stub(mod_info_params_server, "info_params_table_demographic_adjustment", m)
  stub(mod_info_params_server, "info_params_table_baseline_adjustment", m)
  stub(mod_info_params_server, "info_params_table_covid_adjustment", m)
  stub(mod_info_params_server, "info_params_table_waiting_list_adjustment", m)
  stub(mod_info_params_server, "info_params_table_expat_repat_adjustment", m)
  stub(
    mod_info_params_server,
    "info_params_table_non_demographic_adjustment",
    m
  )
  stub(mod_info_params_server, "info_params_table_activity_avoidance", m)
  stub(mod_info_params_server, "info_params_table_efficiencies", m)

  testServer(
    mod_info_params_server,
    args = list(selected_data = selected_data),
    {
      session$private$flush()
      expect_equal(output$time_profile_waiting_list_adjustment, "linear")
      expect_equal(output$time_profile_expat, "linear")
      expect_equal(output$time_profile_repat_local, "linear")
      expect_equal(output$time_profile_repat_nonlocal, "linear")

      expect_called(m, 10)
      expect_args(m, 1, expected_data)
      expect_args(m, 2, expected_data)
      expect_args(m, 3, expected_data)
      expect_args(m, 4, expected_data)
      expect_args(m, 5, expected_data, "expat")
      expect_args(m, 6, expected_data, "repat_local")
      expect_args(m, 7, expected_data, "repat_nonlocal")
      expect_args(m, 8, expected_data)
      expect_args(m, 9, expected_data)
      expect_args(m, 10, expected_data)
    }
  )
})
