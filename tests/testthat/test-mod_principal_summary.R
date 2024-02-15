library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(mod_principal_summary_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_summary_data summarises the data", {
  m1 <- mock(
    tibble::tribble(
      ~pod, ~baseline, ~principal,
      "a_1", 1, 2,
      "a_2", 3, 4,
      "b_1", 4, 5,
      "b_2", 6, 7,
      "c_1", 8, 9
    ),
    cycle = TRUE
  )
  m2 <- mock(
    tibble::tribble(
      ~quarter, ~model_run, ~baseline, ~principal,
      "q1", 1, 1, 2,
      "q1", 1, 3, 4,
      "q2", 1, 1, 2,
      "q2", 1, 3, 4,
      "q1", 2, 1, 2,
      "q1", 2, 3, 4,
      "q2", 2, 1, 2,
      "q2", 2, 3, 4,
    )
  )

  expected <- tibble::tribble(
    ~pod_name, ~activity_type, ~baseline, ~principal,
    "A 1", "Inpatient", 1, 2,
    "A 1", "Inpatient", 1, 2,
    "A 1", "Inpatient", 1, 2,
    "A 2", "Inpatient", 3, 4,
    "A 2", "Inpatient", 3, 4,
    "A 2", "Inpatient", 3, 4,
    "B 1", "Outpatient", 4, 5,
    "B 1", "Outpatient", 4, 5,
    "B 1", "Outpatient", 4, 5,
    "B 2", "A&E", 6, 7,
    "B 2", "A&E", 6, 7,
    "B 2", "A&E", 6, 7,
    "Beds Available", "Beds Available", 4, 6
  ) |>
    dplyr::mutate(
      activity_type = forcats::as_factor(activity_type),
      change = principal - baseline,
      change_pcnt = change / baseline
    )

  stub(
    mod_principal_summary_data,
    "mod_principal_high_level_pods",
    tibble::tibble(
      activity_type = c("ip", "ip", "op", "aae"),
      pod = c("a_1", "a_2", "b_1", "b_2"),
      pod_name = c("A 1", "A 2", "B 1", "B 2")
    )
  )

  stub(mod_principal_summary_data, "get_principal_high_level", m1)
  stub(mod_principal_summary_data, "get_bed_occupancy", m2)

  actual <- mod_principal_summary_data("data", character())

  expect_called(m1, 3)
  expect_called(m2, 1)

  expect_args(m1, 1, "data", c("admissions", "attendances", "walk-in", "ambulance"), character())
  expect_args(m1, 2, "data", "tele_attendances", character())
  expect_args(m1, 3, "data", "beddays", character())
  expect_args(m2, 1, "data")

  expect_equal(actual, expected)
})

test_that("mod_principal_summary_data doesn't show bed occupancy if all sites aren't selected", {
  m1 <- mock(
    tibble::tribble(
      ~pod, ~baseline, ~principal,
      "a_1", 1, 2,
      "a_2", 3, 4,
      "b_1", 4, 5,
      "b_2", 6, 7,
      "c_1", 8, 9
    ),
    cycle = TRUE
  )
  m2 <- mock(
    tibble::tribble(
      ~quarter, ~model_run, ~baseline, ~principal,
      "q1", 1, 1, 2,
      "q1", 1, 3, 4,
      "q2", 1, 1, 2,
      "q2", 1, 3, 4,
      "q1", 2, 1, 2,
      "q1", 2, 3, 4,
      "q2", 2, 1, 2,
      "q2", 2, 3, 4,
    )
  )

  stub(
    mod_principal_summary_data,
    "mod_principal_high_level_pods",
    tibble::tibble(
      activity_type = c("ip", "ip", "op", "aae"),
      pod = c("a_1", "a_2", "b_1", "b_2"),
      pod_name = c("A 1", "A 2", "B 1", "B 2")
    )
  )

  stub(mod_principal_summary_data, "get_principal_high_level", m1)
  stub(mod_principal_summary_data, "get_bed_occupancy", m2)

  mod_principal_summary_data("data", "a")

  expect_called(m2, 0)
})

test_that("mod_principal_summary_table creates a gt object", {
  set.seed(1)

  data <- tibble::tibble(
    pod_name = c("a", "b", "c"),
    baseline = 1:3,
    principal = 4:6
  ) |>
    dplyr::mutate(
      change = principal - baseline,
      change_pcnt = change / baseline
    )

  table <- mod_principal_summary_table(data)

  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


test_that("it sets up the reactives correctly", {
  d <- tibble::tibble(
    value = 1:2
  )
  m <- mock(d, cycle = TRUE)

  stub(mod_principal_summary_server, "mod_principal_summary_data", m)

  shiny::testServer(mod_principal_summary_server, args = list(reactiveVal(), reactiveVal()), {
    selected_data(1)
    selected_site("a")

    expect_equal(summary_data(), d)
  })

  expect_called(m, 1)
  expect_args(m, 1, 1, "a")
})

test_that("it creates the table", {
  m <- mock()
  stub(mod_principal_summary_server, "gt::render_gt", m)
  stub(mod_principal_summary_server, "mod_principal_summary_data", NULL)
  stub(mod_principal_summary_server, "mod_principal_summary_table", NULL)

  shiny::testServer(mod_principal_summary_server, args = list(reactiveVal()), {
    expect_called(m, 1)
  })
})
