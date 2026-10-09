library(shiny)
library(mockery)

# ─────────────────────────────────────────────────────────────────────────────
# setup
# ─────────────────────────────────────────────────────────────────────────────

# fmt: skip
atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance"
)

set_names <- \(x) rlang::set_names(x[[1]], x[[2]])

data_dictionary <- yyjsonr::read_json_file(
  app_sys("app", "data", "excel_dictionary.json")
)

# ─────────────────────────────────────────────────────────────────────────────
# ui
# ─────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_info_downloads_ui("id"))
})

# ─────────────────────────────────────────────────────────────────────────────
# helpers
# ─────────────────────────────────────────────────────────────────────────────

test_that("it generates an excel file", {
  data <- \() {
    list(
      params = list(x = 1, y = "x", create_datetime = "20220101_000000"),
      results = list(a = tibble::tibble(x = 1:3, y = 4:6)),
      data_dictionary = data_dictionary
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
      metadata = tibble::tibble(
        name = c("x", "y", "create_datetime"),
        value = c("1", "x", "01-Jan-2022 00:00:00")
      ),
      worksheets = data_dictionary[["worksheets"]],
      fields = data_dictionary[["fields"]],
      a = tibble::tibble(x = 1:3, y = 4:6)
    ),
    "file"
  )
})

# ─────────────────────────────────────────────────────────────────────────────
# server
# ─────────────────────────────────────────────────────────────────────────────

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
      expect_args(m, 1, reshaped_data)
      expect_args(m, 2, reshaped_data)
    }
  )
})

# Run the module's real `downloadHandler()`s against results with no A&E rows.
# In `testServer()`, reading `output$<id>` runs the handler's `content`
# function and returns the path of the file it wrote, so errors in the handler
# surface here. The files are deleted when `testServer()` exits, so any checks
# on their contents must happen inside it.
with_downloads_server <- function(r, code) {
  testServer(
    mod_info_downloads_server,
    args = list(
      selected_data = shiny::reactive(r),
      selected_site = shiny::reactive(NULL)
    ),
    {{ code }}
  )
}

# Both report templates set `knitr::opts_chunk$set(error = TRUE)`, so a failing
# chunk doesn't stop the render; the error is written into the HTML instead.
html_chunk_errors <- function(file) {
  grepv("^<pre><code>## Error", readLines(file, warn = FALSE))
}

r_no_aae <- remove_aae_results(mock_results())

test_that("the mock results used below really have no A&E rows", {
  expect_false(any(purrr::map_lgl(
    r_no_aae$results,
    \(x) any(grepl("^aae", x[["pod"]]))
  )))
})

test_that("excel download works when results are missing aae", {
  with_downloads_server(r_no_aae, {
    path <- output$download_results_xlsx
    expect_match(basename(path), "_results\\.xlsx$")
    expect_gt(file.size(path), 0)
  })
})

test_that("json download works when results are missing aae", {
  with_downloads_server(r_no_aae, {
    path <- output$download_results_json
    expect_match(basename(path), "_results\\.json$")

    json <- yyjsonr::read_json_file(path)
    expect_setequal(names(json$results), names(r_no_aae$results))
  })
})

test_that("report downloads work when results are missing aae", {
  skip_if_not(rmarkdown::pandoc_available(), "pandoc is not available")
  skip_on_cran()

  tpma_label_lookup_fixture <- readRDS(test_path(
    "fixtures",
    "tpma_label_lookup.rds"
  ))
  local_mocked_bindings(
    get_tpma_label_lookup = \() tpma_label_lookup_fixture,
    .package = "reskit"
  )

  with_downloads_server(r_no_aae, {
    path <- output$download_report_parameters_html
    expect_gt(file.size(path), 0)
    expect_identical(html_chunk_errors(path), character())

    path <- output$download_report_outputs_html
    expect_gt(file.size(path), 0)
    expect_identical(html_chunk_errors(path), character())
  })
})
