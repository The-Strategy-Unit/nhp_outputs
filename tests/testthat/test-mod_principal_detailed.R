library(shiny)
library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# setup
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

selected_measure_expected <- c(
  activity_type = "aae",
  pod = "aae_type-01",
  measure = "ambulance"
)

available_aggregations_expected <- list(
  aae = c("default", "sex+age_group"),
  ip = c("default", "sex+age_group", "mainspef", "sex+tretspef"),
  op = c("default", "sex+age_group", "sex+tretspef")
)

aggregations_age_group_expected <- tibble::tribble(
  ~sex,
  ~age_group,
  ~baseline,
  ~principal,
  ~median,
  ~lwr_pi,
  ~upr_pi,
  1,
  " 0- 4",
  900,
  800,
  850,
  825,
  875,
  1,
  " 5-14",
  650,
  550,
  600,
  625,
  650
)

aggregations_tretspef_expected <- tibble::tribble(
  ~sex,
  ~tretspef,
  ~baseline,
  ~principal,
  ~median,
  ~lwr_pi,
  ~upr_pi,
  1,
  "100: General Surgery",
  900,
  800,
  850,
  825,
  875,
  1,
  "300: General Internal Medicine",
  650,
  550,
  600,
  625,
  650
)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# ui
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("ui is created correctly", {
  set.seed(1)
  expect_snapshot(mod_principal_detailed_ui("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# helpers
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("table returns a gt", {
  set.seed(1)

  data <- aggregations_age_group_expected |>
    dplyr::transmute(
      sex,
      agg = age_group,
      baseline,
      final = principal,
      change = final - baseline,
      change_pcnt = change / baseline
    )

  table <- mod_principal_detailed_table(data, "Age Group", "2040/41")

  expect_s3_class(table, "gt_tbl")
  expect_snapshot(gt::as_raw_html(table))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# server
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("it sets up mod_measure_selection_server", {
  m <- mock("mod_measure_selection_server")

  stub(mod_principal_detailed_server, "mod_measure_selection_server", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      expect_called(m, 1)
      expect_args(m, 1, "measure_selection")
      expect_equal(selected_measure, "mod_measure_selection_server")
    }
  )
})

test_that("it calls get_available_aggregations", {
  m <- mock("get_available_aggregations")

  stub(mod_principal_detailed_server, "get_available_aggregations", m)
  stub(mod_principal_detailed_server, "shiny::updateSelectInput", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      selected_data(1)
      expect_equal(available_aggregations(), "get_available_aggregations")
      expect_called(m, 1)
      expect_args(m, 1, 1)
    }
  )
})

test_that("it updates the aggregation drop down", {
  m <- mock()

  stub(
    mod_principal_detailed_server,
    "mod_measure_selection_server",
    reactiveVal
  )
  stub(
    mod_principal_detailed_server,
    "get_available_aggregations",
    available_aggregations_expected
  )
  stub(mod_principal_detailed_server, "shiny::updateSelectInput", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal()

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      selected_data(1)
      selected_measure(selected_measure_expected)
      session$private$flush() # manually trigger an invalidation

      expect_called(m, 1)
      expect_args(m, 1, session, "aggregation", "Age Group")
    }
  )
})

test_that("it calls get_aggregation", {
  m <- mock(aggregations_age_group_expected, aggregations_tretspef_expected)

  stub(
    mod_principal_detailed_server,
    "mod_measure_selection_server",
    reactiveVal
  )
  stub(
    mod_principal_detailed_server,
    "get_available_aggregations",
    available_aggregations_expected
  )
  stub(mod_principal_detailed_server, "get_aggregation", m)

  selected_data <- reactiveVal()
  selected_site <- reactiveVal("a")

  testServer(
    mod_principal_detailed_server,
    args = list(selected_data, selected_site),
    {
      selected_data(1)
      selected_measure(selected_measure_expected)

      expected <- aggregations_age_group_expected |>
        dplyr::transmute(
          sex,
          agg = age_group,
          baseline,
          final = principal,
          change = final - baseline,
          change_pcnt = change / baseline
        )
      session$setInputs(aggregation = "Age Group")
      expect_equal(aggregated_data(), expected)

      expected <- aggregations_tretspef_expected |>
        dplyr::transmute(
          sex,
          agg = tretspef,
          baseline,
          final = principal,
          change = final - baseline,
          change_pcnt = change / baseline
        )
      session$setInputs(aggregation = "Treatment Specialty")

      expect_equal(aggregated_data(), expected)

      expect_called(m, 2)
      expect_args(m, 1, 1, "aae_type-01", "ambulance", "age_group", "a")
      expect_args(m, 2, 1, "aae_type-01", "ambulance", "tretspef", "a")
    }
  )
})

# TODO: fix test (broken with introduction of end_fyear)
# test_that("it renders the table", {
#   m <- mock()
#
#   stub(mod_principal_detailed_server, "mod_measure_selection_server", reactiveVal)
#   stub(mod_principal_detailed_server, "get_available_aggregations", available_aggregations_expected)
#   stub(mod_principal_detailed_server, "get_aggregation", aggregations_age_group_expected)
#   stub(mod_principal_detailed_server, "dplyr::transmute", \(x, ...) x)
#   stub(mod_principal_detailed_server, "mod_principal_detailed_table", m)
#
#   selected_data <- reactiveVal()
#   selected_site <- reactiveVal()
#
#   testServer(mod_principal_detailed_server, args = list(selected_data, selected_site), {
#     selected_data(1)
#     selected_site("a")
#     selected_measure(selected_measure_expected)
#     session$setInputs(aggregation = "Age Group")
#
#     expect_called(m, 1)
#     expect_args(m, 1, aggregations_age_group_expected, "Age Group")
#   })
# })
