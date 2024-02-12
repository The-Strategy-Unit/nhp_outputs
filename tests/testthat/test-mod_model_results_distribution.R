library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

selected_measure_expected <- c(activity_type = "aae", pod = "aae_type-01", measure = "ambulance")
model_run_distribution_expected <- tibble::tribble(
  ~baseline, ~principal, ~model_run, ~value, ~variant,
  30000, 31000, 1, 34000, "principal",
  30000, 31000, 2, 35000, "high migration",
  30000, 31000, 3, 36000, "high migration"
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(mod_model_results_distribution_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_data calls get_model_run_distribution", {
  m <- mock("results")

  stub(mod_model_results_distribution_get_data, "get_model_run_distribution", m)

  actual <- mod_model_results_distribution_get_data("id", selected_measure_expected, "a")

  expect_equal(actual, "results")
  expect_called(m, 1)
  expect_args(m, 1, "id", "aae_type-01", "ambulance", "a")
})

test_that("beeswarm returns a ggplot", {
  p <- mod_model_results_distribution_beeswarm_plot(
    model_run_distribution_expected,
    FALSE
  )
  expect_s3_class(p, "plotly")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it creates a mod_measure_selection_server", {
  m <- mock(selected_measure_expected)
  stub(mod_model_results_distribution_server, "mod_measure_selection_server", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(mod_model_results_distribution_server, args = list(selected_model_run), {
    expect_called(m, 1)
    expect_equal(selected_measure, selected_measure_expected)
  })
})

test_that("it calls mod_model_results_distribution_get_data", {
  m <- mock(model_run_distribution_expected)
  stub(mod_model_results_distribution_server, "mod_measure_selection_server", reactiveVal)
  stub(mod_model_results_distribution_server, "mod_model_results_distribution_get_data", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  shiny::testServer(mod_model_results_distribution_server, args = list(selected_data, selected_site), {
    selected_data("data")
    selected_site("a")
    selected_measure(selected_measure_expected)

    expect_equal(aggregated_data(), model_run_distribution_expected)

    expect_called(m, 1)
    expect_args(m, 1, "data", selected_measure_expected, "a")
  })
})

test_that("it renders the plot", {
  m <- mock()

  stub(
    mod_model_results_distribution_server, "mod_measure_selection_server", reactiveVal
  )
  stub(
    mod_model_results_distribution_server, "mod_model_results_distribution_get_data", model_run_distribution_expected
  )
  stub(
    mod_model_results_distribution_server, "mod_model_results_distribution_beeswarm_plot", m
  )

  selected_model_run <- reactiveVal()
  selected_site <- reactiveVal()

  shiny::testServer(mod_model_results_distribution_server, args = list(selected_model_run, selected_site), {
    selected_model_run("id")
    selected_site("trust")
    selected_measure(selected_measure_expected)
    session$setInputs(show_origin = FALSE)

    expect_called(m, 1)
    expect_args(m, 1, model_run_distribution_expected, FALSE)
  })
})
