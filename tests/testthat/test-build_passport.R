test_that("build_passport returns a list with all required fields", {
  p <- build_passport(
    object_id    = "TestObj",
    rds_self     = "001",
    animal_id    = "M01",
    species      = "Mus musculus",
    sex          = "male",
    age          = "P60",
    condition    = "control",
    tissue       = "lung",
    project      = "test_project",
    researcher   = "Sedat",
    date         = "2026-03-19",
    notes        = "test notes",
    parent_id    = "root",
    rds_parent   = "root",
    lineage      = character(0),
    children     = character(0),
    rds_children = character(0),
    custom_keys  = character(0),
    custom_vals  = character(0)
  )

  expect_type(p, "list")
  expect_equal(p$object_id,  "TestObj")
  expect_equal(p$rds_self,   "001")
  expect_equal(p$animal_id,  "M01")
  expect_equal(p$species,    "Mus musculus")
  expect_equal(p$sex,        "male")
  expect_equal(p$age,        "P60")
  expect_equal(p$condition,  "control")
  expect_equal(p$tissue,     "lung")
  expect_equal(p$project,    "test_project")
  expect_equal(p$researcher, "Sedat")
  expect_equal(p$date,       "2026-03-19")
  expect_equal(p$notes,      "test notes")
  expect_equal(p$parent_id,  "root")
  expect_equal(p$rds_parent, "root")
  expect_true(!is.null(p$created))
})

test_that("build_passport appends custom fields correctly", {
  p <- build_passport(
    object_id    = "TestObj",
    rds_self     = "001",
    animal_id    = "", species = "", sex = "", age = "",
    condition    = "", tissue  = "", project = "",
    researcher   = "", date    = "2026-03-19", notes = "",
    parent_id    = "root", rds_parent = "root",
    lineage      = character(0),
    children     = character(0),
    rds_children = character(0),
    custom_keys  = c("genome_build", "batch"),
    custom_vals  = c("mm10", "batch_01")
  )

  expect_equal(p$genome_build, "mm10")
  expect_equal(p$batch,        "batch_01")
})

test_that("build_passport handles lineage vector correctly", {
  p <- build_passport(
    object_id    = "ChildObj",
    rds_self     = "002",
    animal_id    = "", species = "", sex = "", age = "",
    condition    = "", tissue  = "", project = "",
    researcher   = "", date    = "2026-03-19", notes = "",
    parent_id    = "ParentObj",
    rds_parent   = "001",
    lineage      = c("root", "ParentObj"),
    children     = character(0),
    rds_children = character(0),
    custom_keys  = character(0),
    custom_vals  = character(0)
  )

  expect_equal(length(p$lineage), 2)
  expect_equal(p$lineage[1], "root")
  expect_equal(p$lineage[2], "ParentObj")
  expect_equal(p$parent_id,  "ParentObj")
})
