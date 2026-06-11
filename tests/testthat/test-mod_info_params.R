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
