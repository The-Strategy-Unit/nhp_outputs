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
      params = list(x = 1, y = "x", create_datetime = "20220101_000000"),
      results = list(
        a = tibble::tibble(
          x = 1:3,
          y = 4:6,
          z = list(
            list(),
            list(),
            list()
          )
        ),
        # test attendance_category because it's wrangled in the server
        attendance_category = tibble::tibble(
          attendance_category = c(1:4, "X")
        ),
        # test step_counts because data is joined in the server
        step_counts = tibble::tibble(
          strategy = c(
            "alcohol_partially_attributable_acute",
            "convert_to_tele_adult_non-surgical",
            "discharged_no_treatment_adult_ambulance"
          )
        )
      ),
      data_dictionary = jsonlite::read_json(
        app_sys("app", "data", "excel_dictionary.json"),
        simplifyVector = TRUE
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
      metadata = tibble::tibble(
        name = c("x", "y", "create_datetime"),
        value = c("1", "x", "01-Jan-2022 00:00:00")
      ),
      worksheets = data_dictionary[["worksheets"]],
      fields = data_dictionary[["fields"]],
      a = tibble::tibble(x = 1:3, y = 4:6),
      attendance_category = tibble::tibble(
        attendance_category = c(
          "unplanned_first_attendance",
          "unplanned_follow-up_attendance_this_department",
          "unplanned_follow-up_attendance_another_department",
          "planned_follow-up_attendance",
          "unknown"
        )
      ),
      step_counts = tibble::tibble(
        strategy = c(
          "alcohol_partially_attributable_acute",
          "convert_to_tele_adult_non-surgical",
          "discharged_no_treatment_adult_ambulance"
        ),
        mitigator_name = c(
          "Alcohol Related Admissions (Acute Conditions - Partially Attributable) (IP-AA-001)",
          "Outpatient Convert to Tele-Attendance (Adult, Non-Surgical) (OP-EF-001)",
          "A&E Discharged No Investigation or Treatment (Adult, Ambulance Conveyed) (AE-AA-001)"
        ),
        mitigator_code = c(
          "IP-AA-001",
          "OP-EF-001",
          "AE-AA-001"
        )
      )
    ),
    "file"
  )
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
