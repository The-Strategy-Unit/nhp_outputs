library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

beds_data_expected <- tibble::tribble(
  ~ward_group, ~baseline, ~principal, ~model_run, ~value, ~variant,
  "a", 50, 45, 1, 1, "a",
  "a", 50, 45, 2, 2, "a",
  "a", 50, 45, 3, 3, "b",
  "b", 60, 75, 1, 4, "a",
  "b", 60, 75, 2, 5, "a",
  "b", 60, 75, 3, 6, "b",
  "c", 80, 90, 1, 7, "a",
  "c", 80, 90, 2, 8, "a",
  "c", 80, 90, 3, 9, "b"
)

fhs_expected <- tibble::tribble(
  ~tretspef, ~baseline, ~principal, ~model_runs,
  "a", 50, 45, c(10, 20, 30),
  "b", 60, 75, c(40, 50, 60),
  "c", 80, 90, c(70, 80, 90)
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_model_results_capacity_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("beds_density_plot returns a ggplot object", {
  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_model_results_capacity_beds_density_plot(expected_data, expected_baseline)

  expect_s3_class(p, "ggplot")
})

test_that("beds_beeswarm returns a ggplot object", {
  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_model_results_capacity_beds_beeswarm_plot(expected_data, expected_baseline)

  expect_s3_class(p, "ggplot")
})

test_that("beds_available_plot combines the plots into a plotly object", {
  m <- mock(
    "density_plot",
    "beeswarm_plot",
    "density_plotly",
    "beeswarm_plotly",
    "subplot",
    "layout"
  )

  stub(mod_model_results_capacity_beds_available_plot, "mod_model_results_capacity_beds_density_plot", m)
  stub(mod_model_results_capacity_beds_available_plot, "mod_model_results_capacity_beds_beeswarm_plot", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::ggplotly", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::subplot", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::layout", m)

  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- beds_data_expected |>
    mod_model_results_capacity_beds_available_plot()

  expect_equal(p, "layout")

  expect_called(m, 6)
  expect_args(m, 1, expected_data, expected_baseline)
  expect_args(m, 2, expected_data, expected_baseline)
  expect_args(m, 3, "density_plot")
  expect_args(m, 4, "beeswarm_plot")
  expect_args(m, 5, "density_plotly", "beeswarm_plotly", nrows = 2)
  expect_args(m, 6, "subplot", legend = list(orientation = "h"))
})

test_that("fhs_available_plot returns a ggplot object", {
  data <- fhs_expected |>
    dplyr::mutate(dplyr::across("model_runs", \(.x) purrr::map(.x, tibble::enframe, "model_run"))) |>
    tidyr::unnest("model_runs") |>
    dplyr::mutate(variant = "a")

  p <- mod_model_results_capacity_fhs_available_plot(data)
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls get_bed_occupancy correctly", {
  m <- mock("beds_data")

  stub(mod_model_results_capacity_server, "get_bed_occupancy", m)

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")

    expect_equal(beds_data(), "beds_data")

    expect_called(m, 1)
    expect_args(m, 1, "data")
  })
})

test_that("it calls get_theatres_available correctly", {
  m <- mock(fhs_expected)

  stub(mod_model_results_capacity_server, "get_theatres_available", m)
  stub(
    mod_model_results_capacity_server,
    "get_variants",
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  expected <- tibble::tibble(
    tretspef = c("a", "a", "a", "b", "b", "b", "c", "c", "c"),
    baseline = c(50, 50, 50, 60, 60, 60, 80, 80, 80),
    principal = c(45, 45, 45, 75, 75, 75, 90, 90, 90),
    model_run = c(1, 2, 3, 1, 2, 3, 1, 2, 3),
    value = c(10, 20, 30, 40, 50, 60, 70, 80, 90),
    variant = c("a", "a", "b", "a", "a", "b", "a", "a", "b")
  )

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")

    expect_equal(four_hour_sessions(), expected)

    expect_called(m, 1)
    expect_args(m, 1, "data")
  })
})

test_that("it sets the reactives up correctly", {
  expected_variants <- tibble::tibble(
    model_run = 1:3,
    variant = c("a", "a", "b")
  )
  stub(mod_model_results_capacity_server, "get_theatres_available", fhs_expected)
  stub(mod_model_results_capacity_server, "get_variants", expected_variants)

  fhs_data <- fhs_expected |>
    dplyr::mutate(dplyr::across("model_runs", \(.x) purrr::map(.x, tibble::enframe, "model_run"))) |>
    tidyr::unnest("model_runs") |>
    dplyr::inner_join(expected_variants, by = "model_run")

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data(0)

    expect_equal(four_hour_sessions(), fhs_data)
  })
})

test_that("it renders the plots", {
  m <- mock()
  stub(mod_model_results_capacity_server, "mod_model_results_capacity_beds_available_plot", "beds")
  stub(mod_model_results_capacity_server, "mod_model_results_capacity_fhs_available_plot", "fhs")
  stub(mod_model_results_capacity_server, "plotly::ggplotly", \(x, ...) x)
  stub(mod_model_results_capacity_server, "plotly::layout", \(x, ...) x)
  stub(mod_model_results_capacity_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_model_run("id")

    expect_called(m, 2)
    expect_args(m, 1, "beds")
    expect_args(m, 2, "fhs")
  })
})
