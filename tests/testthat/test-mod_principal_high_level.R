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
  ~sitetret, ~pod,                          ~baseline, ~principal,
  "trust",   "aae",                            135000,     137000,
  "RXX",     "ip_elective_admission",            8800,      10700,
  "RXX",     "ip_elective_daycase",             58000,      74000,
  "RXX",     "ip_maternity_admission",           1100,       1200,
  "RXX",     "ip_non-elective_admission",       60000,      70000,
  "RXX",     "op_first",                       140000,     150000,
  "RXX",     "op_follow-up",                   370000,     390000,
  "RXX",     "op_procedure",                    42000,      47000
)

summary_data_expected <- tibble::tribble(
  ~year, ~sitetret, ~value, ~activity_type, ~pod_name, ~fyear,
  2018, "RXX", 8800, "ip", "Elective Admission", "2018/19",
  2018, "RXX", 58000, "ip", "Daycase Admission", "2018/19",
  2018, "RXX", 1100, "ip", "Maternity Admission", "2018/19",
  2018, "RXX", 60000, "ip", "Non-Elective Admission", "2018/19",
  2018, "RXX", 140000, "op", "First Outpatient Attendance", "2018/19",
  2018, "RXX", 370000, "op", "Follow-up Outpatient Attendance", "2018/19",
  2018, "RXX", 42000, "op", "Outpatient Procedure", "2018/19",
  2018, "trust", 135000, "aae", "A&E Attendance", "2018/19",
  2019, "RXX", 9750, "ip", "Elective Admission", "2019/20",
  2019, "RXX", 66000, "ip", "Daycase Admission", "2019/20",
  2019, "RXX", 1150, "ip", "Maternity Admission", "2019/20",
  2019, "RXX", 65000, "ip", "Non-Elective Admission", "2019/20",
  2019, "RXX", 145000, "op", "First Outpatient Attendance", "2019/20",
  2019, "RXX", 380000, "op", "Follow-up Outpatient Attendance", "2019/20",
  2019, "RXX", 44500, "op", "Outpatient Procedure", "2019/20",
  2019, "trust", 136000, "aae", "A&E Attendance", "2019/20",
  2020, "RXX", 10700, "ip", "Elective Admission", "2020/21",
  2020, "RXX", 74000, "ip", "Daycase Admission", "2020/21",
  2020, "RXX", 1200, "ip", "Maternity Admission", "2020/21",
  2020, "RXX", 70000, "ip", "Non-Elective Admission", "2020/21",
  2020, "RXX", 150000, "op", "First Outpatient Attendance", "2020/21",
  2020, "RXX", 390000, "op", "Follow-up Outpatient Attendance", "2020/21",
  2020, "RXX", 47000, "op", "Outpatient Procedure", "2020/21",
  2020, "trust", 137000, "aae", "A&E Attendance", "2020/21"
) |>
  dplyr::mutate(dplyr::across(pod_name, \(.x) factor(.x, levels(pods_expected$pod_name))))

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_principal_high_level_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_high_level_pods returns the correct list of pods", {
  stub(mod_principal_high_level_pods, "get_activity_type_pod_measure_options", atpmo_expected)
  expect_equal(mod_principal_high_level_pods(), pods_expected)
})

test_that("mod_principal_high_level_summary_data processes data correctly", {
  m <- mock(c(2018, 2020), principal_high_level_expected)
  stub(mod_principal_high_level_summary_data, "get_model_run_years", m)
  stub(mod_principal_high_level_summary_data, "get_principal_high_level", m)

  actual <- mod_principal_high_level_summary_data(1, pods_expected)
  expect_equal(actual, summary_data_expected)
})

test_that("mod_principal_high_level_table returns a gt", {
  set.seed(1) # ensure gt id always regenerated identically

  table <- mod_principal_high_level_table(summary_data_expected)

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

test_that("it creates the table", {
  m <- mock()
  stub(mod_principal_high_level_server, "gt::render_gt", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_table", NULL)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal()), {
    expect_called(m, 1)
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
