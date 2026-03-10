library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

selected_measure_expected <- c(
  activity_type = "aae",
  pod = "aae_type-01",
  measure = "ambulance"
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(
    mod_model_results_distribution_ui("id"),
    transform = \(lines) {
      # Mask both id and data-spinner-id attributes
      lines <- gsub("id=\"spinner-[0-9a-f]+\"", "id=\"spinner-<id>\"", lines)
      gsub(
        "data-spinner-id=\"spinner-[0-9a-f]+\"",
        "data-spinner-id=\"spinner-<id>\"",
        lines
      )
    }
  )
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it creates a mod_measure_selection_server", {
  m <- mock(selected_measure_expected)
  stub(mod_model_results_distribution_server, "mod_measure_selection_server", m)

  selected_model_run <- reactiveVal()

  shiny::testServer(
    mod_model_results_distribution_server,
    args = list(selected_model_run),
    {
      expect_called(m, 1)
      expect_equal(selected_measure, selected_measure_expected)
    }
  )
})
