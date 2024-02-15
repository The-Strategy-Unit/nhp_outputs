library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(1)
  expect_snapshot(mod_info_params_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("outputs are set correctly", {
  selected_data <- shiny::reactiveVal(
    jsonlite::read_json(app_sys("sample_results.json"), simplifyVector = TRUE)
  )

  set.seed(1)
  testServer(
    mod_info_params_server,
    args = list(selected_data = selected_data),
    {
      session$private$flush()
      expect_equal(output$time_profile_waiting_list_adjustment, "linear")
      expect_equal(output$time_profile_expat, "linear")
      expect_equal(output$time_profile_repat_local, "linear")
      expect_equal(output$time_profile_repat_nonlocal, "linear")

      # TODO: test other outputs
    }
  )
})
