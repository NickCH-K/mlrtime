{smcl}
{* *! version 2.1.0  09oct2021}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{vieweralsosee "[R] parsnip" "help parsnip"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{title:MLRtimesetup}

{phang}
{bf:MLRtimesetup} {hline 2} set up rcall and R package dependencies


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:MLRtimesetup} [repo], [go]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt repo}} specify a CRAN mirror. Otherwise, defaults to the R-project 
cloud.{p_end}
{synopt:{opt go}} skip the text prompts and just say "yes" to everything.{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:MLRtimesetup} will install the Stata packages {cmd: github} and 
{cmd: rcall} referenced in {browse 
"https://journals.sagepub.com/doi/abs/10.1177/1536867X19830891?journalCode=stja"
:Haghish (2019)}, as well as every R package necessary to run every function in 
MLRtime.
The Stata packages will be downloaded from GitHub and not ssc.

{pstd}
R must be installed first before running {cmd:MLRtimesetup}, and R must be 
callable from the command line.
You can install R at {browse "https://www.r-project.org/":R-Project.org}.
If after installing R, {cmd: rcall} is still having trouble finding your R 
installation, see the {browse "http://www.haghish.com/packages/Rcall.php":rcall 
website} for troubleshooting tips.
Likely, your R installation is just not where it expects.

{pstd}
The use of any MLRtime function will often result in flashing blue screens.
If you are photosensitive you may want to look away.

{pstd}
If {cmd:rcall} seems to be working fine, but R package installation is giving 
you problems, then open up R and copy/paste the following commands one at a 
time.
If one fails, check the error message to see if it's something you can fix 
(sometimes you need to delete the "00LOCK" folder that shows up in your 
subdirectory of R packages), or maybe just try it again before moving on to the 
next:

{pstd} install.packages("broom", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("broom.mixed", repos = "https://cloud.r-project.org", 
dependencies = TRUE)
      
{pstd} install.packages("C50", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("covr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("data.table", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("dials", repos = "https://cloud.r-project.org", 
dependencies = TRUE)
  
{pstd} install.packages("DiceKriging", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("dplyr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("earth", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("generics", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("globals", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("glue", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("grDevices", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("grf", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("gsynth", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("hardhat", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("keras", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("kernlab", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("kknn", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("knitr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("LiblineaR", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("lifecycle", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("lmtest", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("magrittr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("MASS", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("Matrix", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("methods", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("mgcv", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("modeldata", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("nlme", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("parsnip", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("prettyunits", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("purrr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("randomForest", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("ranger", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("Rcpp", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("RcppArmadillo", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("rlang", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("rpart", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("rstanarm", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("sandwich", repos = "https://cloud.r-project.org", 
dependencies = TRUE)
 
{pstd} install.packages("sparklyr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("stats", repos = "https://cloud.r-project.org", 
dependencies = TRUE)
 
{pstd} install.packages("survival", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("tibble", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("tidyr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("utils", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("vctrs", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("withr", repos = "https://cloud.r-project.org", 
dependencies = TRUE)

{pstd} install.packages("xgboost", repos = "https://cloud.r-project.org", 
dependencies = TRUE)	  

 
{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between
 R and Stata. The Stata Journal, 19(1), 61–82. 
 {browse "https://doi.org/10.1177/1536867X19830891":Link}.


