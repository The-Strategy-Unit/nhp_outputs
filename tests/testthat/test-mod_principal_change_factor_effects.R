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
    ~measure, ~change_factor, ~value, ~strategy,
    "arrivals", "baseline", 100000, "-",
    "arrivals", "frequent_attenders", -4000, "-",
    "arrivals", "health_status_adjustment", -1000, "-",
    "arrivals", "left_before_seen", -500, "-",
    "arrivals", "low_cost_discharged", -6000, "-",
    "arrivals", "population_factors", 14000, "-"
  ),
  ip = tibble::tribble(
    ~measure, ~change_factor, ~value, ~strategy,
    "admissions", "baseline", 100000, "-",
    "admissions", "population_factors", 15000, "-",
    "admissions", "health_status_adjustment", -1000, "-",
    "admissions", "admission_avoidance", -100, "alcohol_wholly_attributable",
    "admissions", "admission_avoidance", -250, "ambulatory_care_conditions_acute",
    "admissions", "admission_avoidance", -300, "ambulatory_care_conditions_chronic",
    "beddays", "baseline", 200000, "-",
    "beddays", "population_factors", 30000, "-",
    "beddays", "health_status_adjustment", -2000, "-",
    "beddays", "admission_avoidance", -200, "alcohol_wholly_attributable",
    "beddays", "admission_avoidance", -500, "ambulatory_care_conditions_acute",
    "beddays", "admission_avoidance", -600, "ambulatory_care_conditions_chronic"
  )
) |>
  purrr::map(~ dplyr::mutate(
    .x,
    dplyr::across(.data$change_factor, forcats::fct_inorder),
    dplyr::across(
      .data$change_factor,
      forcats::fct_relevel,
      "baseline",
      "population_factors",
      "health_status_adjustment"
    )
  ))

change_factors_summarised_expected_inc_baseline <- tibble::tribble(
  ~change_factor, ~colour, ~name, ~value,
  "baseline", "#f9bf07", "value", 100000,
  "baseline", NA, "hidden", 0,
  "population_factors", "#f9bf07", "value", 15000,
  "population_factors", NA, "hidden", 100000,
  "admission_avoidance", "#2c2825", "value", 650,
  "admission_avoidance", NA, "hidden", 114350,
  "health_status_adjustment", "#2c2825", "value", 1000,
  "health_status_adjustment", NA, "hidden", 113350,
  "Estimate", "#ec6555", "value", 113350,
  "Estimate", NA, "hidden", 0
) |>
  dplyr::mutate(
    dplyr::across(
      change_factor,
      forcats::fct_relevel,
      "Estimate", "health_status_adjustment", "admission_avoidance", "population_factors", "baseline"
    ),
    dplyr::across(
      name, forcats::fct_relevel, c("hidden", "value")
    )
  )

change_factors_summarised_expected_exc_baseline <- tibble::tribble(
  ~change_factor, ~colour, ~name, ~value,
  "population_factors", "#f9bf07", "value", 15000,
  "population_factors", NA, "hidden", 0,
  "admission_avoidance", "#2c2825", "value", 650,
  "admission_avoidance", NA, "hidden", 14350,
  "health_status_adjustment", "#2c2825", "value", 1000,
  "health_status_adjustment", NA, "hidden", 13350,
  "Estimate", "#ec6555", "value", 13350,
  "Estimate", NA, "hidden", 0
) |>
  dplyr::mutate(
    dplyr::across(
      change_factor,
      forcats::fct_relevel,
      "Estimate", "health_status_adjustment", "admission_avoidance", "population_factors"
    ),
    dplyr::across(
      name, forcats::fct_relevel, c("hidden", "value")
    )
  )

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  expect_snapshot(mod_principal_change_factor_effects_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("mod_principal_change_factor_effects_summarised returns correct data", {
  actual <- mod_principal_change_factor_effects_summarised(
    change_factors_expected$ip, "admissions", TRUE
  )
  expect_equal(actual, change_factors_summarised_expected_inc_baseline)

  actual <- mod_principal_change_factor_effects_summarised(
    change_factors_expected$ip, "admissions", FALSE
  )
  expect_equal(actual, change_factors_summarised_expected_exc_baseline)
})

test_that("mod_principal_change_factor_effects_cf_plot returns a ggplot", {
  p <- mod_principal_change_factor_effects_cf_plot(change_factors_summarised_expected_inc_baseline)
  expect_s3_class(p, "ggplot")
})

test_that("mod_principal_change_factor_effects_ind_plot returns a ggplot", {
  p <- mod_principal_change_factor_effects_ind_plot(change_factors_expected$ip, "admission_avoidance", "#f9bf07")
  expect_s3_class(p, "ggplot")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it sets up the activity_type dropdown", {
  m <- mock()

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "shiny::updateSelectInput", m)

  selected_model_id <- reactiveVal()

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    session$private$flush() # need to trigger an invalidation
    expect_called(m, 1)
    expect_args(m, 1, session, "activity_type", c("A&E" = "aae", "Inpatients" = "ip", "Outpatients" = "op"))
  })
})

test_that("it loads the data from cosmos when the activity_type or id changes", {
  m <- mock(change_factors_expected$aae, cycle = TRUE)

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "cosmos_get_principal_change_factors", m)

  selected_model_id <- reactiveVal()

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    selected_model_id(1)
    expect_called(m, 0)

    session$setInputs("activity_type" = "aae")
    expect_equal(principal_change_factors(), change_factors_expected$aae)

    selected_model_id(2)
    expect_equal(principal_change_factors(), change_factors_expected$aae)

    expect_called(m, 2)
    expect_args(m, 1, 1, "aae")
    expect_args(m, 2, 2, "aae")
  })
})

test_that("it updates the measures dropdown when the change factors updates", {
  m <- mock()
  cfe <- \(id, at) change_factors_expected[[at]]

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "cosmos_get_principal_change_factors", cfe)
  stub(mod_principal_change_factor_effects_server, "shiny::updateSelectInput", m)

  selected_model_id <- reactiveVal()

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    selected_model_id(1)

    session$setInputs("activity_type" = "aae")
    principal_change_factors()

    session$setInputs("activity_type" = "ip")
    principal_change_factors()

    expect_called(m, 3)
    expect_args(m, 2, session, "measure", choices = c("arrivals"))
    expect_args(m, 3, session, "measure", choices = c("admissions", "beddays"))
  })
})

test_that("it sets up the individual change factors", {
  cfe <- \(id, at) change_factors_expected[[at]]

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "cosmos_get_principal_change_factors", cfe)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_ind_plot", NULL)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_cf_plot", NULL)

  selected_model_id <- reactiveVal()

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    selected_model_id(1)
    session$setInputs(
      activity_type = "ip", measure = "admissions", sort_type = "descending value", include_baseline = TRUE
    )

    expected <- change_factors_expected$ip |>
      dplyr::filter(measure == "admissions", strategy != "-", value < 0)

    expected_1 <- expected |>
      dplyr::mutate(dplyr::across(strategy, forcats::fct_reorder, -value))

    expect_equal(individual_change_factors(), expected_1)

    session$setInputs(sort_type = "ascending value")
    expected_2 <- expected |>
      dplyr::mutate(dplyr::across(strategy, forcats::fct_reorder, strategy))

    expect_equal(individual_change_factors(), expected_2)
  })
})

test_that("it shows or hides the individual plots", {
  m <- mock()
  cfe <- \(id, at) change_factors_expected[[at]]

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "cosmos_get_principal_change_factors", cfe)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_ind_plot", NULL)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_cf_plot", NULL)
  stub(mod_principal_change_factor_effects_server, "shinyjs::toggle", m)

  selected_model_id <- reactiveVal()

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    selected_model_id(1)

    session$setInputs(
      activity_type = "aae", measure = "ambulance", sort_type = "descending value", include_baseline = TRUE
    )

    session$setInputs(
      activity_type = "ip", measure = "admissions", sort_type = "descending value", include_baseline = TRUE
    )

    expect_called(m, 2)
    expect_args(m, 1, "individual_change_factors", condition = FALSE)
    expect_args(m, 2, "individual_change_factors", condition = TRUE)
  })
})

test_that("it renders the plots", {
  m <- mock()
  cfe <- \(id, at) change_factors_expected[[at]]

  stub(mod_principal_change_factor_effects_server, "get_activity_type_pod_measure_options", atpmo_expected)
  stub(mod_principal_change_factor_effects_server, "cosmos_get_principal_change_factors", cfe)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_summarised", "cfd")
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_cf_plot", m)
  stub(mod_principal_change_factor_effects_server, "mod_principal_change_factor_effects_ind_plot", m)

  selected_model_id <- reactiveVal(1)

  testServer(mod_principal_change_factor_effects_server, args = list(selected_model_id), {
    session$setInputs(
      activity_type = "ip", measure = "admissions", sort_type = "descending value", include_baseline = TRUE
    )
    selected_model_id(1)

    expect_called(m, 3)
    expect_args(m, 1, "cfd")
    expect_equal(mock_args(m)[[2]][-1], list("admission_avoidance", "#f9bf07"))
    expect_equal(mock_args(m)[[3]][-1], list("los_reduction", "#ec6555"))
  })
})
