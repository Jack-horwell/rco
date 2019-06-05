context("opt_constant_folding")

test_that("correctly constant fold", {
  code <- paste(
    "x <- - 2 + (4 - 3)",
    "x <- - 1 + 2 - 3 * 4 / 5 ^ 6",
    "x <- (1000 + 2 - 3 * 4) / 5 ^ (6 - 1)",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 >  3 * 1",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 >= 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 <  3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 <=  3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 == 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 & TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 & FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 | TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 | FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 && TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 && FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 || TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 || FALSE",
    "y <- 14 + 14 + x + 14 + 14",
    "for (i in 1:100) {",
    "  i <- i + 7 * 3",
    "}",
    sep = "\n")
  opt_code <- opt_constant_folding(list(code), fold_floats = TRUE)$codes[[1]]
  expect_equal(opt_code, paste(
    "x <- -1",
    "x <- 0.999232",
    "x <- 0.3168",
    "x <- 0.999232",
    "x <- FALSE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "y <- 28 + x + 14 + 14",
    "for (i in 1:100) {",
    "  i <- i + 21",
    "}",
    sep = "\n"
  ))
})

test_that("dont fold floats", {
  code <- paste(
    "x <- - 2 + (4 - 3)",
    "x <- - 1 + 2 - 3 * 4 / 5 ^ 6",
    "x <- (1000 + 2 - 3 * 4) / 5 ^ (6 - 1)",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 >  3 * 1",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 >= 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 <  3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 <=  3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 == 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 & TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 & FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 | TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 | FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 && TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 && FALSE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 || TRUE",
    "x <- 2 - 3 * 4 / 5 ^ 6 - 1 != 3 || FALSE",
    "y <- 14 + 14 + x + 14 + 14",
    "for (i in 1:100) {",
    "  i <- i + 7 * 3",
    "}",
    sep = "\n")
  opt_code <- opt_constant_folding(list(code), fold_floats = FALSE)$codes[[1]]
  expect_equal(opt_code, paste(
    "x <- -1",
    "x <- 1 - 12 / 15625",
    "x <- 990 / 3125",
    "x <- 2 - 12 / 15625 - 1",
    "x <- FALSE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- TRUE",
    "x <- FALSE",
    "x <- TRUE",
    "x <- TRUE",
    "y <- 28 + x + 14 + 14",
    "for (i in 1:100) {",
    "  i <- i + 21",
    "}",
    sep = "\n"
  ))
})

test_that("constant fold in while", {
  code <- paste(
    "i <- 0 * 512;",
    "n <- 100",
    "res <- 0",
    "while (i <n) {",
    "  (TRUE || 0 / 2 == 0)",
    "  if (TRUE || 0 / 2 == 0)",
    "    i <- (0 + (1^1)) * (i / 1)",
    "  if (0+i %% 2 == 0)",
    "    res <- res + 1",
    "  i <- i + 1",
    "}",
    sep = "\n")
  opt_code <- opt_constant_folding(list(code))$codes[[1]]
  expect_equal(opt_code, paste(
    "i <- 0;",
    "n <- 100",
    "res <- 0",
    "while (i <n) {",
    "  TRUE",
    "  if (TRUE)",
    "    i <- 1 * (i / 1)",
    "  if (0+i %% 2 == 0)",
    "    res <- res + 1",
    "  i <- i + 1",
    "}",
    sep = "\n"
  ))

  env1 <- new.env()
  eval(parse(text = code), envir = env1)
  env2 <- new.env()
  eval(parse(text = opt_code), envir = env2)

  expect_equal(as.list(env1), as.list(env2))
})

test_that("constant fold in function", {
  code <- paste(
    "foo <- function() {",
    "  return(2 - 3 * 4 / 5 ^ 6 - 1 != 3 || FALSE)",
    "}",
    "",
    "bar <- function(x) {",
    "  return(2 - 3 * 4 / 5 ^ 6 - 1 != 3 && x)",
    "}",
    "",
    "res <- bar(TRUE)",
    sep = "\n")
  opt_code <- opt_constant_folding(list(code))$codes[[1]]
  expect_equal(opt_code, paste(
    "foo <- function() {",
    "  return(TRUE)",
    "}",
    "",
    "bar <- function(x) {",
    "  return(TRUE && x)",
    "}",
    "",
    "res <- bar(TRUE)",
    sep = "\n"
  ))

  env1 <- new.env()
  eval(parse(text = code), envir = env1)
  env2 <- new.env()
  eval(parse(text = opt_code), envir = env2)
  env1 <- as.list(env1)
  env2 <- as.list(env2)

  expect_equal(names(env1), names(env1))
  expect_equal(env1$res, env2$res)
})

test_that("constant fold in function call", {
  code <- paste(
    "sum(1*7, 8/2)",
    sep = "\n")
  opt_code <- opt_constant_folding(list(code))$codes[[1]]
  expect_equal(opt_code, paste(
    "sum(7, 4)",
    sep = "\n"
  ))

  env1 <- new.env()
  eval(parse(text = code), envir = env1)
  env2 <- new.env()
  eval(parse(text = opt_code), envir = env2)
  env1 <- as.list(env1)
  env2 <- as.list(env2)

  expect_equal(names(env1), names(env1))
  expect_equal(env1$res, env2$res)
})