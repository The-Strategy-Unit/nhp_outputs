library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

beds_data_expected <- tibble::tribble(
  ~ward_group, ~baseline, ~principal,
  "a", 50, 45,
  "b", 60, 75,
  "c", 80, 90
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

test_that("get_available_plot returns a ggplot object", {
  p <- mod_capacity_beds_get_available_plot(beds_data_expected)
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls cosmos_get_bed_occupancy correctly", {
  m <- mock("beds_data")

  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "cosmos_get_bed_occupancy", m)

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_equal(beds_data(), "beds_data")

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it renders the table", {
  m <- mock(
    mod_capacity_beds_get_available_table(beds_data_expected)
  )
  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "cosmos_get_bed_occupancy", beds_data_expected)
  stub(mod_capacity_beds_server, "mod_capacity_beds_get_available_table", m)

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, beds_data_expected)
  })
})

test_that("it renders the plot", {
  m <- mock()
  stub(mod_capacity_beds_server, "get_data_cache", "session")
  stub(mod_capacity_beds_server, "cosmos_get_bed_occupancy", beds_data_expected)
  stub(mod_capacity_beds_server, "plotly::ggplotly", "plotly")
  stub(mod_capacity_beds_server, "plotly::layout", "plotly_layout")
  stub(mod_capacity_beds_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_beds_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_called(m, 1)
    expect_args(m, 1, "plotly_layout")
  })
})
