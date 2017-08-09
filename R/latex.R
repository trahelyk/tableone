# --------------------------------------------------------------------------------
# Define a generic function for formatting things in LaTeX
# --------------------------------------------------------------------------------
tex <- function(x, row.names=FALSE) UseMethod("tex")
tex.default <- function(x) {
  print(x)
}

# --------------------------------------------------------------------------------
# Define a function that displays a tableone object in LaTeX
# --------------------------------------------------------------------------------

tex.tableone <- function(x, size="footnotesize") {
  # Combine the method with the p-value and format it as a superscript.
  x$table$p[x$table$p != " "] <- paste0(x$table$p[x$table$p != " "], "$^", x$table$method[x$table$p != " "], "$")
  x$table$method <- NULL
  x$table$p[x$table$p==". "] <- "."
  x$table$p[x$table$p==" ^^"] <- " "

  # Reformat special characters in the table
  for(i in 3:5) {
    x$table[,i] <- gsub("\\+/-", "$\\\\pm$", x$table[,i])
    x$table[,i] <- gsub("\\%", "\\\\%", x$table[,i])
  }

  # Bold the table headers in markdown.
  colnames(x$table)[c(2,6)] <- paste0("{\\bf ", colnames(x$table)[c(2,6)], "}")
  colnames(x$table)[3] <- paste0("{\\bf ", colnames(x$table)[3], " (n=", x$n$n.grp1, ")}")
  colnames(x$table)[4] <- paste0("{\\bf ", colnames(x$table)[4], " (n=", x$n$n.grp2, ")}")
  colnames(x$table)[5] <- paste0("{\\bf ", colnames(x$table)[5], " (n=", x$n$n.combined, ")}")

  # Reformat the footer for markdown.
  for(l in letters[1:10]) {
    x$footer <- gsub(paste0("\\(", l, "\\)"), paste0("$^", l, "$"), x$footer)
  }
  x$footer <- gsub("\\+/-", "$\\\\pm$", x$footer)
  x$footer <- paste0("{\\em ", x$footer, "}")

  xt.out <- xtable(x$table, caption=x$caption, label=x$label)
  align(xt.out) <- paste0("ll", paste(rep("r", ncol(x$table)-1), collapse=""))

  # Configure header and footer
  addtorow <- list()
  addtorow$pos <- list(nrow(x$table))
  # x$footer[1] <- paste("\\hline", x$footer[1])
  addtorow$command <- paste0("\\hline\n\\multicolumn{", ncol(x$table), "}{l}",
                             paste(x$footer, collapse = paste0("\\\\\n\\multicolumn{", ncol(x$table), "}{l}")),
                             "\n")
  # addtorow$command <- c(paste0("~ & ~ & {\\em (n = ",
  #                              nrow(df[df[[grpvar]]==levels(df[[grpvar]])[1] & !is.na(df[[grpvar]]), ]),
  #                              ")} & {\\em (n = ",
  #                              nrow(df[df[[grpvar]]==levels(df[[grpvar]])[2] & !is.na(df[[grpvar]]), ]),
  #                              ")} & {\\em (n = ",
  #                              nrow(df[!is.na(df[[grpvar]]),]),
  #                              ")} & ~ \\\\\n"),
  #                       paste0("\\hline ", footer))

  # Print the table
  print(xt.out,
        include.rownames=FALSE,
        caption.placement="top",
        floating=TRUE,
        table.placement="H",
        size=size,
        add.to.row=addtorow,
        hline.after=c(-1, 0),
        sanitize.text.function = identity)
}

