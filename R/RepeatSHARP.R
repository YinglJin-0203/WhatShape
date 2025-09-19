#' Implement SHARP test repeatedly on a dose-response curve
#'
#' The SHARP shape detection test relies on a underlying random generation process, which may lead to ambiguous test results. To examin its uncertainty and obtain a more robust conclusion, we may with to repet the test on the same data.
#'
#' @importFrom dplyr bind_rows
#'
#' @param df Dose-response curve data in a table format. Dose and responses should be two separate columns with numeric values.
#' @param nRep Number of repetitions of SHAPR test. Integer.
#' @param mixed Logical indicator (TRUE for FALSE) for whether or not to use the mixed-model-based test.
#' @param xName The column name for dose. Character string.
#' @param yName The column name for response. Character string.
#' @param rName The column name for random effect. Only used if mixed = TRUE. Character string.git a
#' @param niter An integer for the number of iterations in SHARP test procedure
#'
#' @return A dataframe of test results from all repititions. Each row is one single test with four p values after Holm adjustment.
#'
#' @examples
#' # Simulate dose-response data
#' x <- seq(0, 1, length.out = 48)
#' y <- 2*sqrt(x)+rnorm(48)
#' y[17:32] <- y[17:32]+0.5
#' y[33:48] <- y[33:48]+1
#' curve <- data.frame(x, y)
#' curve$rep <- rep(1:3, each = 16)
#'
#' # Fixed-model based test
#' RepeatSHARP(curve, nRep = 10, xName = "x", yName = "y")
#'
#' # Mixed-model based test
#' RepeatSHARP(curve, nRep = 10, mixed = T, xName = "x", yName = "y", rName = "rep")


RepeatSHARP <- function(df, nRep, mixed=F, xName, yName, rName, niter=1000){
  pval_list <- lapply(1:nRep,
                      function(r){
                        SHARPtest(df=df, mixed=mixed, xName=xName, yName=yName, niter=niter)
                        })
  pval_df <- bind_rows(pval_list, .id="Rep")
  return(pval_df)
}
