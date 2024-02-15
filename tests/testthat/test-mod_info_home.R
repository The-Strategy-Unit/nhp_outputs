library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance"
)

set_names <- function(x) {
  purrr::set_names(x[[1]], x[[2]])
}

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_info_home_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it generates an excel file", {
  data <- \() {
    list(
      results = list(
        a = tibble::tibble(
          x = 1:3,
          y = 4:6,
          z = list(
            list(),
            list(),
            list()
          )
        )
      )
    )
  }

  m <- mock()
  stub(mod_info_home_download_excel, "writexl::write_xlsx", m, 2)

  mod_info_home_download_excel(data)("file")

  expect_called(m, 1)
  expect_args(m, 1, list(a = tibble::tibble(x = 1:3, y = 4:6)), "file")
})

test_that("it generates a json file", {
  data <- \() "data"
  m <- mock()
  stub(mod_info_home_download_json, "jsonlite::write_json", m, 2)

  mod_info_home_download_json(data)("file")

  expect_called(m, 1)
  expect_args(m, 1, "data", "file", pretty = TRUE, auto_unbox = TRUE)
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it gets the model run information from params", {
  selected_data <- reactive({
    list(
      params = list(
        id = "test-synthetic",
        scenario = "test",
        dataset = "synthetic",
        start_year = 2020,
        end_year = 2040,
        create_datetime = "20240123_012345",
        stuff = list(1, 2, 3)
      )
    )
  })

  testServer(
    mod_info_home_server,
    args = list(selected_data = selected_data),
    {
      expected <- tibble::tribble(
        ~name, ~value,
        "id", "test-synthetic",
        "scenario", "test",
        "dataset", "synthetic",
        "start_year", "2020/21",
        "end_year", "2040/41",
        "create_datetime", "23-Jan-2024 01:23:45"
      )

      actual <- params_model_run()
      expect_equal(actual, expected)
    }
  )
})

test_that("it generates a gt table", {
  selected_data <- reactive({
    list(
      params = list(
        id = "test-synthetic",
        scenario = "test",
        dataset = "synthetic",
        start_year = 2020,
        end_year = 2040,
        create_datetime = "20240123_012345",
        stuff = list(1, 2, 3)
      )
    )
  })

  expected <- tibble::tribble(
    ~name, ~value,
    "id", "test-synthetic",
    "scenario", "test",
    "dataset", "synthetic",
    "start_year", "2020/21",
    "end_year", "2040/41",
    "create_datetime", "23-Jan-2024 01:23:45"
  )

  m1 <- mock("gt")
  m2 <- mock("gt_theme")

  stub(mod_info_home_server, "gt::gt", m1)
  stub(mod_info_home_server, "gt_theme", m2)

  testServer(
    mod_info_home_server,
    args = list(selected_data = selected_data),
    {
      session$private$flush()
      expect_called(m1, 1)
      expect_called(m2, 1)
      expect_call(m1, 1, gt::gt(params_model_run(), "name"))
      expect_args(m2, 1, "gt")
    }
  )
})
