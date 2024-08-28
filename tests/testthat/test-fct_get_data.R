library(shiny)
library(mockery)

test_that("get_container uses managed token", {
  m0 <- mock("t0")
  m1 <- mock("t1")
  m2 <- mock("t2")
  m3 <- mock("ep")
  m4 <- mock("container")

  withr::local_envvar(
    "AZ_STORAGE_EP" = "url/results",
    "AZ_APP_ID" = "",
    "AZ_STORAGE_CONTAINER" = "results"
  )

  stub(get_container, "AzureAuth::get_azure_token", m0)
  stub(get_container, "AzureAuth::get_managed_token", m1)
  stub(get_container, "AzureAuth::extract_jwt", m2)
  stub(get_container, "AzureStor::blob_endpoint", m3)
  stub(get_container, "AzureStor::storage_container", m4)

  expect_equal(get_container(), "container")

  expect_called(m0, 0)
  expect_called(m1, 1)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(m1, 1, "https://storage.azure.com/")
  expect_args(m2, 1, "t1")
  expect_args(m3, 1, "url/results", token = "t2")
  expect_args(m4, 1, "ep", "results")
})

test_that("get_container uses azure app id if present", {
  m0 <- mock("t0")
  m1 <- mock("t1")
  m2 <- mock("t2")
  m3 <- mock("ep")
  m4 <- mock("container")

  withr::local_envvar(
    "AZ_STORAGE_EP" = "url/results",
    "AZ_TENANT_ID" = "tenant_id",
    "AZ_APP_ID" = "app_id",
    "AZ_STORAGE_CONTAINER" = "results"
  )

  stub(get_container, "AzureAuth::get_azure_token", m0)
  stub(get_container, "AzureAuth::get_managed_token", m1)
  stub(get_container, "AzureAuth::extract_jwt", m2)
  stub(get_container, "AzureStor::blob_endpoint", m3)
  stub(get_container, "AzureStor::storage_container", m4)

  expect_equal(get_container(), "container")

  expect_called(m0, 1)
  expect_called(m1, 0)
  expect_called(m2, 0)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(
    m0,
    1,
    "https://storage.azure.com",
    tenant = "tenant_id",
    app = "app_id",
    auth_type = "device_code"
  )
  expect_args(m3, 1, "url/results", token = "t0")
  expect_args(m4, 1, "ep", "results")
})

test_that("get_result_sets returns files", {
  withr::local_envvar("RESULTS_PATH" = "results")

  m1 <- mock(
    tibble::tribble(
      ~name, ~isdir,
      "d", TRUE,
      "1", FALSE,
      "2", FALSE,
      "3", FALSE,
      "4", FALSE
    )
  )
  m2 <- mock(
    list(dataset = "a", viewable = "true"),
    list(dataset = "b", viewable = "false"),
    list(dataset = "a", viewable = "false"),
    list(dataset = "c", viewable = "true")
  )

  stub(get_result_sets, "get_container", "container")
  stub(get_result_sets, "AzureStor::list_blobs", m1)
  stub(get_result_sets, "AzureStor::get_storage_metadata", m2)

  expected <- tibble::tribble(
    ~file, ~dataset, ~viewable,
    "1", "a", TRUE,
    "2", "b", FALSE,
    "3", "a", FALSE
  )

  result <- get_result_sets(c("a", "b"), "dev")

  expect_equal(result, expected)

  expect_called(m1, 1)
  expect_called(m2, 4)

  expect_args(m1, 1, "container", "dev", "all", TRUE)

  expect_args(m2, 1, "container", "1")
  expect_args(m2, 2, "container", "2")
  expect_args(m2, 3, "container", "3")
  expect_args(m2, 4, "container", "4")
})

test_that("get_results_from_azure returns data from azure", {
  # arrange
  m1 <- mock()
  m2 <- mock("binary_data")
  m3 <- mock("json_data")
  m4 <- mock("parsed_data")

  stub(get_results_from_azure, "get_container", "container")
  stub(get_results_from_azure, "withr::local_tempfile", "tf")
  stub(get_results_from_azure, "AzureStor::download_blob", m1)
  stub(get_results_from_azure, "readBin", m2)
  stub(get_results_from_azure, "jsonlite::parse_gzjson_raw", m3)
  stub(get_results_from_azure, "file.size", 10)
  stub(get_results_from_azure, "parse_results", m4)

  # act
  actual <- get_results_from_azure("file")

  # assert
  expect_called(m1, 1)
  expect_called(m2, 1)
  expect_called(m3, 1)
  expect_called(m4, 1)

  expect_args(m1, 1, "container", "file", "tf")
  expect_args(m2, 1, "tf", raw(), 10)
  expect_args(m3, 1, "binary_data", simplifyVector = FALSE)
  expect_args(m4, 1, "json_data")

  expect_equal(actual, "parsed_data")
})

test_that("get_results_from_local returns data from local storage", {
  # arrange
  m1 <- mock("json_data")
  m2 <- mock("parsed_data")

  stub(get_results_from_local, "jsonlite::read_json", m1)
  stub(get_results_from_local, "parse_results", m2)

  # act
  actual <- get_results_from_local("file")

  # assert
  expect_called(m1, 1)
  expect_called(m2, 1)

  expect_args(m1, 1, "file", simplifyVector = FALSE)
  expect_args(m2, 1, "json_data")

  expect_equal(actual, "parsed_data")
})

test_that("parse_results converts results correctly", {
  m <- mock("patched_results")
  stub(parse_results, "patch_results", m)

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

  # act
  actual <- parse_results(data)

  # assert
  expect_called(m, 1)
  expect_args(m, 1, expected)

  expect_equal(actual, "patched_results")
})

test_that("patch_principal returns correct values (not step_counts)", {
  # arrange
  m <- mock()

  stub(patch_principal, "patch_principal_step_counts", m)

  results <- tibble::tibble(
    model_runs = list(c(1:100))
  )
  expected <- dplyr::mutate(
    results,
    principal = 50.5,
    median = 50.5,
    lwr_pi = 10.9,
    upr_pi = 90.1
  )

  # act
  actual <- patch_principal(results, "x")

  # assert
  expect_called(m, 0)
  expect_equal(actual, expected)
})

test_that("patch_principal returns correct values (step_counts)", {
  # arrange
  m <- mock("patch_principal_step_counts")

  stub(patch_principal, "patch_principal_step_counts", m)

  # act
  actual <- patch_principal("results", "step_counts")

  # assert
  expect_called(m, 1)
  expect_args(m, 1, "results")
  expect_equal(actual, "patch_principal_step_counts")
})

test_that("patch_principal_step_counts returns correct values", {
  # arrange
  results <- tibble::tibble(
    change_factor = c("baseline", "x"),
    model_runs = list(1, 2:4)
  )
  expected <- results |>
    dplyr::mutate(value = c(1, 3))

  # act
  actual <- patch_principal_step_counts(results)

  # assert
  expect_equal(actual, expected)
})

test_that("patch_step_counts returns correct values (no strategy)", {
  # arrange
  expected <- tibble::tibble(
    change_factor = "a",
    strategy = NA_character_,
    value = 1
  )
  r <- list(
    step_counts = dplyr::select(expected, -"strategy")
  )

  # act
  actual <- patch_step_counts(r)

  # assert
  expect_equal(actual$step_counts, expected)
})

test_that("patch_step_counts returns correct values (has strategy)", {
  # arrange
  expected <- tibble::tibble(
    change_factor = "a",
    strategy = "b",
    value = 1
  )
  r <- list(
    step_counts = expected
  )

  # act
  actual <- patch_step_counts(r)

  # assert
  expect_equal(actual$step_counts, expected)
})

test_that("patch_results returns correct values", {
  # arrange
  r <- list(
    results = list(
      "tretspef_raw" = tibble::tribble(
        ~measure, ~pod, ~tretspef_raw, ~sitetret, ~baseline, ~principal, ~time_profiles, ~lwr_pi, ~median, ~upr_pi,
        "a", "op", "100", "s1", 1, 2, c(1, 2), 3, 4, 5
      ),
      "tretspef_raw+los_group" = tibble::tribble(
        ~measure, ~pod, ~tretspef_raw, ~sitetret, ~baseline, ~principal, ~time_profiles, ~lwr_pi, ~median, ~upr_pi, ~los_group, # nolint
        "a", "ip", "100", "s1", 1, 2, c(1, 2), 3, 4, 5, "0-day",
        "b", "ip", "100", "s1", 2, 3, c(3, 4), 4, 5, 6, "1-7 days",
        "a", "ip", "100", "s1", 3, 4, c(5, 6), 5, 6, 7, "8-14 days",
        "b", "ip", "100", "s1", 4, 5, c(7, 8), 6, 7, 8, "15-21 days",
        "a", "ip", "200", "s1", 2, 1, c(9, 0), 4, 5, 3, "22+ days",
        "b", "ip", "200", "s1", 3, 2, c(1, 3), 5, 6, 4, "0-day",
        "a", "ip", "200", "s1", 4, 3, c(2, 5), 6, 7, 5, "1-7 days",
        "b", "ip", "200", "s1", 5, 4, c(3, 7), 7, 8, 6, "8-14 days",
        "a", "ip", "100", "s2", 5, 4, c(4, 9), 4, 5, 3, "15-21 days",
        "b", "ip", "100", "s2", 4, 3, c(5, 0), 5, 6, 4, "22+ days",
        "a", "ip", "100", "s2", 3, 2, c(6, 2), 6, 7, 5, "0-day",
        "b", "ip", "100", "s2", 2, 1, c(7, 4), 7, 8, 6, "1-7 days",
        "a", "ip", "200", "s2", 4, 5, c(8, 6), 5, 6, 1, "8-14 days",
        "b", "ip", "200", "s2", 3, 4, c(9, 8), 6, 7, 2, "15-21 days",
        "a", "ip", "200", "s2", 2, 3, c(0, 0), 7, 8, 3, "22+ days",
        "b", "ip", "200", "s2", 1, 2, c(1, 9), 8, 9, 4, "0-day"
      ),
      "sex+age_group" = tibble::tribble(
        ~sitetret, ~pod, ~sex, ~age_group, ~measure, ~baseline, ~principal, ~median, ~lwr_pi, ~upr_pi, # nolint
        "s1", "ip", 1, "0",       "a", 1, 2, 4, 3, 5,
        "s1", "ip", 1, "85+",     "b", 2, 3, 5, 4, 6,
        "s1", "ip", 1, "65-74",   "a", 4, 5, 7, 6, 8,
        "s1", "ip", 1, "16-17",   "b", 2, 1, 5, 4, 3,
        "s1", "ip", 1, "18-34",   "a", 3, 2, 6, 5, 4,
        "s1", "ip", 1, "35-49",   "b", 4, 3, 7, 6, 5,
        "s1", "ip", 1, "5-9",     "a", 3, 4, 6, 5, 7,
        "s1", "ip", 1, "50-64",   "b", 5, 4, 8, 7, 6,
        "s2", "ip", 1, "10-15",   "a", 5, 4, 5, 4, 3,
        "s2", "ip", 1, "75-84",   "b", 4, 3, 6, 5, 4,
        "s2", "ip", 1, "1-4",     "a", 3, 2, 7, 6, 5,
        "s2", "ip", 1, "Unknown", "b", 2, 1, 8, 7, 6
      )
    )
  )
  m <- mock(r$results[[1]], r$results[[2]], r$results[[3]], r$results)
  stub(patch_results, "patch_principal", m)
  stub(patch_results, "patch_step_counts", m)

  expected <- list(
    results = list(
      "tretspef_raw" = tibble::tribble(
        ~measure, ~pod, ~tretspef_raw, ~sitetret, ~baseline, ~principal, ~time_profiles, ~lwr_pi, ~median, ~upr_pi,
        "a", "op", "100", "s1", 1, 2, c(1, 2), 3, 4, 5,
        "a", "ip", "100", "s1", 4, 6, c(6, 8), 8, 10, 12,
        "b", "ip", "100", "s1", 6, 8, c(10, 12), 10, 12, 14,
        "a", "ip", "200", "s1", 6, 4, c(11, 5), 10, 12, 8,
        "b", "ip", "200", "s1", 8, 6, c(4, 10), 12, 14, 10,
        "a", "ip", "100", "s2", 8, 6, c(10, 11), 10, 12, 8,
        "b", "ip", "100", "s2", 6, 4, c(12, 4), 12, 14, 10,
        "a", "ip", "200", "s2", 6, 8, c(8, 6), 12, 14, 4,
        "b", "ip", "200", "s2", 4, 6, c(10, 17), 14, 16, 6
      ),
      "tretspef_raw+los_group" = r$results[["tretspef_raw+los_group"]] |>
        dplyr::mutate(
          dplyr::across(
            "los_group",
            \(.x) {
              forcats::fct_relevel(
                .x,
                c("0-day", "1-7 days", "8-14 days", "15-21 days", "22+ days")
              )
            }
          )
        ) |>
        dplyr::arrange(.data$pod, .data$measure, .data$sitetret, .data$los_group),
      "sex+age_group" = r$results[["sex+age_group"]] |>
        dplyr::mutate(
          dplyr::across(
            "age_group",
            \(.x) {
              forcats::lvls_expand(
                .x,
                c(
                  "0",
                  "1-4",
                  "5-9",
                  "10-15",
                  "16-17",
                  "18-34",
                  "35-49",
                  "50-64",
                  "65-74",
                  "75-84",
                  "85+",
                  "Unknown"
                )
              )
            }
          )
        ) |>
        dplyr::arrange(
          .data$pod, .data$measure, .data$sitetret, .data$sex, .data$age_group
        )
    )
  )

  # act
  actual <- patch_results(r)

  # assert
  expect_equal(actual, expected)
  expect_called(m, 4)
  expect_args(m, 1, r$results[[1]], "tretspef_raw")
  expect_args(m, 2, r$results[[2]], "tretspef_raw+los_group")
  expect_args(m, 3, r$results[[3]], "sex+age_group")
  expect_args(m, 4, r$results)
})

test_that("user_allowed_datasets returns correct values", {
  stub(get_user_allowed_datasets, "jsonlite::read_json", c("A", "B", "C"))

  for (i in list(NULL, "nhp_devs", "nhp_power_users")) {
    expect_equal(
      get_user_allowed_datasets(NULL),
      c(
        "synthetic", "A", "B", "C"
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
        "synthetic", i
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
        ~sitetret, ~baseline, ~principal, ~model_runs, ~pod, ~measure,
        "a", 100, 110, c(100, 200, 300), "a", "a",
        "a", 101, 111, c(101, 201, 301), "a", "b",
        "a", 102, 112, c(102, 202, 302), "b", "a",
        "a", 103, 113, c(103, 203, 303), "b", "b"
      )
    )
  )

  expected <- tibble::tribble(
    ~sitetret, ~baseline, ~principal, ~model_run, ~value, ~variant,
    "a", 100, 110, 1, 100, "a",
    "a", 100, 110, 2, 200, "a",
    "a", 100, 110, 3, 300, "b"
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

  actual <- get_aggregation(r, "a", "a", "tretspef", "a")

  expect_equal(actual, "tsa")
  expect_called(m, 1)
  expect_args(m, 1, expected, "a")
})

test_that("get_aggregation returns NULL if filter returns no rows", {
  r <- list(
    results = list(
      "sex+tretspef" = tibble::tibble(
        pod = "a",
        measure = "b",
        value = 1
      )
    )
  )

  expect_null(get_aggregation(r, "a", "x", "tretspef"))
  expect_null(get_aggregation(r, "x", "b", "tretspef"))
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
    ~sitetret, ~x, ~v,
    "x", "a", 1,
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

test_that("get_time_profiles extracts the time profiles correctly", {
  # arrange
  r <- list(
    params = list(
      start_year = 2020,
      end_year = 2030
    ),
    results = list(
      default = tibble::tibble(
        baseline = 0,
        principal = 10,
        model_runs = list(20:40),
        time_profiles = list(
          1:9
        ),
        lwr_pi = 20,
        median = 30,
        upr_pi = 40
      )
    )
  )
  # act
  actual <- get_time_profiles(r, "default")

  # assert
  expect_equal(
    actual,
    tibble::tibble(value = 0:10, year = 2020:2030)
  )
})
