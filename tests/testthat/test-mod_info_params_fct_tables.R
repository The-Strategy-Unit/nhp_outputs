library(shiny)
library(mockery)

get_sample_params <- \() {
  list(
    params = jsonlite::read_json(
      app_sys("sample_params.json"),
      simplifyVector = FALSE
    )
  ) |>
    get_params()
}

test_that("info_params_tables generated validation errors if no params provided", {
  p <- list()

  expect_error(
    info_params_table_demographic_adjustment(p)
  )

  expect_error(
    info_params_table_baseline_adjustment(p)
  )

  expect_error(
    info_params_table_covid_adjustment(p)
  )

  expect_error(
    info_params_table_waiting_list_adjustment(p)
  )

  expect_error(
    info_params_table_expat_repat_adjustment(p, "expat")
  )

  expect_error(
    info_params_table_non_demographic_adjustment(p)
  )

  expect_error(
    info_params_table_activity_avoidance(p)
  )

  expect_error(
    info_params_table_efficiencies(p)
  )
})

test_that("info_params_table_demographic_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_demographic_adjustment(p)
    )
  )
})

test_that("info_params_table_baseline_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_baseline_adjustment(p)
    )
  )
})

test_that("info_params_table_covid_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_covid_adjustment(p)
    )
  )
})

test_that("info_params_table_waiting_list_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_waiting_list_adjustment(p)
    )
  )
})

test_that("info_params_table_expat_repat_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_expat_repat_adjustment(p, "expat")
    )
  )
})

test_that("info_params_table_non_demographic_adjustment creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_non_demographic_adjustment(p)
    )
  )
})

test_that("info_params_table_activity_avoidance creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_activity_avoidance(p)
    )
  )
})

test_that("info_params_table_efficiencies creates table correctly", {
  p <- get_sample_params()

  set.seed(1)
  expect_snapshot(
    gt::as_raw_html(
      info_params_table_efficiencies(p)
    )
  )
})
