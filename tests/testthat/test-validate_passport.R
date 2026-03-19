test_that("validate_passport returns TRUE for a complete passport", {
  p <- build_passport(
    object_id    = "TestObj", rds_self = "001",
    animal_id    = "M01", species = "Mus musculus", sex = "male",
    age          = "P60", condition = "control", tissue = "lung",
    project      = "test_project", researcher = "Sedat",
    date         = "2026-03-19", notes = "",
    parent_id    = "root", rds_parent = "root",
    lineage      = character(0), children = character(0),
    rds_children = character(0),
    custom_keys  = character(0), custom_vals = character(0)
  )

  expect_true(validate_passport(p))
})

test_that("validate_passport returns FALSE when required fields are missing", {
  incomplete <- list(object_id = "TestObj", rds_self = "001")
  expect_false(validate_passport(incomplete))
})

test_that("validate_passport returns FALSE for empty list", {
  expect_false(validate_passport(list()))
})
