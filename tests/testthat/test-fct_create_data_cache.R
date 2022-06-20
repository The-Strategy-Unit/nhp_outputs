library(shiny)
library(mockery)

test_that("it creates a directory for the data cache", {
  m <- mock()

  stub(create_data_cache, "dir.exists", FALSE)
  stub(create_data_cache, "dir.create", m)
  stub(create_data_cache, "cachem::cache_disk", list(reset = \() NULL))
  stub(create_data_cache, "file.exists", TRUE)
  stub(create_data_cache, "readLines", "0")
  stub(create_data_cache, "writeLines", "writeLines")
  stub(create_data_cache, "shiny::shinyOptions", "options")

  create_data_cache()
  expect_called(m, 1)
  expect_args(m, 1, ".cache")
})

test_that("it creates a disk cache object", {
  m <- mock(list(reset = \() NULL))

  stub(create_data_cache, "dir.exists", TRUE)
  stub(create_data_cache, "dir.create", "dir.create")
  stub(create_data_cache, "cachem::cache_disk", m)
  stub(create_data_cache, "file.exists", TRUE)
  stub(create_data_cache, "readLines", "0")
  stub(create_data_cache, "writeLines", "writeLines")
  stub(create_data_cache, "shiny::shinyOptions", "options")

  create_data_cache()
  expect_called(m, 1)
  expect_args(m, 1, ".cache/data_cache", 200 * 1024^2)
})

test_that("it does not invalidate the cache if cache_version hasn't changed", {
  m <- mock()

  stub(create_data_cache, "dir.exists", TRUE)
  stub(create_data_cache, "dir.create", "dir.create")
  stub(create_data_cache, "cachem::cache_disk", list(reset = m))
  stub(create_data_cache, "file.exists", FALSE)
  stub(create_data_cache, "readLines", "0")
  stub(create_data_cache, "writeLines", "writeLines")
  stub(create_data_cache, "shiny::shinyOptions", "options")

  withr::local_envvar(c("CACHE_VERSION" = -1))
  create_data_cache()
  expect_called(m, 0)
})

test_that("it invalidates the cache if cache_version has changed", {
  m <- mock()

  stub(create_data_cache, "dir.exists", TRUE)
  stub(create_data_cache, "dir.create", "dir.create")
  stub(create_data_cache, "cachem::cache_disk", list(reset = m))
  stub(create_data_cache, "file.exists", TRUE)
  stub(create_data_cache, "readLines", "0")
  stub(create_data_cache, "writeLines", m)
  stub(create_data_cache, "shiny::shinyOptions", "options")

  withr::local_envvar(c("CACHE_VERSION" = 1))
  expect_output(create_data_cache(), "Invalidating cache")
  expect_called(m, 2)
  expect_args(m, 2, "1", ".cache/cache_version.txt")
})


test_that("it sets the shinyOptions", {
  m <- mock()

  stub(create_data_cache, "dir.exists", TRUE)
  stub(create_data_cache, "dir.create", "dir.create")
  stub(create_data_cache, "cachem::cache_disk", "cache_disk")
  stub(create_data_cache, "file.exists", TRUE)
  stub(create_data_cache, "readLines", "0")
  stub(create_data_cache, "writeLines", "writeLines")
  stub(create_data_cache, "shiny::shinyOptions", m)

  create_data_cache()
  expect_called(m, 1)
  expect_args(m, 1, cache = "cache_disk")
})
