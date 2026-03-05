library(shiny)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)

  # requires hack because the gt id can't be controlled
  ui <- mod_model_core_activity_ui("id") |>
    as.character() |>
    stringr::str_replace_all(" data-tabsetid=\"\\d+\"", "") |>
    stringr::str_replace_all("#?tab-\\d+-\\d+", "")

  expect_snapshot(ui)
})
