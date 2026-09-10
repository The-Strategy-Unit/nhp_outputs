# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# regression tests: several downstream modules (mod_measure_selection_server,
# mod_principal_change_factor_effects_server, mod_info_params_fct_tables)
# hard-code these column names when reading from get_activity_type_pod_measure_options().
# A silent rename here previously broke those modules without failing any test,
# because the modules' own test fixtures had been written to match the same
# stale names. Assert the contract explicitly so a rename fails fast here.
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("get_activity_type_pod_measure_options returns the expected columns", {
  actual <- get_activity_type_pod_measure_options()

  expect_named(
    actual,
    c(
      "activity_type",
      "activity_type_label",
      "pod",
      "pod_label",
      "measure"
    )
  )

  expect_true(nrow(actual) > 0)
  expect_type(actual$activity_type, "character")
  expect_s3_class(actual$activity_type_label, "factor")
  expect_type(actual$pod, "character")
  expect_s3_class(actual$pod_label, "factor")
  expect_type(actual$measure, "character")
})

test_that("get_pod_lookup returns the expected columns", {
  actual <- get_pod_lookup()

  expect_named(actual, c("activity_type_label", "pod", "pod_label"))
  expect_true(nrow(actual) > 0)
  expect_s3_class(actual$activity_type_label, "factor")
  expect_type(actual$pod, "character")
  expect_s3_class(actual$pod_label, "factor")
})

test_that("get_condensed_pod_lookup returns the expected columns", {
  actual <- get_condensed_pod_lookup()

  expect_named(actual, c("activity_type_label", "pod", "pod_label"))
  expect_true(nrow(actual) > 0)
  expect_s3_class(actual$activity_type_label, "factor")
  expect_type(actual$pod, "character")
  expect_s3_class(actual$pod_label, "factor")

  # the individual A&E "pod" types (e.g. aae_type-01) are condensed down to a
  # single "aae" row
  aae_rows <- dplyr::filter(actual, .data[["activity_type_label"]] == "A&E")
  expect_equal(nrow(aae_rows), 1)
  expect_equal(aae_rows$pod, "aae")
  expect_equal(as.character(aae_rows$pod_label), "A&E Arrivals")
})
