# MLRtime

MLRtime is a Stata package that allows you to access certain machine learning commands and packages in R. These features probably aren't coming natively to Stata any time soon, but that doesn't mean you have to go without or switch over entirely! 

Currently the package allows use of all non-experimental forests from the **grf** package in R (including causal forests) and `gsynth` from the **gsynth** package for generalized synthetic control and matrix completion. It will soon expand to the wide range of ML algorithms accessible from the **parsnip** package. If you'd like to add an interface with another command, go for it! PRs are welcome.

You can install MLRtime with `net install MLRtime, from("https://raw.githubusercontent.com/NickCH-K/MLRtime/master/") replace`
