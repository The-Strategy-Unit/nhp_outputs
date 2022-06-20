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
  "ip", "Inpatients", "ip_non-elective_birth-episode", "Birth Episode", "admissions",
  "ip", "Inpatients", "ip_non-elective_birth-episode", "Birth Episode", "beddays",
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
  "ip", "ip_non-elective_birth-episode", "Birth Episode",
  "op", "op_first", "First Outpatient Attendance",
  "op", "op_follow-up", "Follow-up Outpatient Attendance",
  "op", "op_procedure", "Outpatient Procedure",
  "aae", "aae", "A&E Attendance"
) |>
  dplyr::mutate(dplyr::across(pod_name, forcats::fct_inorder))

principal_high_level_expected <- tibble::tribble(
  ~pod,                          ~baseline, ~principal,
  "aae",                            135000,     137000,
  "ip_elective_admission",            8800,      10700,
  "ip_elective_daycase",             58000,      74000,
  "ip_non-elective_admission",       60000,      70000,
  "ip_non-elective_birth-episode",    1100,       1200,
  "op_first",                       140000,     150000,
  "op_follow-up",                   370000,     390000,
  "op_procedure",                    42000,      47000
)

summary_data_expected <- tibble::tribble(
  ~year, ~value, ~activity_type, ~pod_name, ~fyear,
  2018, 135000, "aae", "A&E Attendance", "2018/19",
  2018, 8800, "ip", "Elective Admission", "2018/19",
  2018, 58000, "ip", "Daycase Admission", "2018/19",
  2018, 60000, "ip", "Non-Elective Admission", "2018/19",
  2018, 1100, "ip", "Birth Episode", "2018/19",
  2018, 140000, "op", "First Outpatient Attendance", "2018/19",
  2018, 370000, "op", "Follow-up Outpatient Attendance", "2018/19",
  2018, 42000, "op", "Outpatient Procedure", "2018/19",
  2019, 136000, "aae", "A&E Attendance", "2019/20",
  2019, 9750, "ip", "Elective Admission", "2019/20",
  2019, 66000, "ip", "Daycase Admission", "2019/20",
  2019, 65000, "ip", "Non-Elective Admission", "2019/20",
  2019, 1150, "ip", "Birth Episode", "2019/20",
  2019, 145000, "op", "First Outpatient Attendance", "2019/20",
  2019, 380000, "op", "Follow-up Outpatient Attendance", "2019/20",
  2019, 44500, "op", "Outpatient Procedure", "2019/20",
  2020, 137000, "aae", "A&E Attendance", "2020/21",
  2020, 10700, "ip", "Elective Admission", "2020/21",
  2020, 74000, "ip", "Daycase Admission", "2020/21",
  2020, 70000, "ip", "Non-Elective Admission", "2020/21",
  2020, 1200, "ip", "Birth Episode", "2020/21",
  2020, 150000, "op", "First Outpatient Attendance", "2020/21",
  2020, 390000, "op", "Follow-up Outpatient Attendance", "2020/21",
  2020, 47000, "op", "Outpatient Procedure", "2020/21"
) |>
  dplyr::mutate(dplyr::across(pod_name, factor, levels(pods_expected$pod_name)))

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
  stub(mod_principal_high_level_summary_data, "cosmos_get_model_run_years", m)
  stub(mod_principal_high_level_summary_data, "cosmos_get_principal_high_level", m)

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
  stub(mod_principal_high_level_server, "get_data_cache", "session")
  stub(mod_principal_high_level_server, "mod_principal_high_level_pods", m)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal(1)), {
    expect_called(m, 1)
    expect_equal(pods, "pods")
  })
})

test_that("it gets the summary data", {
  m <- mock("summary data")
  stub(mod_principal_high_level_server, "get_data_cache", "session")
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
  stub(mod_principal_high_level_server, "get_data_cache", "session")
  stub(mod_principal_high_level_server, "gt::render_gt", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_table", NULL)

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal()), {
    expect_called(m, 1)
  })
})

test_that("it creates 3 plots", {
  m <- mock()
  stub(mod_principal_high_level_server, "get_data_cache", "session")
  stub(mod_principal_high_level_server, "plotly::renderPlotly", m)
  stub(mod_principal_high_level_server, "mod_principal_high_level_summary_data", NULL)
  stub(mod_principal_high_level_server, "mod_principal_high_level_plot", ggplot2::ggplot())

  shiny::testServer(mod_principal_high_level_server, args = list(reactiveVal()), {
    expect_called(m, 3)
  })
})
