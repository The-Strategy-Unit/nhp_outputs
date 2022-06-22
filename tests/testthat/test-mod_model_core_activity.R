library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance"
)

model_core_activity_expected <- tibble::tribble(
  ~pod, ~measure, ~baseline, ~median, ~lwr_ci, ~upr_ci,
  "aae_type-01", "ambulance", 30000, 35000, 34000, 36000
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_model_core_activity_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_model_core_activity_server_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- model_core_activity_expected |>
    dplyr::inner_join(atpmo_expected, by = c("pod", "measure" = "measures")) |>
    mod_model_core_activity_server_table()

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it gets the activity type/pod/measure reference data", {
  m <- mock(atpmo_expected)
  stub(mod_model_core_activity_server, "get_activity_type_pod_measure_options", m)

  selected_model_run_id <- reactiveVal()

  shiny::testServer(mod_model_core_activity_server, args = list(selected_model_run_id), {
    expect_called(m, 1)
    expect_equal(atpmo, atpmo_expected)
  })
})

test_that("it calls cosmos_get_model_core_activity", {
  m <- mock(model_core_activity_expected)
  stub(mod_model_core_activity_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_model_core_activity_server, "cosmos_get_model_core_activity", m)

  selected_model_run_id <- reactiveVal()

  shiny::testServer(mod_model_core_activity_server, args = list(selected_model_run_id), {
    selected_model_run_id("id")

    expected <- model_core_activity_expected |>
      dplyr::inner_join(atpmo_expected, by = c("pod", "measure" = "measures"))
    expect_equal(summarised_data(), expected)

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it renders the table", {
  m <- mock()

  stub(mod_model_core_activity_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_model_core_activity_server, "cosmos_get_model_core_activity", model_core_activity_expected)
  stub(mod_model_core_activity_server, "mod_model_core_activity_server_table", "table")
  stub(mod_model_core_activity_server, "gt::render_gt", m)

  selected_model_run_id <- reactiveVal()

  shiny::testServer(mod_model_core_activity_server, args = list(selected_model_run_id), {
    selected_model_run_id("id")

    expect_called(m, 1)
    expect_args(m, 1, "table")
  })
})
