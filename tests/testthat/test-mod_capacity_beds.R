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

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_capacity_beds_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_available_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically
  table <- mod_capacity_beds_get_available_table(beds_data_expected)

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

test_that("get_available_density_plot returns a ggplot object", {
  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_capacity_beds_get_available_density_plot(expected_data, expected_baseline)
  expect_s3_class(p, "ggplot")
})

test_that("get_available_beeswarm returns a ggplot object", {
  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_capacity_beds_get_available_beeswarm_plot(expected_data, expected_baseline)
  expect_s3_class(p, "ggplot")
})

test_that("get_available_plot combines the plots into a plotly object", {
  m <- mock(
    "density_plot",
    "beeswarm_plot",
    "density_plotly",
    "beeswarm_plotly",
    "subplot",
    "layout"
  )

  stub(mod_capacity_beds_get_available_plot, "mod_capacity_beds_get_available_density_plot", m)
  stub(mod_capacity_beds_get_available_plot, "mod_capacity_beds_get_available_beeswarm_plot", m)
  stub(mod_capacity_beds_get_available_plot, "plotly::ggplotly", m)
  stub(mod_capacity_beds_get_available_plot, "plotly::subplot", m)
  stub(mod_capacity_beds_get_available_plot, "plotly::layout", m)

  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_capacity_beds_get_available_plot(beds_data_expected)
  expect_equal(p, "layout")

  expect_called(m, 6)
  expect_args(m, 1, expected_data, expected_baseline)
  expect_args(m, 2, expected_data, expected_baseline)
  expect_args(m, 3, "density_plot")
  expect_args(m, 4, "beeswarm_plot")
  expect_args(m, 5, "density_plotly", "beeswarm_plotly", nrows = 2)
  expect_args(m, 6, "subplot", legend = list(orientation = "h"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls cosmos_get_bed_occupancy correctly", {
  m <- mock("beds_data")

  stub(mod_capacity_beds_server, "cosmos_get_bed_occupancy", m)

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_equal(beds_data(), "beds_data")

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it renders the table", {
  d <- dplyr::filter(beds_data_expected, model_run == 1)

  m <- mock(mock_table)
  stub(mod_capacity_beds_server, "cosmos_get_bed_occupancy", beds_data_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_table", m)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_plot", NULL)

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, d)
  })
})

test_that("it renders the plot", {
  m <- mock()
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_plot", "plot")
  stub(mod_capacity_beds_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_called(m, 1)
    expect_args(m, 1, "plot")
  })
})
