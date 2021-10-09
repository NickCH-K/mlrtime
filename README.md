# MLRtime

MLRtime is a Stata package that allows you to access certain machine learning commands and packages in R. These features probably aren't coming natively to Stata any time soon, but that doesn't mean you have to go without or switch over entirely! 

Currently the package allows use of most random and causal forests from the **grf** package in R for causal forests, `gsynth` to run generalized synthetic control and matrix completion from the **gsynth** package, and `parsnip` for access to a wide range of machine learning algorithms via the **parsnip** package. If you'd like to add an interface with another command, go for it! PRs are welcome.

You can install MLRtime with `net install MLRtime, from("https://raw.githubusercontent.com/NickCH-K/MLRtime/master/")`
