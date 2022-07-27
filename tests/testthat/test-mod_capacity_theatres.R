library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

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
  expect_snapshot(mod_capacity_theatres_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helper functions
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_utilisation_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically
  table <- mod_capacity_theatres_get_utilisation_table(fhs_expected)

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

test_that("get_utilisation_plot returns a ggplot object", {
  p <- mod_capacity_theatres_get_utilisation_plot(fhs_expected)
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls cosmos_get_theatres_available correctly", {
  m <- mock("theatres_data")

  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", m)

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_equal(theatres_data(), "theatres_data")

    expect_called(m, 1)
    expect_args(m, 1, "id")
  })
})

test_that("it sets the reactives up correctly", {
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_equal(four_hour_sessions(), fhs_expected)
    expect_equal(theatres_available(), theatres_expected)
  })
})

test_that("it renders the table", {
  m <- mock(
    mod_capacity_theatres_get_utilisation_table(fhs_expected)
  )
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)
  stub(mod_capacity_theatres_server, "mod_capacity_theatres_get_utilisation_table", m)

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, fhs_expected)
  })
})

test_that("it renders the plot", {
  m <- mock()
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)
  stub(mod_capacity_theatres_server, "plotly::ggplotly", "plotly")
  stub(mod_capacity_theatres_server, "plotly::layout", "plotly_layout")
  stub(mod_capacity_theatres_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_called(m, 1)
    expect_args(m, 1, "plotly_layout")
  })
})

test_that("it sets the available text correctly", {
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)
  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_equal(output$available_baseline, "10")
    expect_equal(output$available_principal, "20")
  })
})
