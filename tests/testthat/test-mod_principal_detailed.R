library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(1)
  expect_snapshot(mod_principal_detailed_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it sets up mod_measure_selection_server", {
  m <- mock("mod_measure_selection_server")

  stub(mod_principal_detailed_server, "mod_measure_selection_server", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      expect_called(m, 1)
      expect_args(m, 1, "measure_selection")
      expect_equal(selected_measure, "mod_measure_selection_server")
    }
  )
})

test_that("it calls get_available_aggregations", {
  m <- mock("get_available_aggregations")

  stub(mod_principal_detailed_server, "get_available_aggregations", m)
  stub(mod_principal_detailed_server, "shiny::updateSelectInput", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      selected_data(1)
      expect_equal(available_aggregations(), "get_available_aggregations")
      expect_called(m, 1)
      expect_args(m, 1, 1)
    }
  )
})
