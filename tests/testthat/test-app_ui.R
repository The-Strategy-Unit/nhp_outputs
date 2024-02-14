library(shiny)
library(mockery)

test_that("ui is created correctly", {
  # there is an issue running on CI with the font awesome icons...
  stub_icon_fn <- purrr::partial(shiny::icon, verify_fa = FALSE)
  shiny_icon_fn <- shiny::icon

  assign_shiny_icon <- function(fn) {
    rlang::env_unlock(env = asNamespace("shiny"))
    rlang::env_binding_unlock(env = asNamespace("shiny"))
    assign("icon", fn, envir = asNamespace("shiny"))
    rlang::env_binding_lock(env = asNamespace("shiny"))
    rlang::env_lock(asNamespace("shiny"))
  }
  withr::defer({
    assign_shiny_icon(shiny_icon_fn)
  })
  assign_shiny_icon(stub_icon_fn)

  m <- mock(
    "result_selection",
    "principal_summary",
    "principal_change_factor_effects",
    "principal_high_level",
    "principal_detailed",
    "model_core_activity",
    "model_results_distribution",
    "info_params"
  )

  stub(app_ui, "mod_result_selection_ui", m)
  stub(app_ui, "mod_principal_summary_ui", m)
  stub(app_ui, "mod_principal_change_factor_effects_ui", m)
  stub(app_ui, "mod_principal_high_level_ui", m)
  stub(app_ui, "mod_principal_detailed_ui", m)
  stub(app_ui, "mod_model_core_activity_ui", m)
  stub(app_ui, "mod_model_results_distribution_ui", m)
  stub(app_ui, "mod_info_params_ui", m)

  expect_snapshot(app_ui())

  expect_called(m, 8)
  expect_args(m, 1, "result_selection")
  expect_args(m, 2, "principal_summary")
  expect_args(m, 3, "principal_change_factor_effects")
  expect_args(m, 4, "principal_high_level")
  expect_args(m, 5, "principal_detailed")
  expect_args(m, 6, "model_core_activity")
  expect_args(m, 7, "model_results_distribution")
  expect_args(m, 8, "info_params")
})
