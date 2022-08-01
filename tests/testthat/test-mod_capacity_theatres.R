library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

fhs_expected <- tibble::tribble(
  ~tretspef, ~baseline, ~principal, ~model_runs,
  "a", 50, 45, list(10, 20, 30),
  "b", 60, 75, list(40, 50, 60),
  "c", 80, 90, list(70, 80, 90)
)

theatres_expected <- tibble::tribble(
  ~baseline, ~principal, ~model_run, ~value, ~variant,
  10, 20, 1, 4, "a",
  10, 20, 2, 5, "a",
  10, 20, 3, 6, "b"
)

theatres_data_expected <- list(
  "four_hour_sessions" = fhs_expected,
  "theatres" = tibble::tribble(
    ~tretspef, ~baseline, ~principal, ~model_runs,
    NA, 10, 20, 4:6
  )
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

test_that("get_available_plot returns a ggplot object", {
  p <- mod_capacity_theatres_get_available_plot(theatres_expected)
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
  expected_variants <- tibble::tibble(
    model_run = 1:3,
    variant = c("a", "a", "b")
  )
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)
  stub(mod_capacity_theatres_server, "cosmos_get_variants", expected_variants)

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
  stub(mod_capacity_theatres_server, "mod_capacity_theatres_get_utilisation_plot", NULL)
  stub(mod_capacity_theatres_server, "mod_capacity_theatres_get_available_plot", NULL)

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    session$private$flush()

    expect_called(m, 1)
    expect_args(m, 1, fhs_expected)
  })
})

test_that("it renders the plots", {
  m <- mock()
  stub(mod_capacity_theatres_server, "cosmos_get_theatres_available", theatres_data_expected)
  stub(mod_capacity_theatres_server, "plotly::ggplotly", "plotly")
  stub(mod_capacity_theatres_server, "plotly::layout", "plotly_layout")
  stub(mod_capacity_theatres_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_capacity_theatres_server, args = list(reactiveVal()), {
    selected_model_run_id("id")

    expect_called(m, 2)
    expect_args(m, 1, "plotly_layout")
  })
})
