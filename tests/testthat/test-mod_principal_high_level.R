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
  "ip", "ip_elective_admission", "Elective Admission",
  "ip", "ip_elective_daycase", "Daycase Admission",
  "ip", "ip_non-elective_admission", "Non-Elective Admission",
  "ip", "ip_maternity_admission", "Maternity Admission",
  "op", "op_first", "First Outpatient Attendance",
  "op", "op_follow-up", "Follow-up Outpatient Attendance",
  "op", "op_procedure", "Outpatient Procedure",
  "aae", "aae", "A&E Attendance"
) |>
  dplyr::mutate(dplyr::across(pod_name, forcats::fct_inorder))

principal_high_level_expected <- tibble::tribble(
  ~sitetret, ~pod, ~measure, ~year, ~value,
  "trust", "aae", "a", 2018, 135000,
  "trust", "aae", "a", 2020, 137000,
  "RXX", "ip_elective_admission", "a", 2018, 8800,
  "RXX", "ip_elective_admission", "a", 2020, 10700,
  "RXX", "ip_elective_daycase", "a", 2018, 58000,
  "RXX", "ip_elective_daycase", "a", 2020, 74000,
  "RXX", "ip_maternity_admission", "a", 2018, 1100,
  "RXX", "ip_maternity_admission", "a", 2020, 1200,
  "RXX", "ip_non-elective_admission", "a", 2018, 60000,
  "RXX", "ip_non-elective_admission", "a", 2020, 70000,
  "RXX", "ip_non-elective_admission", "beddays", 2018, 60000,
  "RXX", "ip_non-elective_admission", "beddays", 2020, 70000,
  "RXX", "op_first", "a", 2018, 140000,
  "RXX", "op_first", "a", 2020, 150000,
  "RXX", "op_first", "tele_attendances", 2018, 140000,
  "RXX", "op_first", "tele_attendances", 2020, 150000,
  "RXX", "op_follow-up", "a", 2018, 370000,
  "RXX", "op_follow-up", "a", 2020, 390000,
  "RXX", "op_procedure", "procedures", 2018, 42000,
  "RXX", "op_procedure", "procedures", 2020, 47000
) |>
  dplyr::mutate(
    .by = c(sitetret, pod, measure),
    change = value - dplyr::lag(value),
    change_pcnt = change / dplyr::lag(value),
    .after = year
  )

summary_data_expected <- tibble::tribble(
  ~sitetret, ~year, ~fyear, ~value, ~activity_type, ~pod_name,
  "trust", 2018, "2018/19", 135000, "aae", "A&E Attendance",
  "trust", 2020, "2020/21", 137000, "aae", "A&E Attendance",
  "RXX",   2018, "2018/19", 8800,   "ip",  "Elective Admission",
  "RXX",   2020, "2020/21", 10700,  "ip",  "Elective Admission",
  "RXX",   2018, "2018/19", 58000,  "ip",  "Daycase Admission",
  "RXX",   2020, "2020/21", 74000,  "ip",  "Daycase Admission",
  "RXX",   2018, "2018/19", 1100,   "ip",  "Maternity Admission",
  "RXX",   2020, "2020/21", 1200,   "ip",  "Maternity Admission",
  "RXX",   2018, "2018/19", 60000,  "ip",  "Non-Elective Admission",
  "RXX",   2020, "2020/21", 70000,  "ip",  "Non-Elective Admission",
  "RXX",   2018, "2018/19", 140000, "op",  "First Outpatient Attendance",
  "RXX",   2020, "2020/21", 150000, "op",  "First Outpatient Attendance",
  "RXX",   2018, "2018/19", 370000, "op",  "Follow-up Outpatient Attendance",
  "RXX",   2020, "2020/21", 390000, "op",  "Follow-up Outpatient Attendance"
) |>
  dplyr::mutate(
    .by = c(sitetret, pod_name),
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
  m <- mock(principal_high_level_expected)

  stub(mod_principal_high_level_summary_data, "get_time_profiles", m)
  stub(mod_principal_high_level_summary_data, "trust_site_aggregation", identity)

  actual <- mod_principal_high_level_summary_data(1, pods_expected)
  expect_equal(actual, summary_data_expected)
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

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1)), {
    expect_equal(summary_data(), "summary data")
    expect_called(m, 1)
    expect_args(m, 1, 1, "pods")
  })
})

test_that("it filters for the site data", {
  stub(mod_principal_high_level_server, "mod_principal_high_level_pods", "pods")
  stub(
    mod_principal_high_level_server,
    "mod_principal_high_level_summary_data",
    tibble::tibble(
      sitetret = c("a", "b"),
      value = 1:2
    )
  )
  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1), reactiveVal("a")), {
    expect_equal(
      site_data(),
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

test_that("it creates 3 plots", {
  m <- mock()
  stub(mod_principal_high_level_server, "plotly::renderPlotly", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_plot", ggplot2::ggplot())

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(), reactiveVal("trust")), {
    expect_called(m, 3)
  })
})
