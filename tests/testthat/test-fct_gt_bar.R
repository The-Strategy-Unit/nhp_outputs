library(shiny)
library(mockery)

test_that("it produces correct bars", {
  expect_snapshot(gt_bar(1:2))
  expect_snapshot(gt_bar(1:2 / 10, scales::percent))
})
