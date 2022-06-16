library(mockery)

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_token_fn
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_token_fn calls get_managed_token if env var isn't set", {
  m1 <- mock("get_managed_token")
  m2 <- mock("get_azure_token")

  stub(batch_token_fn, "AzureAuth::get_managed_token", m1)
  stub(batch_token_fn, "AzureAuth::get_azure_token", m2)

  withr::local_envvar(c(
    AAD_TENANT_ID = "",
    AAD_APP_ID = "",
    AAD_APP_SECRET = ""
  ))

  expect_equal(batch_token_fn("resource"), "get_managed_token")
  expect_called(m1, 1)
  expect_called(m2, 0)
  expect_args(m1, 1, "resource")
})

test_that("batch_token_fn calls get_azure_token if env var is set", {
  m1 <- mock("get_managed_token")
  m2 <- mock("get_azure_token")

  stub(batch_token_fn, "AzureAuth::get_managed_token", m1)
  stub(batch_token_fn, "AzureAuth::get_azure_token", m2)

  withr::local_envvar(c(
    AAD_TENANT_ID = "tenant",
    AAD_APP_ID = "app",
    AAD_APP_SECRET = "secret"
  ))

  expect_equal(batch_token_fn("resource"), "get_azure_token")
  expect_called(m1, 0)
  expect_called(m2, 1)
  expect_args(m2, 1, "resource", "tenant", "app", "secret")
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_pools
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_pools gets a token", {
  m <- mock()

  stub(batch_get_pools, "batch_token_fn", m)

  stub(batch_get_pools, "AzureAuth::extract_jwt", "token")

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(value = NULL))

  batch_get_pools()

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_pools calls the correct API", {
  m <- mock()

  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", m)
  stub(batch_get_pools, "httr::add_headers", list)
  stub(batch_get_pools, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_pools()

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = "pools",
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_pools returns the expected data", {
  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(
    value = list(
      list(
        id = 0,
        state = 1,
        thing = 2,
        vmSize = 3,
        ignore = 4,
        currentDedicatedNodes = 5,
        currentLowPriorityNodes = 6,
        targetDedicatedNodes = 7,
        targetLowPriorityNodes = 8
      ),
      list(
        id = 8,
        state = 7,
        thing = 6,
        vmSize = 5,
        ignore = 4,
        currentDedicatedNodes = 3,
        currentLowPriorityNodes = 2,
        targetDedicatedNodes = 1,
        targetLowPriorityNodes = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_pools()
  expected <- tibble::tribble(
    ~id,
    ~state,
    ~thing,
    ~vmSize,
    ~currentDedicatedNodes,
    ~currentLowPriorityNodes,
    ~targetDedicatedNodes,
    ~targetLowPriorityNodes,
    0, 1, 2, 3, 5, 6, 7, 8,
    8, 7, 6, 5, 3, 2, 1, 0
  )

  expect_equal(actual, expected)
})

test_that("batch_get_pools returns NULL if no data returned", {
  stub(batch_get_pools, "batch_token_fn", "token")
  stub(batch_get_pools, "AzureAuth::extract_jwt", identity)

  stub(batch_get_pools, "httr::GET", "get response")
  stub(batch_get_pools, "httr::add_headers", "headers")
  stub(batch_get_pools, "httr::content", list(value = NULL))

  expect_null(batch_get_pools())
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_jobs
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_jobs gets a token", {
  m <- mock()

  stub(batch_get_jobs, "batch_token_fn", m)

  stub(batch_get_jobs, "AzureAuth::extract_jwt", "token")

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  batch_get_jobs()

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_jobs calls the correct API", {
  m <- mock()

  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", m)
  stub(batch_get_jobs, "httr::add_headers", list)
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_jobs()

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = "jobs",
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_jobs returns the expected data", {
  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(
    value = list(
      list(
        id = 0,
        creationTime = "2022-01-01 01:23:45",
        state = 2,
        executionInfo.startTime = "2022-01-01 11:22:33",
        executionInfo.endTime = "2022-02-02 22:33:11",
        executionInfo.x = 5
      ),
      list(
        id = 5,
        creationTime = "2022-01-01 10:32:54",
        state = 3,
        executionInfo.startTime = "2022-03-03 11:33:22",
        executionInfo.x = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_jobs()
  d <- lubridate::as_datetime
  expected <- tibble::tribble(
    ~id,
    ~creationTime,
    ~state,
    ~startTime,
    ~endTime,
    0, d("2022-01-01 01:23:45"), 2, d("2022-01-01 11:22:33"), d("2022-02-02 22:33:11"),
    5, d("2022-01-01 10:32:54"), 3, d("2022-03-03 11:33:22"), NA
  )

  expect_equal(actual, expected)
})

test_that("batch_get_jobs returns NULL if no data returned", {
  stub(batch_get_jobs, "batch_token_fn", "token")
  stub(batch_get_jobs, "AzureAuth::extract_jwt", identity)

  stub(batch_get_jobs, "httr::GET", "get response")
  stub(batch_get_jobs, "httr::add_headers", "headers")
  stub(batch_get_jobs, "httr::content", list(value = NULL))

  expect_null(batch_get_jobs())
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_get_tasks
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_get_tasks gets a token", {
  m <- mock()

  stub(batch_get_tasks, "batch_token_fn", m)

  stub(batch_get_tasks, "AzureAuth::extract_jwt", "token")

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  batch_get_tasks("id")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_get_tasks calls the correct API", {
  m <- mock()

  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", m)
  stub(batch_get_tasks, "httr::add_headers", list)
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_get_tasks("id")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs", "id", "tasks"),
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

test_that("batch_get_tasks returns the expected data", {
  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(
    value = list(
      list(
        id = 0,
        displayName = 1,
        state = 2,
        creationTime = "2022-01-01 01:23:45",
        executionInfo.startTime = "2022-01-01 11:22:33",
        executionInfo.endTime = "2022-02-02 22:33:11",
        executionInfo.result = "success",
        executionInfo.exitCode = 3,
        executionInfo.x = 4
      ),
      list(
        id = 4,
        displayName = 3,
        state = 2,
        creationTime = "2022-01-01 10:32:54",
        executionInfo.startTime = "2022-03-03 11:33:22",
        executionInfo.result = "failure",
        executionInfo.exitCode = 1,
        executionInfo.x = 0
      )
    )
  ))

  withr::local_envvar(c("BATCH_URL" = "url"))
  actual <- batch_get_tasks("id")
  d <- lubridate::as_datetime
  expected <- tibble::tribble(
    ~id,
    ~displayName,
    ~state,
    ~creationTime,
    ~startTime,
    ~endTime,
    ~result,
    ~exitCode,
    0, 1, 2, d("2022-01-01 01:23:45"), d("2022-01-01 11:22:33"), d("2022-02-02 22:33:11"), "success", 3,
    4, 3, 2, d("2022-01-01 10:32:54"), d("2022-03-03 11:33:22"), NA, "failure", 1
  )

  expect_equal(actual, expected)
})

test_that("batch_get_tasks returns NULL if no data returned", {
  stub(batch_get_tasks, "batch_token_fn", "token")
  stub(batch_get_tasks, "AzureAuth::extract_jwt", identity)

  stub(batch_get_tasks, "httr::GET", "get response")
  stub(batch_get_tasks, "httr::add_headers", "headers")
  stub(batch_get_tasks, "httr::content", list(value = NULL))

  expect_null(batch_get_tasks("id"))
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_delete_job
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_delete_job gets a token", {
  m <- mock()

  stub(batch_delete_job, "batch_token_fn", m)

  stub(batch_delete_job, "AzureAuth::extract_jwt", "token")

  stub(batch_delete_job, "httr::DELETE", "delete")
  stub(batch_delete_job, "httr::add_headers", "headers")

  batch_delete_job("id")

  expect_called(m, 1)
  expect_args(m, 1, "https://batch.core.windows.net/")
})

test_that("batch_delete_job calls the correct API", {
  m <- mock()

  stub(batch_delete_job, "batch_token_fn", "token")
  stub(batch_delete_job, "AzureAuth::extract_jwt", identity)

  stub(batch_delete_job, "httr::DELETE", m)
  stub(batch_delete_job, "httr::add_headers", list)

  withr::local_envvar(c("BATCH_URL" = "url"))
  batch_delete_job("id")

  expect_called(m, 1)
  expect_args(m, 1,
    "url",
    path = c("jobs", "id"),
    query = list("api-version" = "2022-01-01.15.0"),
    list(
      "Authorization" = "Bearer token"
    )
  )
})

# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# batch_job_status
# ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

test_that("batch_job_status calls batch_get_tasks", {
  m <- mock(tibble())

  stub(batch_job_status, "batch_get_tasks", m)

  batch_job_status("id")

  expect_called(m, 1)
  expect_args(m, 1, "id")
})

test_that("batch_job_status returns running when the job is still running", {
  m <- mock(tibble(), tibble(result = c("running", "success")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "running")
  expect_equal(batch_job_status("id"), "running")
})

test_that("batch_job_status returns failure when a task has failed", {
  m <- mock(tibble(result = c("running", "success", "failure")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "failure")
})

test_that("batch_job_status returns success when all tasks have successfully completed", {
  m <- mock(tibble(result = c("success", "success")))

  stub(batch_job_status, "batch_get_tasks", m)

  expect_equal(batch_job_status("id"), "success")
})
