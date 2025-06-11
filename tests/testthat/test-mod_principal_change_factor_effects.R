library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

atpmo_expected <- tibble::tribble(
  ~activity_type, ~activity_type_name, ~pod, ~pod_name, ~measures,
  "aae", "A&E", "aae_type-01", "Type 1 Department", "ambulance",
  "aae", "A&E", "aae_type-01", "Type 1 Department", "walk-in",
  "ip", "Inpatients", "ip_elective_admission", "Elective Admission", "admissions",
  "ip", "Inpatients", "ip_elective_admission", "Elective Admission", "beddays",
  "op", "Outpatients", "op_first", "First Outpatient Attendance", "attendances",
  "op", "Outpatients", "op_first", "First Outpatient Attendance", "tele_attendances"
)

change_factors_expected <- list(
  aae = tibble::tribble(
    ~pod, ~sitetret, ~measure, ~change_factor, ~strategy, ~mitigator_name, ~value,
    "aae_type-01", "R00", "arrivals", "baseline", "-", "-", 100000,
    "aae_type-01", "R00", "arrivals", "frequent_attenders", "-", "-", -4000,
    "aae_type-01", "R00", "arrivals", "health_status_adjustment", "-", "-", -1000,
    "aae_type-01", "R00", "arrivals", "left_before_seen", "-", "-", -500,
    "aae_type-01", "R00", "arrivals", "low_cost_discharged", "-", "-", -6000,
    "aae_type-01", "R00", "arrivals", "demographic_adjustment", "-", "-", 14000
  ),
  ip = tibble::tribble(
    ~pod, ~sitetret, ~measure, ~change_factor, ~strategy, ~mitigator_name, ~value,
    "ip_elective_admission", "R00", "admissions", "baseline", "-", "-", 100000,
    "ip_elective_admission", "R00", "admissions", "demographic_adjustment", "-", "-", 15000,
    "ip_elective_admission", "R00", "admissions", "health_status_adjustment", "-", "-", -1000,
    "ip_elective_admission", "R00", "admissions", "activity_avoidance", "alcohol_wholly_attributable", "Alcohol Related Admissions (Wholly Attributable) (IP-AA-003)", -100,
    "ip_elective_admission", "R00", "admissions", "activity_avoidance", "ambulatory_care_conditions_acute", "Ambulatory Care Sensitive Admissions (Acute Conditions) (IP-AA-004)", -250,
    "ip_elective_admission", "R00", "admissions", "activity_avoidance", "ambulatory_care_conditions_chronic", "Ambulatory Care Sensitive Admissions (Chronic Conditions) (IP-AA-005)", -300,
    "ip_elective_admission", "R00", "beddays", "baseline", "-", "-", 200000,
    "ip_elective_admission", "R00", "beddays", "demographic_adjustment", "-", "-", 30000,
    "ip_elective_admission", "R00", "beddays", "health_status_adjustment", "-", "-", -2000,
    "ip_elective_admission", "R00", "beddays", "activity_avoidance", "alcohol_wholly_attributable", "Alcohol Related Admissions (Wholly Attributable) (IP-AA-003)", -200,
    "ip_elective_admission", "R00", "beddays", "activity_avoidance", "ambulatory_care_conditions_acute", "Ambulatory Care Sensitive Admissions (Acute Conditions) (IP-AA-004)", -500,
    "ip_elective_admission", "R00", "beddays", "activity_avoidance", "ambulatory_care_conditions_chronic", "Ambulatory Care Sensitive Admissions (Chronic Conditions) (IP-AA-005)", -600
  )
) |>
  purrr::map(
    ~ dplyr::mutate(
      .x,
      dplyr::across("change_factor", forcats::fct_inorder),
      dplyr::across(
        "change_factor",
        \(.x) {
          forcats::fct_relevel(
            .x,
            "baseline",
            "demographic_adjustment",
            "health_status_adjustment"
          )
        }
      )
    )
  )

change_factors_summarised_expected_inc_baseline <- tibble::tribble(
  ~change_factor, ~colour, ~name, ~value,
  "baseline", "#f9bf07", "value", 100000,
  "baseline", NA, "hidden", 0,
  "demographic_adjustment", "#f9bf07", "value", 15000,
  "demographic_adjustment", NA, "hidden", 100000,
  "activity_avoidance", "#2c2825", "value", 650,
  "activity_avoidance", NA, "hidden", 114350,
  "health_status_adjustment", "#2c2825", "value", 1000,
  "health_status_adjustment", NA, "hidden", 113350,
  "Estimate", "#ec6555", "value", 113350,
  "Estimate", NA, "hidden", 0
) |>
  dplyr::mutate(
    dplyr::across(
      "change_factor",
      \(.x) {
        forcats::fct_relevel(
          .x,
          "Estimate",
          "health_status_adjustment",
          "activity_avoidance",
          "demographic_adjustment",
          "baseline"
        )
      }
    ),
    dplyr::across(
      "name",
      \(.x) forcats::fct_relevel(.x, c("hidden", "value"))
    )
  )

change_factors_summarised_expected_exc_baseline <- tibble::tribble(
  ~change_factor, ~colour, ~name, ~value,
  "demographic_adjustment", "#f9bf07", "value", 15000,
  "demographic_adjustment", NA, "hidden", 0,
  "activity_avoidance", "#2c2825", "value", 650,
  "activity_avoidance", NA, "hidden", 14350,
  "health_status_adjustment", "#2c2825", "value", 1000,
  "health_status_adjustment", NA, "hidden", 13350,
  "Estimate", "#ec6555", "value", 13350,
  "Estimate", NA, "hidden", 0
) |>
  dplyr::mutate(
    dplyr::across(
      "change_factor",
      \(.x) {
        forcats::fct_relevel(
          .x,
          "Estimate",
          "health_status_adjustment",
          "activity_avoidance",
          "demographic_adjustment"
        )
      }
    ),
    dplyr::across(
      "name",
      \(.x) forcats::fct_relevel(.x, c("hidden", "value"))
    )
  )

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(123)
  expect_snapshot(mod_principal_change_factor_effects_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_change_factor_effects_summarised returns correct data", {
  actual <- mod_principal_change_factor_effects_summarised(
    change_factors_expected$ip,
    "admissions",
    TRUE
  )
  expect_equal(actual, change_factors_summarised_expected_inc_baseline)

  actual <- mod_principal_change_factor_effects_summarised(
    change_factors_expected$ip,
    "admissions",
    FALSE
  )
  expect_equal(actual, change_factors_summarised_expected_exc_baseline)
})

test_that("mod_principal_change_factor_effects_cf_plot returns a ggplot", {
  p <- mod_principal_change_factor_effects_cf_plot(
    change_factors_summarised_expected_inc_baseline
  )
  expect_s3_class(p, "ggplot")
})

test_that("mod_principal_change_factor_effects_ind_plot returns a ggplot", {
  p <- mod_principal_change_factor_effects_ind_plot(
    change_factors_expected$ip,
    "activity_avoidance",
    "#f9bf07",
    "Activity Avoidance",
    "Admissions"
  )
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it sets up the activity_type dropdown", {
  m <- mock()

  stub(
    mod_principal_change_factor_effects_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_principal_change_factor_effects_server,
    "shiny::updateSelectInput",
    m
  )

  selected_data <- reactiveVal()
  selected_sites <- reactiveVal()

  testServer(
    mod_principal_change_factor_effects_server,
    args = list(selected_data, selected_sites),
    {
      session$private$flush() # need to trigger an invalidation
      selected_sites("R00")
      session$private$flush()
      expect_called(m, 1)
      expect_args(
        m,
        1,
        session,
        "activity_type",
        c("A&E" = "aae", "Inpatients" = "ip", "Outpatients" = "op")
      )
    }
  )
})

test_that("it loads the data from when the activity_type or id changes", {
  m <- mock(
    dplyr::select(change_factors_expected$aae, -"mitigator_name"),
    cycle = TRUE
  )

  stub(
    mod_principal_change_factor_effects_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_principal_change_factor_effects_server,
    "get_principal_change_factors",
    m
  )

  selected_data <- reactiveVal()
  selected_sites <- reactiveVal("R00")

  testServer(
    mod_principal_change_factor_effects_server,
    args = list(selected_data, selected_sites),
    {
      selected_data(1)
      expect_called(m, 0)

      expected <- change_factors_expected$aae

      session$setInputs("activity_type" = "aae")
      expect_equal(principal_change_factors_raw()[colnames(expected)], expected)

      selected_data(2)
      expect_equal(principal_change_factors_raw()[colnames(expected)], expected)

      expect_called(m, 2)
      expect_args(m, 1, 1, "aae", "R00")
      expect_args(m, 2, 2, "aae", "R00")
    }
  )
})

test_that("it updates the measures dropdown when the change factors updates", {
  m <- mock()
  cfe <- \(id, at, ...) {
    change_factors_expected[[at]] |>
      dplyr::select(-"mitigator_name")
  }

  stub(
    mod_principal_change_factor_effects_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_principal_change_factor_effects_server,
    "get_principal_change_factors",
    cfe
  )
  stub(
    mod_principal_change_factor_effects_server,
    "shiny::updateSelectInput",
    m
  )

  selected_data <- reactiveVal()
  selected_sites <- reactiveVal("R00")

  testServer(
    mod_principal_change_factor_effects_server,
    args = list(selected_data, selected_sites),
    {
      selected_data(1)

      session$setInputs("activity_type" = "aae")
      principal_change_factors_raw()

      session$setInputs("activity_type" = "ip")
      principal_change_factors_raw()

      expect_called(m, 5)
      expect_args(
        m,
        1,
        session,
        "activity_type",
        choices = c("A&E" = "aae", Inpatients = "ip", Outpatients = "op")
      )
      expect_args(
        m,
        2,
        session,
        "pods",
        choices = c(`Type 1 Department` = "aae_type-01"),
        selected = "aae_type-01"
      )
      expect_args(
        m,
        3,
        session,
        "measure",
        choices = c(Arrivals = "arrivals"),
        selected = "arrivals"
      )
      expect_args(
        m,
        4,
        session,
        "pods",
        choices = c(`Elective Admission` = "ip_elective_admission"),
        selected = "ip_elective_admission"
      )
      expect_args(
        m,
        5,
        session,
        "measure",
        choices = c(Admissions = "admissions", Beddays = "beddays"),
        selected = "beddays"
      )
    }
  )
})

test_that("it sets up the individual change factors", {
  cfe <- \(id, at, ...) {
    change_factors_expected[[at]] |>
      dplyr::select(-"mitigator_name")
  }

  stub(
    mod_principal_change_factor_effects_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_principal_change_factor_effects_server,
    "get_principal_change_factors",
    cfe
  )
  stub(
    mod_principal_change_factor_effects_server,
    "mod_principal_change_factor_effects_ind_plot",
    NULL
  )
  stub(
    mod_principal_change_factor_effects_server,
    "mod_principal_change_factor_effects_cf_plot",
    NULL
  )

  selected_data <- reactiveVal()
  selected_sites <- reactiveVal("R00")

  testServer(
    mod_principal_change_factor_effects_server,
    args = list(selected_data, selected_sites),
    {
      selected_data(1)
      session$setInputs(activity_type = "ip")
      session$setInputs(pods = "ip_elective_admission")
      session$setInputs(measure = "admissions")
      session$setInputs(sort_type = "Descending value")
      session$setInputs(include_baseline = TRUE)

      expected <- change_factors_expected$ip |>
        dplyr::filter(measure == "admissions", strategy != "-", value < 0)

      expected_1 <- expected |>
        dplyr::mutate(
          dplyr::across(
            "mitigator_name",
            \(.x) forcats::fct_reorder(.x, -.data[["value"]])
          )
        ) |>
        dplyr::select(-"pod")

      expect_equal(individual_change_factors(), expected_1)

      session$setInputs(sort_type = "Alphabetical")
      expected_2 <- expected |>
        dplyr::mutate(
          dplyr::across(
            "mitigator_name",
            \(.x) {
              forcats::fct_rev(forcats::fct_reorder(
                .x,
                .data[["mitigator_name"]]
              ))
            }
          )
        ) |>
        dplyr::select(-"pod")

      expect_equal(individual_change_factors(), expected_2)
    }
  )
})

test_that("it renders the plots", {
  m <- mock()
  cfe <- \(id, at, ...) {
    change_factors_expected[[at]] |>
      dplyr::select(-"mitigator_name")
  }

  stub(
    mod_principal_change_factor_effects_server,
    "get_activity_type_pod_measure_options",
    atpmo_expected
  )
  stub(
    mod_principal_change_factor_effects_server,
    "get_principal_change_factors",
    cfe
  )
  stub(
    mod_principal_change_factor_effects_server,
    "mod_principal_change_factor_effects_summarised",
    "cfd"
  )
  stub(
    mod_principal_change_factor_effects_server,
    "mod_principal_change_factor_effects_cf_plot",
    m
  )
  stub(
    mod_principal_change_factor_effects_server,
    "mod_principal_change_factor_effects_ind_plot",
    m
  )

  selected_data <- reactiveVal(1)
  selected_sites <- reactiveVal("R00")

  testServer(
    mod_principal_change_factor_effects_server,
    args = list(selected_data, selected_sites),
    {
      session$setInputs(activity_type = "ip")
      session$setInputs(pods = "ip_elective_admission")
      session$setInputs(measure = "admissions")
      session$setInputs(sort_type = "descending value")
      session$setInputs(include_baseline = TRUE)
      selected_data(1)

      expect_called(m, 7)
      expect_args(m, 3, "cfd")

      expect_equal(
        mock_args(m)[[6]][-1],
        list(
          "activity_avoidance",
          "#f9bf07",
          "Activity Avoidance",
          "Admissions"
        )
      )
      expect_equal(
        mock_args(m)[[7]][-1],
        list("efficiencies", "#ec6555", "Efficiencies", "Admissions")
      )
    }
  )
})
