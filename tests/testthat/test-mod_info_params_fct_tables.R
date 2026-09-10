library(shiny)
library(mockery)

get_sample_params <- \() {
  list(
    params = yyjsonr::read_json_file(
      app_sys("sample_params.json")
    )
  ) |>
    patch_params() |>
    get_params()
}

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# regression tests: info_params_fix_data() joins in lookup columns (from
# get_activity_type_pod_measure_options(), get_tretspef_lookup(), and
# mitigators.json) that several info_params_table_* functions then reference
# by name (e.g. "activity_type_label"). A silent rename in any of those
# lookups, or in the join itself, previously broke those callers without
# failing a test. Assert the joined column names explicitly here, as well as
# each source lookup's own column names directly (a rename in the lookup
# itself should fail here, not only once it propagates through the join).
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_tretspef_lookup returns the expected columns", {
  actual <- get_tretspef_lookup()

  expect_named(actual, c("code", "tretspef"))
  expect_true(nrow(actual) > 0)
  expect_type(actual$code, "character")
  expect_type(actual$tretspef, "character")
})

test_that("get_tpma_name_lookup returns the expected columns", {
  actual <- get_tpma_name_lookup()

  expect_named(actual, c("strategy", "mitigator_name"))
  expect_true(nrow(actual) > 0)
  expect_type(actual$strategy, "character")
  expect_type(actual$mitigator_name, "character")
  expect_true("alcohol_wholly_attributable" %in% actual$strategy)
})

test_that("info_params_fix_data joins in activity_type_label and drops activity_type", {
  df <- tibble::tibble(activity_type = c("ip", "op", "aae"), value = 1:3)

  actual <- info_params_fix_data(df)

  expect_named(actual, c("value", "activity_type_label"))
  expect_false("activity_type" %in% colnames(actual))
  expect_false("activity_type_name" %in% colnames(actual))
  expect_equal(nrow(actual), 3)
})

test_that("info_params_fix_data leaves data untouched if activity_type is absent", {
  df <- tibble::tibble(value = 1:3)

  expect_equal(info_params_fix_data(df), df)
})

test_that("info_params_fix_data joins in specialty_name and drops specialty", {
  df <- tibble::tibble(specialty = c("100", "unknown_code"), value = c(1, 2))

  actual <- info_params_fix_data(df)

  expect_named(actual, c("value", "specialty_name"))
  expect_false("specialty" %in% colnames(actual))
  expect_equal(
    actual$specialty_name,
    c("General Surgery Service", "unknown_code")
  )
})

test_that("info_params_fix_data joins in mitigator_name and drops strategy", {
  df <- tibble::tibble(strategy = "alcohol_wholly_attributable", value = 1)

  actual <- info_params_fix_data(df)

  expect_named(actual, c("value", "mitigator_name"))
  expect_false("strategy" %in% colnames(actual))
  expect_match(
    actual$mitigator_name,
    "Alcohol Related Admissions \\(Wholly Attributable\\)"
  )
})

test_that("info_params_tables generated validation errors if no params provided", {
  p <- list()

  expect_error(
    info_params_table_demographic_adjustment(p)
  )

  expect_error(
    info_params_table_baseline_adjustment(p)
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
