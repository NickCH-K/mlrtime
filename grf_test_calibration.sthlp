{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] grf_ate" "help grf_ate"}{...}
{vieweralsosee "[R] grf_variable_importance" "help grf_variable_importance"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{vieweralsosee "[R] parsnip" "help parsnip"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Generalized Random Forest Functions}

{phang}
{bf:grf_test_calibration} {hline 2} Test the calibration of a generalized random forest from R's grf


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:grf_test_calibration} , {it:options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt vcov_type(string)}} Optional covariance type for standard errors. The possible options are HC0, ..., HC3. The default is "HC3", which is recommended in small samples and corresponds to the "shortcut formula" for the jackknife (see MacKinnon & White for more discussion, and Cameron & Miller for a review). For large data sets with clusters, "HC0" or "HC1" are significantly faster to compute.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:grf_test_calibration}

{marker description}{...}
{title:Description}

{pstd}
{cmd:grf_test_calibration} is an interface between Stata and the "test_calibration" function in the R package {cmd: grf}, by Athey, Tibshirani, and Wager (2019).

{pstd}
This is a postestimation function for {cmd:grf}, and can be used with any of the forests. See {cmd: rcall: help(test_calibration, package = 'grf')} or {browse "https://grf-labs.github.io/grf/"} for more information.

{pstd}
This function tests the calibration of the forest. Computes the best linear fit of the target estimand using the forest prediction (on held-out data) as well as the mean forest prediction as the sole two regressors. A coefficient of 1 for 'mean.forest.prediction' suggests that the mean forest prediction is correct, whereas a coefficient of 1 for 'differential.forest.prediction' additionally suggests that the forest has captured heterogeneity in the underlying signal. The p-value of the 'differential.forest.prediction' coefficient also acts as an omnibus test for the presence of heterogeneity: If the coefficient is significantly greater than 0, then we can reject the null of no heterogeneity.

{pstd}
Unfortunately, troubleshooting your model if it does not work is rather difficult when using a wrapper like this. You can get some help on the GitHub page at {browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you may be a bit on your own. You may be able to use {cmd: rcall} to see what error messages come up if things are not being returned to Stata.

{pstd}
The use of any MLRtime function will often result in flashing blue screens. If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Athey, S., Tibshirani, J., and Wager, S. (2019) Generalized Random Forests. The Annals of Statistics 47 (2), 1148-1178. {browse "https://doi.org/10.1214/18-AOS1709":Link}.

{phang} Cameron, A. C., and Miller, D. L. (2015). A Practitioner's Guide to Cluster-robust Inference. Journal of Human Resources, 50 (2), 317-372.

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{phang} MacKinnon, J. G., and White, H. (1985). Some Heteroskedasticity-consistent Covariance Matrix Estimators with Improved Finite Sample Properties. Journal of Econometrics, 29(3), 305-325.

{marker examples}{...}
{title:Examples}

Note that this syntax example produces some strange results, but this is an artifact of the not-well-thought-out analysis.

{phang}{cmd:. sysuse auto.dta, clear}{p_end}
{phang}{cmd:. g model = word(make, 1)}{p_end}
{phang}{cmd:. encode model, g(modeln)}{p_end}
{phang}{cmd:. g hold = runiform() > .5}{p_end}
{phang}{cmd:. grf price mpg headroom trunk i.modeln, forest_type(causal_forest) w(foreign) replace clearR pred(estimated_effect) se(SE_effect) hold(hold)}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. grf_test_calibration}{p_end}


