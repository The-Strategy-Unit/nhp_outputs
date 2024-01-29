library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

beds_data_expected <- tibble::tribble(
  ~ward_type, ~ward_group, ~baseline, ~principal, ~model_run, ~value, ~variant,
  "a", "a", 50, 45, 1, 1, "a",
  "a", "a", 50, 45, 2, 2, "a",
  "a", "a", 50, 45, 3, 3, "b",
  "a", "b", 60, 75, 1, 4, "a",
  "a", "b", 60, 75, 2, 5, "a",
  "a", "b", 60, 75, 3, 6, "b",
  "b", "c", 80, 90, 1, 7, "a",
  "b", "c", 80, 90, 2, 8, "a",
  "b", "c", 80, 90, 3, 9, "b"
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

  p <- mod_model_results_capacity_beds_density_plot(expected_data, 190, 200, 0.5)

  expect_s3_class(p, "ggplot")
})

test_that("beds_beeswarm returns a ggplot object", {
  expected_data <- dplyr::count(beds_data_expected, model_run, variant, wt = value)
  expected_baseline <- 190

  p <- mod_model_results_capacity_beds_beeswarm_plot(expected_data, 190, 200)

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

  stub(mod_model_results_capacity_beds_available_plot, "density", "d")
  stub(mod_model_results_capacity_beds_available_plot, "approx", list(y = 0.5))

  stub(mod_model_results_capacity_beds_available_plot, "mod_model_results_capacity_beds_density_plot", m)
  stub(mod_model_results_capacity_beds_available_plot, "mod_model_results_capacity_beds_beeswarm_plot", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::ggplotly", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::subplot", m)
  stub(mod_model_results_capacity_beds_available_plot, "plotly::layout", m)

  p <- beds_data_expected |>
    mod_model_results_capacity_beds_available_plot()

  expect_equal(p, "layout")

  expect_called(m, 6)
  expect_args(m, 1, beds_data_expected, 190, 210, 0.5)
  expect_args(m, 2, beds_data_expected, 190, 210)
  expect_args(m, 3, "density_plot")
  expect_args(m, 4, "beeswarm_plot")
  expect_args(m, 5, "density_plotly", "beeswarm_plotly", nrows = 2)
  expect_args(m, 6, "subplot", legend = list(orientation = "h"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it calls get_bed_occupancy correctly", {
  m <- mock("beds_data")

  stub(mod_model_results_capacity_server, "get_bed_occupancy", m)

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")

    expect_equal(all_beds_data(), "beds_data")

    expect_called(m, 1)
    expect_args(m, 1, "data")
  })
})

test_that("it filters all_beds_data correctly", {
  d <- dplyr::bind_rows(
    q1 = beds_data_expected,
    q2 = beds_data_expected,
    .id = "quarter"
  )
  stub(mod_model_results_capacity_server, "get_bed_occupancy", d)

  expected <- tibble::tribble(
    ~model_run, ~variant, ~baseline, ~principal, ~value,
    1, "a", 110, 120, 5,
    2, "a", 110, 120, 7,
    3, "b", 110, 120, 9
  )

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")
    session$setInputs(
      beds_ward_type = "a",
      beds_quarter = "q1"
    )

    expect_equal(beds_data(), expected)
  })
})

test_that("it gets the ward types", {
  d <- dplyr::bind_rows(
    q1 = beds_data_expected,
    q2 = beds_data_expected,
    .id = "quarter"
  )
  stub(mod_model_results_capacity_server, "get_bed_occupancy", d)

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")
    session$setInputs(
      beds_ward_type = "a",
      beds_quarter = "q1"
    )

    expect_equal(ward_types(), c("a", "b"))
  })
})

test_that("it updates the ward type dropdown", {
  d <- dplyr::bind_rows(
    q1 = beds_data_expected,
    q2 = dplyr::filter(beds_data_expected, .data[["ward_type"]] == "a"),
    .id = "quarter"
  )
  m <- mock()
  stub(mod_model_results_capacity_server, "get_bed_occupancy", d)
  stub(mod_model_results_capacity_server, "shiny::updateSelectInput", m)

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_data("data")
    session$setInputs(
      beds_ward_type = "a",
      beds_quarter = "q1"
    )
    session$setInputs(
      beds_ward_type = "b",
      beds_quarter = "q1"
    )
    session$setInputs(
      beds_ward_type = "a",
      beds_quarter = "q2"
    )

    expect_called(m, 3)
    expect_args(m, 1, session, "beds_ward_type", choices = c("a", "b"), selected = "a")
    expect_args(m, 2, session, "beds_ward_type", choices = c("a", "b"), selected = "b")
    expect_args(m, 3, session, "beds_ward_type", choices = c("a"), selected = "a")
  })
})

test_that("it renders the plots", {
  m <- mock()
  stub(mod_model_results_capacity_server, "mod_model_results_capacity_beds_available_plot", "beds")
  stub(mod_model_results_capacity_server, "mod_model_results_capacity_beds_ecdf_plot", "beds_ecdf")
  stub(mod_model_results_capacity_server, "plotly::ggplotly", \(x, ...) x)
  stub(mod_model_results_capacity_server, "plotly::layout", \(x, ...) x)
  stub(mod_model_results_capacity_server, "plotly::renderPlotly", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_model_results_capacity_server, args = list(reactiveVal()), {
    selected_model_run("id")

    expect_called(m, 2)
    expect_args(m, 1, "beds")
    expect_args(m, 2, "beds_ecdf")
  })
})
