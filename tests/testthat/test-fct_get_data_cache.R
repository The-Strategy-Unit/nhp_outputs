library(mockery)

# these tests currently fail on github actions - it seems like the cache methods can't be stubbed

test_that("it assigns a cachem object in the global environment when it first runs", {
  testthat::skip_on_ci()

  env <- rlang::new_environment()
  env[["__DATA_CACHE__"]] <- NULL

  stub(get_data_cache, "cachem::cache_mem", "memory cache")

  withr::local_envvar(c("GOLEM_ACTIVE_CONFIG" = "dev"))
  expect_equal(get_data_cache(env), "memory cache")

  expect_equal(get("__DATA_CACHE__", envir = env), "memory cache")
})

test_that("it retrieves the item from the global environment on subsequent runs", {
  testthat::skip_on_ci()

  env <- rlang::new_environment()
  env[["__DATA_CACHE__"]] <- NULL

  m <- mock()
  stub(get_data_cache, "cachem::cache_mem", m)

  assign("__DATA_CACHE__", "cache instance", envir = env)
  withr::local_envvar(c("GOLEM_ACTIVE_CONFIG" = "dev"))
  expect_equal(get_data_cache(env), "cache instance")

  expect_equal(get("__DATA_CACHE__", envir = env), "cache instance")
  expect_called(m, 0)
})

test_that("it creates a physical cache on disk when not dev", {
  testthat::skip_on_ci()

  env <- rlang::new_environment()
  env[["__DATA_CACHE__"]] <- NULL

  m <- mock()
  stub(get_data_cache, "dir.exists", FALSE)
  stub(get_data_cache, "dir.create", m)
  stub(get_data_cache, "cachem::cache_disk", "disk cache")

  withr::local_envvar(
    c("GOLEM_CONFIG_ACTIVE" = "prod", "CACHE_VERSION" = -1)
  )

  expect_equal(get_data_cache(env), "disk cache")

  expect_equal(get("__DATA_CACHE__", envir = env), "disk cache")

  expect_called(m, 1)
  expect_args(m, 1, ".cache")
})

test_that("changing the CACHE_VERSION env var invalidates the cache", {
  testthat::skip_on_ci()

  env <- rlang::new_environment()
  env[["__DATA_CACHE__"]] <- NULL

  m <- mock()
  stub(get_data_cache, "dir.exists", FALSE)
  stub(get_data_cache, "dir.create", NULL)
  stub(get_data_cache, "cachem::cache_disk", list(reset = m))
  stub(get_data_cache, "writeLines", m)

  withr::local_envvar(c("GOLEM_CONFIG_ACTIVE" = "prod"))

  expect_output(get_data_cache(env), "Invalidating cache")

  expect_called(m, 2)
  expect_args(m, 1)
  expect_args(m, 2, "0", ".cache/cache_version.txt")
})
