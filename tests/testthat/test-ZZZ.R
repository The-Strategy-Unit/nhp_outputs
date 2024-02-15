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

test_that("get_selected_file_from_url decodes the filename correctly", {
  # act
  expected <- "test/file.json.gz"

  session <- list(
    clientData = list(
      url_search = paste0(
        "file=",
        expected |>
          charToRaw() |>
          base64enc::base64encode()
      )
    )
  )

  # act
  actual <- get_selected_file_from_url(session)

  # assert
  expect_equal(actual, expected)
})
