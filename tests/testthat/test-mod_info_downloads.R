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
  expect_snapshot(mod_info_downloads_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it generates an excel file", {
  data <- \() {
    list(
      params = list(x = 1, y = 2),
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
  stub(mod_info_downloads_download_excel, "writexl::write_xlsx", m, 2)

  mod_info_downloads_download_excel(data)("file")

  expect_called(m, 1)
  expect_args(
    m,
    1,
    list(
      metadata = tibble::tibble(name = c("x", "y"), value = c("1", "2")),
      a = tibble::tibble(x = 1:3, y = 4:6)
    ),
    "file"
  )
})

test_that("it generates a json file", {
  data <- \() "data"
  m <- mock()
  stub(mod_info_downloads_download_json, "jsonlite::write_json", m, 2)

  mod_info_downloads_download_json(data)("file")

  expect_called(m, 1)
  expect_args(m, 1, "data", "file", pretty = TRUE, auto_unbox = TRUE)
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it sets up download handlers", {
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

  m <- mock()
  stub(mod_info_downloads_server, "mod_info_downloads_download_excel", m)
  stub(mod_info_downloads_server, "mod_info_downloads_download_json", m)

  testServer(
    mod_info_downloads_server,
    args = list(selected_data = selected_data),
    {
      session$private$flush()
      expect_called(m, 2)
      expect_args(m, 1, selected_data)
      expect_args(m, 2, selected_data)
    }
  )
})
