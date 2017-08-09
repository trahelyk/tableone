# Testing the new tableone package
Kyle Hart  
`r format(Sys.Date())`  




```r
foo <- apply.labels(aids[,c("death", "CD4", "drug", "gender", "prevOI", "AZT")],
                    c("Died", "CD4", "Group", "Gender", "Previous OI", "AZT"))

md(tidy.tableone(df = foo,
                 grpvar="drug",
                 caption = "Table\\: Clinical characteristics."))
```

 
 
  
Table\: Clinical characteristics.


|              |**n** |**ddC (n=717)** |**ddI (n=688)** |**Combined (n=1405)** |**p**    |
|:-------------|:-----|:---------------|:---------------|:---------------------|:--------|
|Died          |1405  |0 (0, 1)        |0 (0, 1)        |0 (0, 1)              |0.23^a^  |
|CD4           |1405  |5.2 (3, 9.5)    |5.9 (3.2, 11)   |5.5 (3.2, 10.4)       |0.023^a^ |
|Gender        |1405  |                |                |                      |0.729^b^ |
|- female      |      |9% (62)         |8% (55)         |8% (117)              |         |
|- male        |      |91% (655)       |92% (633)       |92% (1288)            |         |
|Previous OI   |1405  |                |                |                      |0.577^b^ |
|- noAIDS      |      |38% (271)       |39% (271)       |39% (542)             |         |
|- AIDS        |      |62% (446)       |61% (417)       |61% (863)             |         |
|AZT           |1405  |                |                |                      |0.182^b^ |
|- intolerance |      |63% (454)       |67% (460)       |65% (914)             |         |
|- failure     |      |37% (263)       |33% (228)       |35% (491)             |         |

***
  
_x.x (x.x, x.x) indicates median and inter-quartile range._  
_^a^ Wilcoxon rank-sum test_  
_^b^ Pearson's chi-squared test_
<br><br><br>

```r
# x <- tidy.tableone(df = foo, grpvar="drug")
```
