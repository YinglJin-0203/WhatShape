#' Implement SHARP test one on a dose-response curve
#'
#' @param df Dose-response curve data in a table format. Dose and responses should be two separate columns with numeric values.
#' @param mixed Logical indicator (TRUE for FALSE) for whether or not to use the mixed-model-based test.
#' @param xName The column name for dose. Character string.
#' @param yName The column name for response. Character string.
#' @param rName The column name for random effect. Only used if mixed = TRUE. Character string.
#' @param niter An integer for the number of iterations in SHARP test procedure
#'
#' @return A vector of four p values after Holm adjustment, indicating the significance of four different shapes types.
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
#' SHARPtest(curve, xName = "x", yName = "y")
#'
#' # Mixed-model based test
#' SHARPtest(curve, mixed = T, xName = "x", yName = "y", rName = "rep")

SHARPtest <- function(df, mixed = F, xName, yName, rName, niter=1000){
  # mixed model based
  df <- as.data.frame(df)
  if(mixed == T){
    shape_test <- SRMERS::MERS(y=yName, xMain=xName, xRand=rName,
                   dataset = df, nIter=niter)
  }
  # not mixed model based
  else{
    shape_test <-SRMERS::FERS(y=yName, xMain=xName,dataset = df, nIter=niter)
    }

  # Holm adjustment
  test_p <- c(increase = shape_test$PValueIncr,
              decrease = shape_test$PValueDecr,
              convex = shape_test$PValueConv,
              concave = shape_test$PValueConc)
  sort_id <- order(test_p)
  adj_p <- p.adjust(test_p[sort_id], method="holm")

  return(adj_p)
}




