# --------------------------------------------------------------------------------
# Generate new class to hold the return object, comprising a tidy data frame
# for the summary statistics and a character vector that contains definitions
# of displays of summary statistics in the main table and a list of methods
# used to test for differences across groups in each variable.
# --------------------------------------------------------------------------------
tableone <- function(table, n, footer, caption, label) {
  if (!is.data.frame(table) | !is.list(n) | !is.vector(footer) |
      !is.character(caption) | !is.character(label)) {
    stop("Wrong data type(s) passed to constructor.")
  }
  structure(list(table=table,
                 n=n,
                 footer=footer,
                 caption=caption,
                 label=label), class = "tableone")
}

# --------------------------------------------------------------------------------
# Define a function that produces a tableone object.
# --------------------------------------------------------------------------------
tidy.tableone <- function(df, grpvar, testTypes=NULL, d=1, p.digits=3, fisher.simulate.p=FALSE, lbl="", caption="") {
  df <- as.data.frame(df)

  if (lbl=="") lbl <- an.id(9)

  # If the user specified a list of test types of valid length for continuous data, use them; otherwise, set all to "auto".
  if(length(testTypes)!=length(colnames(df))) {
    testTypes <- rep("auto", length(colnames(df)))
  }

  test.df <- data.frame(col.name = colnames(df),
                        test.type = testTypes,
                        stringsAsFactors = FALSE)

  # Create the table, beginning with an empty data frame
  out <- data.frame()
  for (i in seq_along(cols.except(df, grpvar))) {
    # Identify the variable to summarize for the current iteration
    sumvar <- colnames(df)[!(colnames(df) %in% grpvar)][i]

    # Make sure the current variable is labeled; throw an error if it is not.
    if(class(df[[sumvar]])[1] != "labelled") stop("Must label all covariates.")

    # If the variable is continuous, analyze by Wilcoxon or t-test
    if(class(df[[sumvar]])[2] %in% c("integer", "numeric")) {
      # If the user did not specify a test type then use a Wilcoxon rank-sum test if the distance between the mean and
      # median is > 0.25 standard deviations; otherwise use a t-test.
      if(test.df$test.type[test.df$col.name==sumvar] == "auto") {
        if(abs(mean(df[[sumvar]], na.rm=TRUE) - median(df[[sumvar]], na.rm=TRUE))/sd(df[[sumvar]], na.rm=TRUE) <= 0.25) {
          test.df$test.type[test.df$col.name==sumvar] <- "t"
        } else {
          test.df$test.type[test.df$col.name==sumvar] <- "w"
        }
      }

      # The old version based on a shapiro-wilks test:
      # if(test.df$test.type[test.df$col.name==sumvar] == "auto") {
      #   if(sw.test.robust(df[[sumvar]]) > 0.05) {
      #     test.df$test.type[test.df$col.name==sumvar] <- "t"
      #   } else {
      #     test.df$test.type[test.df$col.name==sumvar] <- "w"
      #   }
      # }

      # t-test
      if(test.df$test.type[test.df$col.name==sumvar]=="t") {
        test <- t.test(formula(paste0(sumvar, "~", grpvar)), data=df)
        method <- "Student's t-test (two-sided)"
        newrow <- data.frame(cbind(label(df[[sumvar]]),
                                   sum(!is.na(df[[sumvar]])),
                                   paste0(round(mean(df[df[[grpvar]]==levels(df[[grpvar]])[1], c(sumvar)], na.rm=TRUE), d=d),
                                          " +/- ",
                                          round(sd(df[df[[grpvar]]==levels(df[[grpvar]])[1], c(sumvar)], na.rm=TRUE), d=d)),
                                   paste0(round(mean(df[df[[grpvar]]==levels(df[[grpvar]])[2], c(sumvar)], na.rm=TRUE), d=d),
                                          " +/- ",
                                          round(sd(df[df[[grpvar]]==levels(df[[grpvar]])[2], c(sumvar)], na.rm=TRUE), d=d)),
                                   paste0(round(mean(df[, c(sumvar)], na.rm=TRUE), d=d),
                                          " +/- ",
                                          round(sd(df[, c(sumvar)], na.rm=TRUE), d=d)),
                                   paste0(fmt.pval(test$p.value, include.p=FALSE, latex=FALSE, digits=p.digits), ""),
                                   method))
        names(newrow) <- names(out)
        out <- rbind(out, newrow)
      } else {
        # Wilcoxon rank-sum test
        test <- tryCatch({
          wc.test <- wilcox.test(formula(paste0(sumvar, "~", grpvar), correct=FALSE), data=df)
        }, warning = function(w) {
          return(suppressWarnings(wilcox.test(formula(paste0(sumvar, "~", grpvar)), data=df, correct=FALSE)))
        }, error = function(e) {
          return("err")
        }, finally = function() {
          return(wc.test)
        })
        if(test[[1]]=="err") {
          wc.pval <- "."
        } else {
          wc.pval <- fmt.pval(test$p.value, include.p=FALSE, latex=FALSE, digits=p.digits)
        }
        method <- "Wilcoxon rank-sum test"
        newrow <- data.frame(cbind(label(df[[sumvar]]),
                                   sum(!is.na(df[[sumvar]])),
                                   paste0(round(median(df[df[[grpvar]]==levels(df[[grpvar]])[1], c(sumvar)], na.rm=TRUE), d=d),
                                          " (",
                                          round(quantile(df[df[[grpvar]]==levels(df[[grpvar]])[1], c(sumvar)], 0.25, na.rm=TRUE), d=d),
                                          ", ",
                                          round(quantile(df[df[[grpvar]]==levels(df[[grpvar]])[1], c(sumvar)], 0.75, na.rm=TRUE), d=d),
                                          ")"),
                                   paste0(round(median(df[df[[grpvar]]==levels(df[[grpvar]])[2], c(sumvar)], na.rm=TRUE), d=d),
                                          " (",
                                          round(quantile(df[df[[grpvar]]==levels(df[[grpvar]])[2], c(sumvar)], 0.25, na.rm=TRUE), d=d),
                                          ", ",
                                          round(quantile(df[df[[grpvar]]==levels(df[[grpvar]])[2], c(sumvar)], 0.75, na.rm=TRUE), d=d),
                                          ")"),
                                   paste0(round(median(df[, c(sumvar)], na.rm=TRUE), d=d),
                                          " (",
                                          round(quantile(df[, c(sumvar)], 0.25, na.rm=TRUE), d=d),
                                          ", ",
                                          round(quantile(df[, c(sumvar)], 0.75, na.rm=TRUE), d=d),
                                          ")"),
                                   wc.pval,
                                   method))
        names(newrow) <- names(out)
        out <- rbind(out, newrow)
      }
    }

    # If the variable is categorical, analyze by chi-squared or Fisher's exact
    if(class(df[[sumvar]])[2] %in% c("logical", "factor")) {

      # Construct a contingency table and run a chi-squared test
      tb <- table(df[[sumvar]], df[[grpvar]])
      test <- tryCatch({
        cs.test <- chisq.test(df[[sumvar]], df[[grpvar]])
      }, warning = function(w) {
        return(suppressWarnings(chisq.test(df[[sumvar]], df[[grpvar]])))
      }, error = function(e) {
        return("err")
      }, finally = function() {
        return(cs.test)
      })
      if(test[[1]]=="err") {
        pval <- "."
        method <- ""
      } else {
        pval <- fmt.pval(test$p.value, include.p=FALSE, latex=FALSE, digits=p.digits)
        method <- "Pearson's chi-squared test"
      }

      # If any cells have expected value < 5 and the chi2 test didn't error out, switch to Fisher's exact test.
      if(test[[1]]!="err") {
        if (min(test$expected) < 5) {
          test <- tryCatch({
            fish.test <- fisher.test(df[[sumvar]], df[[grpvar]], simulate.p.value=fisher.simulate.p)
          }, warning = function(w) {
            return(suppressWarnings(fisher.test(df[[sumvar]], df[[grpvar]])))
          }, error = function(e) {
            return("err")
          }, finally = function() {
            return(fish.test)
          })
          if(test[[1]]=="err") {
            pval <- fmt.pval(fisher.test(df[[sumvar]], df[[grpvar]], simulate.p.value=TRUE)$p.value,
                             include.p = FALSE, latex = FALSE, digits = p.digits)
            method <- "Fisher's exact test with simulated p-value"
          } else {
            pval <- fmt.pval(test$p.value, include.p=FALSE, latex=FALSE, digits=p.digits)
            method <- "Fisher's exact test"
          }
          if(class(test)=="try-error") {
            test <- fisher.test(df[[sumvar]], df[[grpvar]], simulate.p.value=TRUE)
          }
        }
      }
      newrow <- data.frame(cbind(label(df[[sumvar]]),
                                 sum(!is.na(df[[sumvar]]) & !is.na(df[[grpvar]])),
                                 " ",
                                 " ",
                                 " ",
                                 pval,
                                 method))
      names(newrow) <- names(out)
      out <- rbind(out, newrow)

      # Identify level labels:
      if(class(df[[sumvar]])[2]=="logical") {
        level.labs <- c("FALSE", "TRUE")
      } else {
        level.labs <- levels(df[[sumvar]])
      }

      method <- ""
      for (j in 1:nrow(tb)) {
        newrow <- data.frame(cbind(paste0(" - ", level.labs[j]),
                                   " ",
                                   paste0(fmt.pct(tb[j,1]/sum(tb[,1]), latex=FALSE), " (", tb[j,1], ")"),
                                   paste0(fmt.pct(tb[j,2]/sum(tb[,2]), latex=FALSE), " (", tb[j,2], ")"),
                                   paste0(fmt.pct(sum(tb[j,])/sum(tb[,]), latex=FALSE), " (", sum(tb[j,]), ")"),
                                   " ", method))
        names(newrow) <- names(out)
        out <- rbind(out, newrow)
      }
    }
  }


  for (l in 1:ncol(out)) {
    out[,l] <- as.character(out[,l])
  }

  colnames(out) <- c(" ", "n", levels(df[[grpvar]])[1], levels(df[[grpvar]])[2], "Combined", "p", "method.name")

  # Identify methods used
  methods.used <- data.frame(method.name = unique(out$method.name[out$method.name!=""]),
                             method = letters[seq(1:length(unique(out$method.name[out$method.name!=""])))],
                             stringsAsFactors = FALSE)
  out$sort <- seq(1:nrow(out))
  out <- merge(out, methods.used,
               by="method.name",
               all.x=TRUE)
  out <- out[order(out$sort),]
  out$sort <- NULL
  out$method[is.na(out$method)] <- ""
  out$method.name <- NULL

  # Replace NaN% with 0%
  out[[levels(df[[grpvar]])[1]]] <- gsub(pattern="NaN",
                                         replacement="0",
                                         x=out[[levels(df[[grpvar]])[1]]])
  out[[levels(df[[grpvar]])[1]]] <- gsub(pattern="NaN",
                                         replacement="0",
                                         x=out[[levels(df[[grpvar]])[1]]])

  # Generate footer
  footer <- c()
  if("Wilcoxon rank-sum test" %in% methods.used$method.name) {
    footer <- c(footer, "x.x (x.x, x.x) indicates median and inter-quartile range.")
  }
  if("Student's t-test (two-sided)" %in% methods.used$method.name) {
    footer <- c(footer, "x +/- x indicates mean +/- standard deviation.")
  }
  for(k in 1:nrow(methods.used)) {
    footer <- c(footer, paste0("(", methods.used$method[k], ") ", methods.used$method.name[k]))
  }

  # Calculate n for each group
  n <- list(n.grp1 = nrow(df[df[[grpvar]]==levels(df[[grpvar]])[1],]),
            n.grp2 = nrow(df[df[[grpvar]]==levels(df[[grpvar]])[2],]),
            n.combined = nrow(df[!is.na(df[[grpvar]]),]))

  return(tableone(table = out,
                  n = n,
                  footer = footer,
                  caption = caption,
                  label = lbl))
}

