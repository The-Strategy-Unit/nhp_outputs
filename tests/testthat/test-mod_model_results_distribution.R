library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

selected_measure_expected <- c(activity_type = "aae", pod = "aae_type-01", measure = "ambulance")
model_run_distribution_expected <- tibble::tribble(
  ~sitetret, ~baseline, ~model_run, ~value, ~variant,
  "trust", 30000, 1, 34000, "principal",
  "trust", 30000, 2, 35000, "high migration",
  "trust", 30000, 3, 36000, "high migration"
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_model_results_distribution_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_data calls get_model_run_distribution", {
  m <- mock("cosmos results")

  stub(mod_model_results_distribution_get_data, "get_model_run_distribution", m)

  actual <- mod_model_results_distribution_get_data("id", selected_measure_expected)

  expect_equal(actual, "cosmos results")
  expect_called(m, 1)
  expect_args(m, 1, "id", "aae_type-01", "ambulance")
})

test_that("density_plot returns a ggplot", {
  p <- mod_model_results_distibution_density_plot(
    model_run_distribution_expected,
    FALSE
  )
  expect_s3_class(p, "ggplot")
})

test_that("beeswarm returns a ggplot", {
  p <- mod_model_results_distibution_beeswarm_plot(
    model_run_distribution_expected,
    FALSE
  )
  expect_s3_class(p, "ggplot")
})

test_that("plot returns a plotly subplot", {
  m_density <- mock("density")
  m_beeswarm <- mock("beeswarm")
  m_ggplotly <- mock("p_density", "p_beeswarm")
  m_subplot <- mock("subplot")

  stub(mod_model_results_distibution_plot, "mod_model_results_distibution_density_plot", m_density)
  stub(mod_model_results_distibution_plot, "mod_model_results_distibution_beeswarm_plot", m_beeswarm)
  stub(mod_model_results_distibution_plot, "plotly::ggplotly", m_ggplotly)
  stub(mod_model_results_distibution_plot, "plotly::subplot", m_subplot)
  stub(mod_model_results_distibution_plot, "plotly::layout", "layout")

  p <- mod_model_results_distibution_plot(model_run_distribution_expected, FALSE)
  expect_equal(p, "layout")

  expect_called(m_density, 1)
  expect_args(m_density, 1, model_run_distribution_expected, FALSE)

  expect_called(m_beeswarm, 1)
  expect_args(m_beeswarm, 1, model_run_distribution_expected, FALSE)

  expect_called(m_ggplotly, 2)
  expect_args(m_ggplotly, 1, "density")
  expect_args(m_ggplotly, 2, "beeswarm")

  expect_called(m_subplot, 1)
  expect_args(m_subplot, 1, "p_density", "p_beeswarm", nrows = 2)
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
    selected_site("trust")
    selected_measure(selected_measure_expected)

    expect_equal(aggregated_data(), model_run_distribution_expected)

    expect_called(m, 1)
    expect_args(m, 1, "data", selected_measure_expected)
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
    mod_model_results_distribution_server, "mod_model_results_distibution_plot", m
  )

  selected_model_run <- reactiveVal()
  selected_site <- reactiveVal()

  shiny::testServer(mod_model_results_distribution_server, args = list(selected_model_run, selected_site), {
    selected_model_run("id")
    selected_site("trust")
    selected_measure(selected_measure_expected)
    session$setInputs(show_origin = FALSE)

    expect_called(m, 1)
    expect_args(m, 1, model_run_distribution_expected |> dplyr::select(-"sitetret"), FALSE)
  })
})
