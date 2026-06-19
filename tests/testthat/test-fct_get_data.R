library(shiny)
library(mockery)

test_that("get_results_from_azure returns data from azure", {
  # arrange
  m0 <- mock("container")
  m1 <- mock("raw_params", "raw_variants")
  m2 <- mock("patched_params")
  m3 <- mock("results_data")
  stub(get_results_from_azure, "azkit::get_container", m0)
  stub(get_results_from_azure, "azkit::read_azure_json", m1)
  stub(get_results_from_azure, "patch_params", m2)
  stub(get_results_from_azure, "reskit::read_results_parquet_files", m3)
  withr::local_envvar(
    "AZ_STORAGE_CONTAINER" = "container",
    "AZ_STORAGE_EP" = "ep"
  )

  # act
  actual <- get_results_from_azure("dir")

  # assert
  expect_called(m0, 1)
  expect_called(m1, 2)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_args(m0, 1, container_name = "container", endpoint_url = "ep")
  expect_args(m1, 1, "container", file.path("dir", "params.json"))
  expect_args(m1, 2, "container", file.path("dir", "variants.json"))
  expect_args(m2, 1, "raw_params")
  expect_args(m3, 1, "container", "dir")
  expect_equal(
    actual,
    list(
      params = "patched_params",
      population_variants = "raw_variants",
      results = "results_data"
    )
  )
})

test_that("get_results_from_local returns data from local storage", {
  # arrange
  m1 <- mock("raw_params", "raw_variants")
  m2 <- mock("patched_params")
  m3 <- mock(c("file/a.parquet", "file/b.parquet"))
  m4 <- mock("parquet_data_a", "parquet_data_b")

  stub(get_results_from_local, "yyjsonr::read_json_file", m1)
  stub(get_results_from_local, "patch_params", m2)
  stub(get_results_from_local, "list.files", m3)
  stub(get_results_from_local, "arrow::read_parquet", m4)
  # act
  actual <- get_results_from_local("file")

  # assert
  expect_called(m1, 2)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_called(m4, 2)
  expect_args(m1, 1, file.path("file", "params.json"))
  expect_args(m1, 2, file.path("file", "variants.json"))
  expect_args(m2, 1, "raw_params")
  expect_args(m3, 1, "file", "\\.parquet$", full.names = TRUE)
  expect_args(m4, 1, "file/a.parquet")
  expect_args(m4, 2, "file/b.parquet")
  expect_equal(
    actual,
    list(
      params = "patched_params",
      population_variants = "raw_variants",
      results = list(a = "parquet_data_a", b = "parquet_data_b")
    )
  )
})

test_that("patch_params returns correct values", {
  # arrange
  params <- list(
    param1 = c(1, 2),
    param2 = list(
      param3 = c(3, 4)
    )
  )
  expected <- list(param1 = list(1, 2), param2 = list(param3 = list(3, 4)))

  # act
  actual <- patch_params(params)

  # assert
  expect_equal(actual, expected)
})

test_that("user_allowed_datasets returns correct values", {
  stub(get_user_allowed_datasets, "yyjsonr::read_json_file", c("A", "B", "C"))

  for (i in list(NULL, "nhp_devs", "nhp_power_users")) {
    expect_equal(
      get_user_allowed_datasets(NULL),
      c(
        "synthetic",
        "A",
        "B",
        "C"
      )
    )
  }

  expect_equal(
    get_user_allowed_datasets("X"),
    c(
      "synthetic"
    )
  )

  for (i in list("A", "B", "C")) {
    expect_equal(
      get_user_allowed_datasets(paste0("nhp_provider_", i)),
      c(
        "synthetic",
        i
      )
    )
  }
})

test_that("get_trust_sites returns the list of trust sites", {
  r <- list(
    results = list(
      default = tibble::tibble(sitetret = c("a", "a", "b", "b", "c", "c"))
    )
  )
  actual <- get_trust_sites(r)

  expect_equal(actual, c("a", "b", "c"))
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
        ~pod,
        ~sitetret,
        ~baseline,
        ~principal,
        ~measure,
        "aae_1",
        "a",
        1,
        2,
        "attendances",
        "aae_2",
        "a",
        2,
        4,
        "attendances",
        "ip_1",
        "a",
        5,
        6,
        "admissions",
        "ip_2",
        "a",
        7,
        8,
        "beddays",
        "ip_3",
        "a",
        9,
        10,
        "procedures",
        "op_1",
        "a",
        9,
        10,
        "attendances",
        "op_2",
        "a",
        11,
        12,
        "tele_attendances"
      )
    )
  )

  expected <- tibble::tribble(
    ~pod,
    ~sitetret,
    ~baseline,
    ~principal,
    "aae",
    "a",
    3,
    6,
    "ip_1",
    "a",
    5,
    6,
    "op_1",
    "a",
    9,
    10
  )

  actual <- get_principal_high_level(
    r,
    c("admissions", "attendances", "walk-in", "ambulance"),
    c("a")
  )

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected, "a")
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

  actual <- get_model_core_activity(r, "a")

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected, "a")
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
        ~sitetret,
        ~baseline,
        ~principal,
        ~model_runs,
        ~pod,
        ~measure,
        "a",
        100,
        110,
        c(100, 200, 300),
        "a",
        "a",
        "a",
        101,
        111,
        c(101, 201, 301),
        "a",
        "b",
        "a",
        102,
        112,
        c(102, 202, 302),
        "b",
        "a",
        "a",
        103,
        113,
        c(103, 203, 303),
        "b",
        "b"
      )
    )
  )

  expected <- tibble::tribble(
    ~sitetret,
    ~baseline,
    ~principal,
    ~model_run,
    ~value,
    ~variant,
    "a",
    100,
    110,
    1,
    100,
    "a",
    "a",
    100,
    110,
    2,
    200,
    "a",
    "a",
    100,
    110,
    3,
    300,
    "b"
  )

  actual <- get_model_run_distribution(r, "a", "a", "a")

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected, "a")
})

test_that("get_model_run_distribution returns NULL if filter returns no rows", {
  r <- list(
    results = list(
      default = tibble::tibble(
        pod = "a",
        measure = "b",
        sitetret = "c",
        baseline = "d",
        principal = "e",
        model_runs = "f"
      )
    )
  )

  expect_null(get_model_run_distribution(r, "a", "x"))
  expect_null(get_model_run_distribution(r, "x", "b"))
})

test_that("get_principal_change_factors gets the results", {
  m <- mock("trust_site_aggregation")

  stub(get_principal_change_factors, "trust_site_aggregation", m)

  r <- list(
    results = list(
      "step_counts" = tibble::tibble(
        "activity_type" = c("aae", "aae", "ip", "ip"),
        "sitetret" = c("a", "a", "a", "a"),
        "pod" = c("a", "a", "a", "a"),
        "measure" = c("a", "a", "a", "a"),
        "change_factor" = c("a", "a", "b", "b"),
        "strategy" = c(NA, "x", NA, "x"),
        "value" = 1:4
      )
    )
  )

  expected <- tibble::tibble(
    activity_type = c("aae", "aae"),
    sitetret = c("a", "a"),
    pod = c("a", "a"),
    measure = c("a", "a"),
    change_factor = c("a", "a"),
    strategy = c("-", "x"),
    value = 1:2
  )

  actual <- get_principal_change_factors(r, "aae", "a")

  expect_equal(actual, "trust_site_aggregation")

  expect_called(m, 1)
  expect_args(m, 1, expected, "a")
})

test_that("get_principal_change_factors validates the arguments", {
  r <- list(
    results = list(
      "step_counts" = tibble::tibble(
        "activity_type" = c("aae", "aae", "ip", "ip"),
        "sitetret" = c("a", "a", "a", "a"),
        "pod" = c("a", "a", "a", "a"),
        "measure" = c("a", "a", "a", "a"),
        "change_factor" = c("a", "a", "b", "b"),
        "strategy" = c(NA, "x", NA, "x"),
        "value" = 1:4
      )
    )
  )

  get_principal_change_factors(r, "aae", "a")
  get_principal_change_factors(r, "ip", "a")
  get_principal_change_factors(r, "op", "a")

  expect_error(get_principal_change_factors(r, "x"), "Invalid activity_type")
})

test_that("trust_site_aggregation adds in a trust level aggregatrion", {
  df <- tibble::tribble(
    ~sitetret,
    ~x,
    ~v,
    "x",
    "a",
    1,
    "x",
    "b",
    2,
    "y",
    "b",
    3,
    "x",
    "c",
    4,
    "y",
    "c",
    5
  )

  expected <- dplyr::bind_rows(
    tibble::tribble(
      ~sitetret,
      ~x,
      ~v,
      "trust",
      "b",
      5,
      "trust",
      "c",
      9
    ),
    df
  ) |>
    dplyr::relocate(x, .before = sitetret)

  expect_equal(
    trust_site_aggregation(df, "x"),
    tibble::tibble(x = c("a", "b", "c"), v = c(1, 2, 4))
  )

  expect_equal(
    trust_site_aggregation(df, c("x", "y")),
    tibble::tibble(x = c("a", "b", "c"), v = c(1, 5, 9))
  )

  expect_equal(
    trust_site_aggregation(df, character(0)),
    tibble::tibble(x = c("a", "b", "c"), v = c(1, 5, 9))
  )
})
