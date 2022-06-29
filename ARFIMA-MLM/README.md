# [An Effective Approach to the Repeated Cross Sectional Design](https://docs.google.com/a/stonybrook.edu/viewer?a=v&pid=sites&srcid=c3Rvbnlicm9vay5lZHV8bWF0dGhldy1sZWJvfGd4Ojc3NjY0MjA1ZDJhYjMxODE)

With Christopher Weber, University of Arizona. **American Journal of Political Science** 59(1), 242-58.

Abstract: Repeated cross-sectional (RCS) designs are distinguishable from true panels and pooled cross-sectional-time-series (PCSTS) since cross-sectional units – e.g. individual survey respondents – appear but once in the data. This poses two serious challenges. 

- First, as with PCSTS, autocorrelation threatens inferences. 
- However, common solutions like differencing and using a lagged dependent variable are not possible with RCS since lags for i cannot be used. 
- Second, although RCS designs contain information that allows both aggregate- and individual-level analyses, available methods – from pooled OLS to PCSTS to time series – force researchers to choose one level of analysis. 
- The PCSTS toolkit does not provide an appropriate solution and we offer one here: double filtering with ARFIMA methods to account for autocorrelation in longer RCS followed by the use of multilevel modeling (MLM) to estimate both aggregate- and individual-level parameters simultaneously. We use Monte-Carlo experiments and three applied examples to explore the advantages of our framework.

> Lebo, Matthew; Weber, Christopher, 2013, "Replication data for: An Effective Approach to the Repeated Cross-Sectional Design", https://doi.org/10.7910/DVN1/22651, Harvard Dataverse, V3


https://github.com/pwkraft/ArfimaMLM/


[Slides](https://docs.google.com/a/stonybrook.edu/viewer?a=v&pid=sites&srcid=c3Rvbnlicm9vay5lZHV8bWF0dGhldy1sZWJvfGd4OjcwY2NhOTg4MDlkZTU3Zg)   [IMC webinar with slides](http://www.methods-colloquium.com/) [R Package on Cran](http://cran.r-project.org/web/packages/ArfimaMLM/index.html)  [R Package Documentation](https://docs.google.com/a/stonybrook.edu/viewer?a=v&pid=sites&srcid=c3Rvbnlicm9vay5lZHV8bWF0dGhldy1sZWJvfGd4OjQyMDcxOWM3NjcwNjhjY2U) 

[R Package Presentation](https://docs.google.com/a/stonybrook.edu/viewer?a=v&pid=sites&srcid=c3Rvbnlicm9vay5lZHV8bWF0dGhldy1sZWJvfGd4OjVlY2NmNjVjZTA1ZWVhMDU)  [Supporting Information](https://docs.google.com/a/stonybrook.edu/viewer?a=v&pid=sites&srcid=c3Rvbnlicm9vay5lZHV8bWF0dGhldy1sZWJvfGd4OjQ2ZDU0NDVmNTE4ZmQ4OGI) 

Package ‘ArfimaMLM’ was removed from the CRAN repository.

Formerly available versions can be obtained from the [archive](https://cran.r-project.org/src/contrib/Archive/ArfimaMLM).

Archived on 2020-05-26 as message asking for corrections bounced.

A summary of the most recent check results can be obtained from the [check results archive](https://cran-archive.r-project.org/web/checks/2020/2020-05-26_check_results_ArfimaMLM.html).

Please use the canonical form [https://CRAN.R-project.org/package=ArfimaMLM](https://cran.r-project.org/package%3DArfimaMLM) to link to this page.

# 解决R包已经被CRAN移除的问题

1. 更改工作路径

```R
setwd('/Users/chengjun/OneDrive - 南京大学/10papers/causal_inference_references/Lebo_Weber_Final Replication Files/')
```

**问题**：R包fractal已经被CRAN移除。从 https://cran.r-project.org/src/contrib/Archive/fractal 下载**fractal_2.0-4.tar.gz**并放到以上路径下。

Notes: for M1 users https://stackoverflow.com/questions/70881723/problems-installing-r-package-nloptr-on-m1-mac

> install.packages('fractal_2.0-4.tar.gz')

> ERROR: dependencies ‘splus2R’, ‘ifultools’, ‘sapa’, ‘wmtsa’, ‘scatterplot3d’ are not available for package ‘fractal’

```
install.packages('splus2R')
install.packages('scatterplot3d')
```

而R包ifultools也已经被CRAN移除。解决方法:



2. 从 https://cran.r-project.org/src/contrib/Archive/ifultools 下载 ifultools_2.0-23.tar.gz 并放到以上路径下。

3. Mac还需要根据OS版本下载并安装gfortran https://github.com/fxcoudert/gfortran-for-macOS/releases/tag/8.2

4. 然后就可以安装ifultools

```R
 install.packages('ifultools_2.0-23.tar.gz')
```


5. 安装sapa和wmtsa

```R
install.packages('sapa_2.0-3.tar.gz')

install.packages('wmtsa_2.0-3.tar.gz')
```

6. 最后安装fractal

```R
install.packages('fractal_2.0-4.tar.gz')
```

7. 与之类似：

```R
install.packages('fArma_3042.81.tar.gz')
```

It was removed because some dependencies (e.g., the fractal package) were removed from CRAN. You can install the current dev version via 

```R
devtools::install_github("pwkraft/ArfimaMLM")
```
