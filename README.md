# MLRtime

MLRtime is a Stata package that allows you to access certain machine learning commands and packages in R. These features probably aren't coming natively to Stata any time soon, but that doesn't mean you have to go without or switch over entirely! 

Currently the package allows use of `causal_forest` from the **grf** package in R for causal forests and `ranger` from the **ranger** package for random forests, but it may expand. If you'd like to add an interface with another command, go for it! PRs are welcome.

You can install MLRtime with `net install MLRtime, from("https://raw.githubusercontent.com/NickCH-K/MLRtime/master/")`