tab_removed <- TRUE
skip_if(tab_removed)  # Note: skipped due to ongoing time-profile discussions

library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance",
  "aae", "A&E", "aae_type-01", "Type 1 Department", "walk-in",
  "aae", "A&E", "aae_type-02", "Type 2 Department", "ambulance",
  "aae", "A&E", "aae_type-02", "Type 2 Department", "walk-in",
  "aae", "A&E", "aae_type-03", "Type 3 Department", "ambulance",
  "aae", "A&E", "aae_type-03", "Type 3 Department", "walk-in",
  "aae", "A&E", "aae_type-04", "Type 4 Department", "ambulance",
  "aae", "A&E", "aae_type-04", "Type 4 Department", "walk-in",
  "ip", "Inpatients", "ip_elective_admission", "Elective Admission", "admissions",
  "ip", "Inpatients", "ip_elective_admission", "Elective Admission", "beddays",
  "ip", "Inpatients", "ip_elective_daycase", "Daycase Admission", "admissions",
  "ip", "Inpatients", "ip_elective_daycase", "Daycase Admission", "beddays",
  "ip", "Inpatients", "ip_non-elective_admission", "Non-Elective Admission", "admissions",
  "ip", "Inpatients", "ip_non-elective_admission", "Non-Elective Admission", "beddays",
  "ip", "Inpatients", "ip_maternity_admission", "Maternity Admission", "admissions",
  "ip", "Inpatients", "ip_maternity_admission", "Maternity Admission", "beddays",
  "op", "Outpatients", "op_first", "First Outpatient Attendance", "attendances",
  "op", "Outpatients", "op_first", "First Outpatient Attendance", "tele_attendances",
  "op", "Outpatients", "op_follow-up", "Follow-up Outpatient Attendance", "attendances",
  "op", "Outpatients", "op_follow-up", "Follow-up Outpatient Attendance", "tele_attendances",
  "op", "Outpatients", "op_procedure", "Outpatient Procedure", "attendances",
  "op", "Outpatients", "op_procedure", "Outpatient Procedure", "procedures"
)

pods_expected <- tibble::tribble(
  ~activity_type, ~pod, ~pod_name,
  "ip", "ip_elective_admission_admissions", "Elective Admission",
  "ip", "ip_elective_daycase_admissions", "Daycase Admission",
  "ip", "ip_non-elective_admission_admissions", "Non-Elective Admission",
  "ip", "ip_maternity_admission_admissions", "Maternity Admission",
  "ip", "ip_elective_admission_beddays", "Elective Bed Days",
  "ip", "ip_elective_daycase_beddays", "Daycase Bed Days",
  "ip", "ip_non-elective_admission_beddays", "Non-Elective Bed Days",
  "ip", "ip_maternity_admission_beddays", "Maternity Bed Days",
  "op", "op_first", "First Outpatient Attendance",
  "op", "op_follow-up", "Follow-up Outpatient Attendance",
  "op", "op_procedure", "Outpatient Procedure",
  "aae", "aae", "A&E Attendance"
) |>
  dplyr::mutate(dplyr::across(pod_name, forcats::fct_inorder))

principal_high_level_expected <- tibble::tribble(
  ~pod, ~measure, ~year, ~value,
  "aae", "a", 2018, 135000,
  "aae", "a", 2020, 137000,
  "ip_elective_admission", "admissions", 2018, 8800,
  "ip_elective_admission", "admissions", 2020, 10700,
  "ip_elective_daycase", "admissions", 2018, 58000,
  "ip_elective_daycase", "admissions", 2020, 74000,
  "ip_maternity_admission", "admissions", 2018, 1100,
  "ip_maternity_admission", "admissions", 2020, 1200,
  "ip_non-elective_admission", "admissions", 2018, 60000,
  "ip_non-elective_admission", "admissions", 2020, 70000,
  # "ip_non-elective_admission", "beddays", 2018, 60000,
  # "ip_non-elective_admission", "beddays", 2020, 70000,

  "ip_elective_admission", "beddays", 2018, 8800,
  "ip_elective_admission", "beddays", 2020, 10700,
  "ip_elective_daycase", "beddays", 2018, 58000,
  "ip_elective_daycase", "beddays", 2020, 74000,
  "ip_non-elective_admission", "beddays", 2018, 60000,
  "ip_non-elective_admission", "beddays", 2020, 70000,
  "ip_maternity_admission", "beddays", 2018, 1100,
  "ip_maternity_admission", "beddays", 2020, 1200,
  "op_first", "a", 2018, 140000,
  "op_first", "a", 2020, 150000,
  "op_first", "tele_attendances", 2018, 140000,
  "op_first", "tele_attendances", 2020, 150000,
  "op_follow-up", "a", 2018, 370000,
  "op_follow-up", "a", 2020, 390000,
  "op_procedure", "procedures", 2018, 42000,
  "op_procedure", "procedures", 2020, 47000
) |>
  dplyr::mutate(
    .by = c(pod, measure),
    change = value - dplyr::lag(value),
    change_pcnt = change / dplyr::lag(value),
    .after = year
  )

summary_data_expected <- tibble::tribble(
  ~year, ~fyear, ~value, ~activity_type, ~pod_name,
  2018, "2018/19", 135000, "aae", "A&E Attendance",
  2020, "2020/21", 137000, "aae", "A&E Attendance",
  2018, "2018/19", 8800, "ip", "Elective Admission",
  2020, "2020/21", 10700, "ip", "Elective Admission",
  2018, "2018/19", 58000, "ip", "Daycase Admission",
  2020, "2020/21", 74000, "ip", "Daycase Admission",
  2018, "2018/19", 60000, "ip", "Non-Elective Admission",
  2020, "2020/21", 70000, "ip", "Non-Elective Admission",
  2018, "2018/19", 1100, "ip", "Maternity Admission",
  2020, "2020/21", 1200, "ip", "Maternity Admission",
  2018, "2018/19", 8800, "ip", "Elective Bed Days",
  2020, "2020/21", 10700, "ip", "Elective Bed Days",
  2018, "2018/19", 58000, "ip", "Daycase Bed Days",
  2020, "2020/21", 74000, "ip", "Daycase Bed Days",
  2018, "2018/19", 60000, "ip", "Non-Elective Bed Days",
  2020, "2020/21", 70000, "ip", "Non-Elective Bed Days",
  2018, "2018/19", 1100, "ip", "Maternity Bed Days",
  2020, "2020/21", 1200, "ip", "Maternity Bed Days",
  2018, "2018/19", 140000, "op", "First Outpatient Attendance",
  2020, "2020/21", 150000, "op", "First Outpatient Attendance",
  2018, "2018/19", 370000, "op", "Follow-up Outpatient Attendance",
  2020, "2020/21", 390000, "op", "Follow-up Outpatient Attendance"
) |>
  dplyr::mutate(
    .by = c(pod_name),
    change = value - dplyr::lag(value),
    change_pcnt = change / dplyr::lag(value),
    .after = year
  ) |>
  dplyr::mutate(
    dplyr::across(pod_name, \(.x) factor(.x, levels(pods_expected$pod_name)))
  )

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)

  # requires hack because the gt id can't be controlled
  ui <- mod_principal_high_level_ui("id") |>
    as.character() |>
    stringr::str_replace_all(" data-tabsetid=\"\\d+\"", "") |>
    stringr::str_replace_all("#?tab-\\d+-\\d+", "")

  expect_snapshot(ui)
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_high_level_pods returns the correct list of pods", {
  stub(mod_principal_high_level_pods, "get_activity_type_pod_measure_options", atpmo_expected)
  expect_equal(mod_principal_high_level_pods(), pods_expected)
})

test_that("mod_principal_high_level_summary_data processes data correctly", {
  m1 <- mock(principal_high_level_expected)
  m2 <- function(x, y) {
    # instead of a mock, act like a spy
    expect_equal(y, "a")
    x
  }

  stub(mod_principal_high_level_summary_data, "get_time_profiles", m1)
  stub(mod_principal_high_level_summary_data, "trust_site_aggregation", m2)

  actual <- mod_principal_high_level_summary_data(1, pods_expected, "a")
  expect_equal(actual, summary_data_expected)

  expect_called(m1, 1)
  expect_args(m1, 1, 1, "default")
})

test_that("mod_principal_high_level_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- mod_principal_high_level_table(summary_data_expected, summary_type = "value")

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

test_that("mod_principal_high_level_plot returns a plot", {
  expect_s3_class(mod_principal_high_level_plot(summary_data_expected, "aae"), "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it gets the list of pods", {
  m <- mock("pods")
  stub(mod_principal_high_level_server, "mod_principal_high_level_pods", m)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1)), {
    expect_called(m, 1)
    expect_equal(pods, "pods")
  })
})

test_that("it gets the summary data", {
  m <- mock("summary data")
  stub(mod_principal_high_level_server, "mod_principal_high_level_pods", "pods")
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", m)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1), reactiveVal("a")), {
    expect_equal(summary_data(), "summary data")
    expect_called(m, 1)
    expect_args(m, 1, 1, "pods", "a")
  })
})

test_that("it filters for the site data", {
  stub(mod_principal_high_level_server, "mod_principal_high_level_pods", "pods")
  stub(
    mod_principal_high_level_server,
    "mod_principal_high_level_summary_data",
    tibble::tibble(
      value = 1
    )
  )
  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1), reactiveVal("a")), {
    expect_equal(
      summary_data(),
      tibble::tibble(value = 1)
    )
  })
})

test_that("it creates the table", {
  m <- mock()
  stub(mod_principal_high_level_server, "gt::render_gt", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_table", NULL)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal()), {
    expect_called(m, 3)
  })
})

test_that("it creates 4 plots", {
  m <- mock()
  stub(mod_principal_high_level_server, "plotly::renderPlotly", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_plot", ggplot2::ggplot())

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(), reactiveVal("trust")), {
    expect_called(m, 4)
  })
})
