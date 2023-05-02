library(shiny)
library(mockery)

test_that("it produces correct bars", {
  expect_snapshot(gt_bar(1:2))
  expect_snapshot(gt_bar(1:2 / 10, scales::percent))

  expect_snapshot(gt_bar(-(1:2)))
  expect_snapshot(gt_bar(-1:1))
})

test_that("it handles the edge case of a value being both positive and negative", {
  x <- gt_bar(-1:1)
  expect_equal(length(x), 3)
  testthat::expect_s3_class(x[[1]], "html")
  testthat::expect_s3_class(x[[2]], "html")
  testthat::expect_s3_class(x[[3]], "html")
})
