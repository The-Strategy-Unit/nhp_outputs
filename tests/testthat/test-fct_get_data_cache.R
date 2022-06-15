library(mockery)

test_that("it assigns a cachem object in the global environment when it first runs", {
  e <- rlang::new_environment()
  stub(get_data_cache, "as.environment", e)
  stub(get_data_cache, "cachem::cache_mem", "memory cache")

  withr::with_envvar(c("GOLEM_ACTIVE_CONFIG" = "dev"), get_data_cache())

  expect_true(exists("__data_cache_instance__", envir = e))
  expect_equal(get("__data_cache_instance__", envir = e), "memory cache")
})

test_that("it retrieves the item from the global environment on subsequent runs", {
  m <- mock()
  e <- rlang::new_environment()
  stub(get_data_cache, "as.environment", e)
  stub(get_data_cache, "cachem::cache_mem", m)

  assign("__data_cache_instance__", "cache instance", envir = e)
  withr::with_envvar(c("GOLEM_ACTIVE_CONFIG" = "dev"), get_data_cache())

  expect_equal(get("__data_cache_instance__", envir = e), "cache instance")
  expect_called(m, 0)
})

test_that("it creates a physical cache on disk when not dev", {
  m <- mock()
  e <- rlang::new_environment()
  stub(get_data_cache, "as.environment", e)
  stub(get_data_cache, "dir.exists", FALSE)
  stub(get_data_cache, "dir.create", m)
  stub(get_data_cache, "cachem::cache_disk", "disk cache")

  withr::with_envvar(
    c("GOLEM_CONFIG_ACTIVE" = "prod", "CACHE_VERSION" = -1),
    get_data_cache()
  )

  expect_true(exists("__data_cache_instance__", envir = e))
  expect_equal(get("__data_cache_instance__", envir = e), "disk cache")

  expect_called(m, 1)
  expect_args(m, 1, ".cache")
})

test_that("changing the CACHE_VERSION env var invalidates the cache", {
  m <- mock()
  e <- rlang::new_environment()
  stub(get_data_cache, "as.environment", e)
  stub(get_data_cache, "dir.exists", FALSE)
  stub(get_data_cache, "dir.create", NULL)
  stub(get_data_cache, "cachem::cache_disk", list(reset = m))
  stub(get_data_cache, "writeLines", m)

  withr::with_envvar(
    c("GOLEM_CONFIG_ACTIVE" = "prod"),
    expect_output(get_data_cache(), "Invalidating cache")
  )

  expect_called(m, 2)
  expect_args(m, 1)
  expect_args(m, 2, "0", ".cache/cache_version.txt")
})
