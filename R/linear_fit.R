#' Linear model
#'
#' Fit linear model E[Y | X] = offset + beta * x
#' @param y n-vector of outcome
#' @param x design matrix
#' @param offset n-vector of offset
#' @param variance whether to return the variance and components for the calculation
#' @examples
#' x <- rep(1:3, each = 10)
#' y <- rnorm(30, 5 + 2 * x, 1)
#'
#' lm_result <- linear_fit(y, cbind(1, x))
#' lm_result$summary
#' @export
linear_fit <- function(y, x, offset = rep(0, length(y)),
                        variance = TRUE) {

  if (class(x)[[1]] %in% c("matrix", "data.frame", "array")) {
    x <- as.matrix(x)
  } else {
    x <- matrix(x, nrow = nn)
  }

  ## estimate the regression coefficients

  param <- c(solve(t(x) %*% x) %*% t(x) %*% (y - offset))

  ## linear predictor
  PREDICT <- c(x %*% param)
  if (variance) {
    ## Jacobian matrix of the estimating function
    J <- - t(x) %*% x
    U <- x * c(y - offset - x %*% param)
    Umat <- t(U) %*% U

    Jinv <- solve(J)

    VAR <- Jinv %*% Umat %*% t(Jinv)
    SE <- sqrt(diag(VAR))

    summ <- matrix(NA, nrow = length(param), ncol = 4)
    summ[, 1] <- param
    summ[, 2] <- SE
    summ[, 3] <- param / SE
    summ[, 4] <- pchisq((param / SE) ^ 2, df = 1, lower.tail = F)
    if (is.null(colnames(x))) {
      if (ncol(x) == 1) {
        rownames(summ) <- "x"
      } else {
        rownames(summ) <- paste0("x", 1:ncol(x))
      }
    } else {
      rownames(summ) <- colnames(x)
    }

    colnames(summ) <- c("Estimate", "Std. Error", "z value",
                        "Pr(>|z|)")
    return(list(ESTIMATE = param,
                PREDICT = PREDICT,
                SE = SE,
                JACOBIAN = J,
                EST_FUNC = U,
                Umat = Umat,
                summary = summ))
  } else {
    return(list(ESTIMATE = param, PREDICT = PREDICT))
  }
}
