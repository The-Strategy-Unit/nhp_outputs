library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

beds_expected <- tibble::tribble(
  ~quarter, ~ward_group, ~baseline, ~principal, ~model_run, ~value, ~variant,
  "q1", "a", 50, 45, 1, 1, "a",
  "q1", "a", 50, 45, 2, 2, "a",
  "q1", "a", 50, 45, 3, 3, "b",
  "q1", "b", 60, 75, 1, 4, "a",
  "q1", "b", 60, 75, 2, 5, "a",
  "q1", "b", 60, 75, 3, 6, "b",
  "q1", "c", 80, 90, 1, 7, "a",
  "q1", "c", 80, 90, 2, 8, "a",
  "q1", "c", 80, 90, 3, 9, "b"
)

beds_data_filtered_expected <- beds_expected |>
  dplyr::filter(model_run == 1) |>
  dplyr::select("quarter", "ward_group", "baseline", "principal")

fhs_expected <- tibble::tribble(
  ~tretspef, ~baseline, ~principal,
  "a", 50, 45,
  "b", 60, 75,
  "c", 80, 90
)

theatres_expected <- tibble::tribble(
  ~baseline, ~principal,
  10, 20
)

theatres_data_expected <- list(
  "four_hour_sessions" = fhs_expected,
  "theatres" = theatres_expected
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
test_that("ui is created correctly", {
  expect_snapshot(mod_principal_capacity_requirements_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("beds_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  data <- beds_expected |>
    dplyr::filter(model_run == 1) |>
    dplyr::select("quarter", "ward_group", "baseline", "principal")

  table <- c("q1", "q2", "q3", "q4") |>
    purrr::map_dfr(\(.x) dplyr::mutate(data, quarter = .x)) |>
    mod_principal_capacity_requirements_beds_table()

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

test_that("fhs_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- fhs_expected |>
    dplyr::select("baseline", "principal") |>
    mod_principal_capacity_requirements_fhs_table()

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls cosmos_get_bed_occupancy correctly", {
  m <- mock(beds_expected)

  stub(mod_principal_capacity_requirements_server, "cosmos_get_bed_occupancy", m)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_model_run("id")

    expect_equal(beds_data(), beds_data_filtered_expected)

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it calls cosmos_get_theatres_available correctly", {
  m <- mock("theatres_data")

  stub(mod_principal_capacity_requirements_server, "cosmos_get_theatres_available", m)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_model_run("id")

    expect_equal(theatres_data(), "theatres_data")

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it sets the reactives up correctly", {
  stub(mod_principal_capacity_requirements_server, "cosmos_get_theatres_available", theatres_data_expected)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_model_run("id")

    expect_equal(four_hour_sessions(), fhs_expected)
  })
})

test_that("it renders the tables", {
  m <- mock(
    mod_principal_capacity_requirements_get_utilisation_table(fhs_expected)
  )
  stub(mod_principal_capacity_requirements_server, "cosmos_get_bed_occupancy", beds_expected)
  stub(mod_principal_capacity_requirements_server, "cosmos_get_theatres_available", theatres_data_expected)
  stub(mod_principal_capacity_requirements_server, "mod_principal_capacity_requirements_beds_table", m)
  stub(mod_principal_capacity_requirements_server, "mod_principal_capacity_requirements_fhs_table", m)

  shiny::testServer(mod_principal_capacity_requirements_server, args = list(reactiveVal()), {
    selected_model_run("id")

    session$private$flush()

    expect_called(m, 2)
    expect_args(m, 1, beds_data_filtered_expected)
    expect_args(m, 2, fhs_expected)
  })
})
