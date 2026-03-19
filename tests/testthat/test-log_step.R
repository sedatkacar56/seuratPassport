test_that("build_log_entry returns a list with required fields", {
  entry <- build_log_entry(
    step    = "NormalizeData",
    n_cells = 5000L,
    n_genes = 20000L,
    params  = list(method = "LogNormalize", scale_factor = 10000)
  )

  expect_type(entry, "list")
  expect_equal(entry$step,    "NormalizeData")
  expect_equal(entry$n_cells, 5000L)
  expect_equal(entry$n_genes, 20000L)
  expect_equal(entry$params$method, "LogNormalize")
  expect_true(!is.null(entry$time))
})

test_that("append_log_entry adds entry to empty log", {
  entry <- build_log_entry("QC", 8000L, 25000L, list())
  log   <- append_log_entry(list(), entry)

  expect_length(log, 1)
  expect_equal(log[[1]]$step, "QC")
})

test_that("append_log_entry appends to existing log", {
  e1  <- build_log_entry("NormalizeData", 8000L, 25000L, list())
  e2  <- build_log_entry("ScaleData",     8000L, 25000L, list())
  log <- append_log_entry(list(), e1)
  log <- append_log_entry(log,    e2)

  expect_length(log, 2)
  expect_equal(log[[1]]$step, "NormalizeData")
  expect_equal(log[[2]]$step, "ScaleData")
})

test_that("append_log_entry preserves order of entries", {
  steps <- c("QC", "NormalizeData", "FindVariableFeatures", "ScaleData", "RunPCA")
  log   <- list()
  for (s in steps) {
    log <- append_log_entry(log, build_log_entry(s, 5000L, 20000L, list()))
  }

  expect_length(log, 5)
  for (i in seq_along(steps)) {
    expect_equal(log[[i]]$step, steps[i])
  }
})
