{smcl}
{* *! version 1.2.2  15may2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{title:MLRtimesetup}

{phang}
{bf:MLRtimesetupz} {hline 2} set up rcall and R package dependencies


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:MLRtimesetup} [repo], [go]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt repo}} specify a CRAN mirror. Otherwise, defaults to Berkeley.{p_end}
{synopt:{opt go}} skip the text prompts and just say "yes" to everything.{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:MLRtimesetup} will install the Stata packages {cmd: github} and {cmd: rcall} referenced in {browse "https://journals.sagepub.com/doi/abs/10.1177/1536867X19830891?journalCode=stja":Haghish (2019)}, as well as every R package necessary to run every function in MLRtime. The Stata packages will be downloaded from GitHub and not ssc.

{pstd}
R must be installed first before running {cmd:MLRtimesetup}, and R must be callable from the command line. You can install R at {browse "https://www.r-project.org/":R-Project.org}. If after installing R, {cmd: rcall} is still having trouble finding your R installation, see the {browse "http://www.haghish.com/packages/Rcall.php":rcall website} for troubleshooting tips. Likely, your R installation is just not where it expects.

{pstd}
If {cmd:rcall} seems to be working fine, but R package installation is giving you problems, then open up R and copy/paste the following commands one at a time. If one fails, check the error message to see if it's something you can fix (sometimes you need to delete the "00LOCK" folder that shows up in your subdirectory of R packages), or maybe just try it again before moving on to the next:
      
{pstd} install.packages("DiceKriging", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("lmtest", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("Matrix", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("methods", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("Rcpp", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("sandwich", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("grf", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)
 
{pstd} install.packages("survival", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE)

{pstd} install.packages("ranger", repos = "https://cran.cnr.berkeley.edu/", dependencies = TRUE) 
 
{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@fullerton.edu

{marker references}{...}
{title:References}

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.


