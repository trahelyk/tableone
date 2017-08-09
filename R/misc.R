library

##################################################################################################
# Generate a random alphanumeric string of length n. These are not necessarily unique.
##################################################################################################
an.id <- function(n) {
  return(paste(replicate(n, c(letters, round(runif(26,0,9)))[round(runif(1,1,52))]), collapse=""))
}

##################################################################################################
# Return all the column names of a data frame except for those specified
##################################################################################################
cols.except <- function(df, except) {
  colnames(df)[!(colnames(df) %in% except)]
}

##################################################################################################
#Apply lables to a dataframe
##################################################################################################
apply.labels <- function(df, labels) {
  for(i in 1:length(df)) {
    label(df[[i]]) <- labels[i]
  }
  return(df)
}

##################################################################################################
# Returns a character-formatted version of a p-value, including LaTeX markup
# to indicate when p is less than the minimum value in the specified number
# of decimal-place digits.
##################################################################################################
fmt.pval <- function(pval, digits=2, include.p=TRUE, latex=FALSE, md=FALSE) {
  p.df <- as.data.frame(cbind(1:length(pval), pval))
  colnames(p.df) <- c("order", "p")
  if(latex) {
    lt <- "\\textless"
  } else {
    lt <- "<"
  }
  if(md) {
    spc <- "\ "
  } else {
    spc <- " "
  }
  if(include.p) {
    prefix.1 <- paste0("p", spc, lt, spc)
    prefix.2 <- paste0("p", spc, "=", spc)
  }
  else{
    prefix.1 <- lt
    prefix.2 <- ""
  }
  p.df[p.df$p*(10^(digits)) < 1 & !is.na(p.df$p),c("p.fmt")] <- paste0(prefix.1, format(1/(10^digits), scientific=FALSE))
  p.df[p.df$p*(10^(digits)) >= 1 & !is.na(p.df$p),c("p.fmt")] <- paste0(prefix.2,
                                                                        as.character(round(p.df$p[p.df$p*(10^(digits)) >= 1 & !is.na(p.df$p)],digits)))
  p.df[is.na(p.df$p),c("p.fmt")] <- ""

  return(p.df$p.fmt)
}

##################################################################################################
# Convert proportion (0 < p < 1) to a percent (0 < pct < 100)
##################################################################################################
fmt.pct <- function(x, d=0, as.numeric=FALSE, latex=FALSE) {
  if(latex) pct.char <- "\\%"
  else pct.char <- "%"
  if(as.numeric)
    return(as.numeric(format(round(x*100,d), nsmall=d)))
  else
    return(paste0(format(round(x*100,d), nsmall=d), pct.char))
}
