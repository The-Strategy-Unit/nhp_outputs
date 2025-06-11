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
  ~pod, ~measure, ~baseline, ~median, ~lwr_pi, ~upr_pi,
  "aae_type-01", "ambulance", 30000, 35000, 34000, 36000
)

model_core_activity_principal_expected <- tibble::tribble(
  ~pod, ~measure, ~baseline, ~principal, ~lwr_pi, ~upr_pi,
  "aae_type-01", "ambulance", 30000, 35000, 34000, 36000
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)

  # requires hack because the gt id can't be controlled
  ui <- mod_model_core_activity_ui("id") |>
    as.character() |>
    stringr::str_replace_all(" data-tabsetid=\"\\d+\"", "") |>
    stringr::str_replace_all("#?tab-\\d+-\\d+", "")

  expect_snapshot(ui)
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_model_core_activity_server_table returns a gt for median data", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- model_core_activity_expected |>
    dplyr::inner_join(atpmo_expected, by = c("pod", "measure" = "measures")) |>
    mod_model_core_activity_server_table(value_type = "median")

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

test_that("mod_model_core_activity_server_table returns a gt for principal data", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- model_core_activity_principal_expected |>
    dplyr::inner_join(atpmo_expected, by = c("pod", "measure" = "measures")) |>
    mod_model_core_activity_server_table(value_type = "principal")

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it gets the activity type/pod/measure reference data", {
  m <- mock(atpmo_expected)
  stub(
    mod_model_core_activity_server,
    "get_activity_type_pod_measure_options",
    m
  )

  selected_model_run <- reactiveVal()

  shiny::testServer(
    mod_model_core_activity_server,
    args = list(selected_model_run),
    {
      expect_called(m, 1)
      expect_equal(atpmo, atpmo_expected)
    }
  )
})

test_that("it calls get_model_core_activity", {
  m <- mock(model_core_activity_expected)
  stub(
    mod_model_core_activity_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(mod_model_core_activity_server, "get_model_core_activity", m)

  selected_model_run <- reactiveVal()
  selected_site <- reactiveVal("a")

  shiny::testServer(
    mod_model_core_activity_server,
    args = list(selected_model_run, selected_site),
    {
      selected_model_run("id")

      expected <- model_core_activity_expected |>
        dplyr::inner_join(atpmo_expected, by = c("pod", "measure" = "measures"))
      expect_equal(summarised_data(), expected)

      expect_called(m, 1)
      expect_args(m, 1, "id", "a")
    }
  )
})

test_that("it filters for the site data", {
  stub(
    mod_model_core_activity_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_model_core_activity_server,
    "get_model_core_activity",
    tibble::tibble(
      pod = c("aae_type-01"),
      measure = c("ambulance"),
      value = 1
    )
  )

  shiny::testServer(
    mod_model_core_activity_server,
    args = list(reactiveVal(1), reactiveVal("a")),
    {
      expect_equal(
        summarised_data(),
        tibble::tibble(
          pod = "aae_type-01",
          measure = "ambulance",
          value = 1,
          activity_type = "aae",
          activity_type_name = "A&E",
          pod_name = "Type 1 Department"
        )
      )
    }
  )
})

test_that("it renders the table", {
  m <- mock()

  stub(
    mod_model_core_activity_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_model_core_activity_server,
    "get_model_core_activity",
    model_core_activity_expected
  )
  stub(
    mod_model_core_activity_server,
    "mod_model_core_activity_server_table",
    "table"
  )
  stub(mod_model_core_activity_server, "gt::render_gt", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(
    mod_model_core_activity_server,
    args = list(selected_model_run),
    {
      selected_model_run("id")

      expect_called(m, 2)
      expect_args(m, 1, "table")
    }
  )
})
