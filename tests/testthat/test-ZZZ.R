library(shiny)
library(mockery)

test_that("set_names converts a two column tibble to a named vector", {
  df <- tibble::tibble(
    one = c("a", "b"),
    two = c("c", "d")
  )

  actual <- set_names(df)
  expected <- c("c" = "a", "d" = "b")

  expect_equal(actual, expected)
})

test_that("global variables are set correctly", {
  expect_equal(`__BATCH_EP__`, "https://batch.core.windows.net/")
  expect_equal(`__STORAGE_EP__`, "https://storage.azure.com/")
})

test_that("fyear_str formats years correctly", {
  expect_equal(fyear_str(1999), "1999/00")
  expect_equal(fyear_str(2018), "2018/19")
  expect_equal(fyear_str(2020), "2020/21")
})

test_that("lookup_ods_org_code_name returns correct names", {
  expect_equal(lookup_ods_org_code_name("RL403"), "NEW CROSS HOSPITAL")
  expect_equal(lookup_ods_org_code_name("RL400"), "Unknown")
})

test_that("format_create_datetime parses a valid datetime string", {
  expect_equal(
    format_create_datetime("20240123_012345"),
    "23-Jan-2024 01:23:45"
  )
})

test_that("format_create_datetime returns NA for missing/invalid input", {
  expect_identical(format_create_datetime(NULL), NA_character_)
  expect_identical(format_create_datetime(NA_character_), NA_character_)
  expect_identical(format_create_datetime(20240123012345), NA_character_)
  expect_identical(format_create_datetime("not-a-datetime"), NA_character_)
  expect_identical(format_create_datetime(c("a", "b")), NA_character_)
})

test_that("dev user can request cache reset", {
  session <- list(
    groups = "nhp_devs",
    clientData = list(
      url_search = "?reset_cache"
    )
  )

  expect_true(user_requested_cache_reset(session))

  session$clientData$url_search <- ""
  expect_false(user_requested_cache_reset(session))
})

test_that("normal user cannot request cache reset", {
  session <- list(
    groups = "",
    clientData = list(
      url_search = "?reset_cache"
    )
  )

  expect_false(user_requested_cache_reset(session))
})
