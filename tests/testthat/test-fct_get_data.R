library(shiny)
library(mockery)

test_that("get_results_container uses managed token", {
  m1 <- mock("t1")
  m2 <- mock("t2")
  m3 <- mock("container")
  m4 <- mock("token")

  withr::local_envvar(
    "AAD_TENANT_ID" = "",
    "STORAGE_URL" = "url"
  )

  stub(get_results_container, "AzureAuth::get_managed_token", m1)
  stub(get_results_container, "AzureAuth::get_azure_token", m2)
  stub(get_results_container, "AzureStor::storage_container", m3)
  stub(get_results_container, "AzureAuth::extract_jwt", m4)

  expect_equal(get_results_container(), "container")

  expect_called(m1, 1)
  expect_called(m2, 0)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(m1, 1, "https://storage.azure.com/")
  expect_args(m3, 1, "url/results", "token")
  expect_args(m4, 1, "t1")
})

test_that("get_results_container uses azure token", {
  m1 <- mock("t1")
  m2 <- mock("t2")
  m3 <- mock("container")
  m4 <- mock("token")

  withr::local_envvar(
    "AAD_TENANT_ID" = "tenant",
    "AAD_APP_ID" = "app",
    "AAD_APP_SECRET" = "secret",
    "STORAGE_URL" = "url"
  )

  stub(get_results_container, "AzureAuth::get_managed_token", m1)
  stub(get_results_container, "AzureAuth::get_azure_token", m2)
  stub(get_results_container, "AzureStor::storage_container", m3)
  stub(get_results_container, "AzureAuth::extract_jwt", m4)

  expect_equal(get_results_container(), "container")

  expect_called(m1, 0)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(m2, 1, "https://storage.azure.com/", "tenant", "app", "secret")
  expect_args(m3, 1, "url/results", "token")
  expect_args(m4, 1, "t2")
})

test_that("get_result_sets returns files on the local filesystem", {
  withr::local_envvar("RESULTS_PATH" = "results")

  m1 <- mock("results/a/1.json")
  m2 <- mock("1.json")

  stub(get_result_sets, "fs::dir_ls", m1)
  stub(get_result_sets, "AzureStor::list_blobs", m2)
  stub(get_result_sets, "get_results_container", "container")

  result <- get_result_sets("a", TRUE)

  expect_equal(result, c("1" = "results/a/1.json"))

  expect_called(m1, 1)
  expect_called(m2, 0)

  expect_args(m1, 1, "results/a", glob = "*.json")
})

test_that("get_result_sets returns files from azure", {
  withr::local_envvar("RESULTS_PATH" = "results")

  m1 <- mock("results/a/1.json")
  m2 <- mock("1.json")

  stub(get_result_sets, "fs::dir_ls", m1)
  stub(get_result_sets, "AzureStor::list_blobs", m2)
  stub(get_result_sets, "get_results_container", "container")

  result <- get_result_sets("a", FALSE)

  expect_equal(result, "1.json")

  expect_called(m1, 0)
  expect_called(m2, 1)

  expect_args(m2, 1, "container", "dev/a", "name")
})

test_that("get_results returns data from local storage", {
  data <- list(
    population_variants = list("a", "b"),
    results = list(
      "a" = list(
        list(
          x = 1,
          model_runs = list(1, 2, 3)
        ),
        list(
          x = 2,
          model_runs = list(2, 3, 4)
        )
      ),
      b = list(
        list(
          x = 3,
          model_runs = list(3, 4, 5)
        ),
        list(
          x = 4,
          model_runs = list(4, 5, 6)
        )
      )
    )
  )

  expected <- list(
    population_variants = c("a", "b"),
    results = list(
      "a" = tibble::tibble(
        x = 1:2,
        model_runs = c(list(1:3), list(2:4))
      ),
      "b" = tibble::tibble(
        x = 3:4,
        model_runs = c(list(3:5), list(4:6))
      )
    )
  )

  m1 <- mock(data)
  m2 <- mock(data)

  stub(get_results, "jsonlite::read_json", m1)
  stub(get_results, "jsonlite::parse_gzjson_raw", m2)

  results <- get_results("file", TRUE)

  expect_called(m1, 1)
  expect_called(m2, 0)

  expect_args(m1, 1, "file", simplifyVector = FALSE)

  expect_equal(results, expected)
})

test_that("get_results returns data from azure", {
  data <- list(
    population_variants = list("a", "b"),
    results = list(
      "a" = list(
        list(
          x = 1,
          model_runs = list(1, 2, 3)
        ),
        list(
          x = 2,
          model_runs = list(2, 3, 4)
        )
      ),
      b = list(
        list(
          x = 3,
          model_runs = list(3, 4, 5)
        ),
        list(
          x = 4,
          model_runs = list(4, 5, 6)
        )
      )
    )
  )

  expected <- list(
    population_variants = c("a", "b"),
    results = list(
      "a" = tibble::tibble(
        x = 1:2,
        model_runs = c(list(1:3), list(2:4))
      ),
      "b" = tibble::tibble(
        x = 3:4,
        model_runs = c(list(3:5), list(4:6))
      )
    )
  )

  m1 <- mock(data)
  m2 <- mock(data)

  m3 <- mock()
  m4 <- mock("data")

  stub(get_results, "jsonlite::read_json", m1)
  stub(get_results, "jsonlite::parse_gzjson_raw", m2)
  stub(get_results, "get_results_container", "container")
  stub(get_results, "withr::local_tempfile", "tf")
  stub(get_results, "AzureStor::download_blob", m3)
  stub(get_results, "readBin", m4)
  stub(get_results, "file.size", 10)

  results <- get_results("file", FALSE)

  expect_called(m1, 0)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(m2, 1, "data", simplifyVector = FALSE)
  expect_args(m3, 1, "container", "file", "tf")
  expect_args(m4, 1, "tf", raw(), 10)

  expect_equal(results, expected)
})

test_that("user_allowed_datasets returns correct values", {
  expect_equal(get_user_allowed_datasets(NULL), "synthetic")

  expect_equal(
    get_user_allowed_datasets("a"),
    c(
      "synthetic",
      "RA9", "RD8", "RGP", "RGR", "RH5", "RH8", "RHW", "RN5", "RNQ", "RX1", "RXC", "RXN_RTX", "RYJ"
    )
  )
})

test_that("get_trust_sites returns the list of trust sites", {
  r <- list(
    results = list(
      default = tibble::tibble(sitetret = c("a", "a", "b", "b", "c", "c"))
    )
  )
  actual <- get_trust_sites(r)

  expect_equal(actual, c("trust", "a", "b", "c"))
})

test_that("get_available_aggregations gets the list of available aggregations", {
  r <- list(
    results = list(
      a = tibble::tibble(pod = c("ip_1", "ip_2", "op_1", "op_2")),
      b = tibble::tibble(pod = c("ip_1", "ip_2")),
      c = tibble::tibble(x = 1)
    )
  )

  actual <- get_available_aggregations(r)

  expect_equal(actual, list(ip = c("a", "b"), op = c("a")))
})

test_that("get_model_run_years gets the model run years", {
  r <- list(
    params = list(start_year = 1, end_year = 2)
  )

  actual <- get_model_run_years(r)

  expect_equal(actual, list(start_year = 1, end_year = 2))
})

test_that("get_principal_high_level gets the results", {
  m <- mock("tsa")
  stub(get_principal_high_level, "trust_site_aggregation", m)

  r <- list(
    results = list(
      default = tibble::tribble(
        ~pod, ~sitetret, ~baseline, ~principal, ~measure,
        "aae_1", "a", 1, 2, "attendances",
        "aae_2", "a", 2, 4, "attendances",
        "ip_1", "a", 5, 6, "admissions",
        "ip_2", "a", 7, 8, "beddays",
        "ip_3", "a", 9, 10, "procedures",
        "op_1", "a", 9, 10, "attendances",
        "op_2", "a", 11, 12, "tele_attendances"
      )
    )
  )

  expected <- tibble::tribble(
    ~pod, ~sitetret, ~baseline, ~principal,
    "aae", "a", 3, 6,
    "ip_1", "a", 5, 6,
    "op_1", "a", 9, 10
  )

  actual <- get_principal_high_level(r)

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected)
})

test_that("get_model_core_activity gets the results", {
  m <- mock("tsa")
  stub(get_model_core_activity, "trust_site_aggregation", m)

  r <- list(
    results = list(
      default = tibble::tibble(x = 1, model_runs = 2)
    )
  )

  expected <- tibble::tibble(
    x = 1
  )

  actual <- get_model_core_activity(r)

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected)
})

test_that("get_variants gets the results", {
  r <- list(
    population_variants = c("a", "b", "c")
  )

  actual <- get_variants(r)

  expect_equal(actual, tibble::tibble(model_run = 1:2, variant = c("b", "c")))
})

test_that("get_model_run_distribution gets the results", {
  m <- mock("tsa")
  stub(get_model_run_distribution, "trust_site_aggregation", m)
  stub(
    get_model_run_distribution,
    "get_variants",
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  r <- list(
    results = list(
      default = tibble::tribble(
        ~sitetret, ~baseline, ~model_runs, ~pod, ~measure,
        "a", 100, c(100, 200, 300), "a", "a",
        "a", 101, c(101, 201, 301), "a", "b",
        "a", 102, c(102, 202, 302), "b", "a",
        "a", 103, c(103, 203, 303), "b", "b"
      )
    )
  )

  expected <- tibble::tribble(
    ~sitetret, ~baseline, ~model_run, ~value, ~variant,
    "a", 100, 1, 100, "a",
    "a", 100, 2, 200, "a",
    "a", 100, 3, 300, "b"
  )

  actual <- get_model_run_distribution(r, "a", "a")

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected)
})

test_that("get_aggregation gets the results", {
  m <- mock("tsa")
  stub(get_aggregation, "trust_site_aggregation", m)

  r <- list(
    results = list(
      "sex+tretspef" = tibble::tibble(
        "sex" = c(1, 1, 2, 2),
        "tretspef" = c("a", "a", "a", "a"),
        "pod" = c("a", "a", "b", "b"),
        "measure" = c("a", "b", "a", "b")
      )
    )
  )

  expected <- tibble::tibble(
    sex = "1",
    tretspef = "a"
  )

  actual <- get_aggregation(r, "a", "a", "tretspef")

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected)
})

test_that("get_principal_change_factors gets the results", {
  r <- list(
    results = list(
      "step_counts" = tibble::tibble(
        "activity_type" = c("aae", "aae", "ip", "ip"),
        "measure" = c("a", "a", "a", "a"),
        "change_factor" = c("a", "a", "b", "b"),
        "strategy" = c(NA, "x", NA, "x"),
        "value" = 1:4
      )
    )
  )

  expected <- tibble::tibble(
    measure = c("a", "a"),
    change_factor = c("a", "a"),
    strategy = c("-", "x"),
    value = 1:2
  )

  actual <- get_principal_change_factors(r, "aae")

  expect_equal(actual, expected)
})

test_that("get_principal_change_factors validates the arguments", {
  r <- list(
    results = list(
      "step_counts" = tibble::tibble(
        "activity_type" = c("aae", "aae", "ip", "ip"),
        "measure" = c("a", "a", "a", "a"),
        "change_factor" = c("a", "a", "b", "b"),
        "strategy" = c(NA, "x", NA, "x"),
        "value" = 1:4
      )
    )
  )

  get_principal_change_factors(r, "aae")
  get_principal_change_factors(r, "ip")
  get_principal_change_factors(r, "op")

  expect_error(get_principal_change_factors(r, "x"), "Invalid activity_type")
})

test_that("get_bed_occupancy gets the results", {
  stub(
    get_bed_occupancy,
    "get_variants",
    tibble::tibble(model_run = 1:3, variant = c("a", "a", "b"))
  )

  r <- list(
    results = list(
      bed_occupancy = tibble::tibble(
        measure = "m",
        quarter = "q",
        ward_group = "w",
        baseline = "b",
        principal = "p",
        median = 1,
        lwr_ci = 0,
        upr_ci = 2,
        model_runs = list(4:6)
      )
    )
  )

  expected <- tibble::tibble(
    measure = c("m", "m", "m"),
    quarter = c("q", "q", "q"),
    ward_group = c("w", "w", "w"),
    baseline = c("b", "b", "b"),
    principal = c("p", "p", "p"),
    median = c(1, 1, 1),
    lwr_ci = c(0, 0, 0),
    upr_ci = c(2, 2, 2),
    model_run = 1:3,
    value = 4:6,
    variant = c("a", "a", "b")
  )

  actual <- get_bed_occupancy(r)

  expect_equal(actual, expected)
})

test_that("get_theatres_available gets the results", {
  r <- list(
    results = list(
      theatres_available = tibble::tibble(
        tretspef = "t",
        baseline = "b",
        principal = "p",
        median = 1,
        lwr_ci = 0,
        upr_ci = 2,
        model_runs = list(4:6)
      )
    )
  )

  actual <- get_theatres_available(r)
  expected <- r$results$theatres_available

  expect_equal(actual, expected)
})

test_that("trust_site_aggregation adds in a trust level aggregatrion", {
  df <- tibble::tribble(
    ~sitetret, ~x, ~v,
    "trust", "a", 1,
    "x", "b", 2,
    "y", "b", 3,
    "x", "c", 4,
    "y", "c", 5
  )

  expected <- dplyr::bind_rows(
    tibble::tribble(
      ~sitetret, ~x, ~v,
      "trust", "b", 5,
      "trust", "c", 9
    ),
    df
  ) |>
    dplyr::relocate(x, .before = sitetret)

  actual <- trust_site_aggregation(df)

  expect_equal(actual, expected)
})
