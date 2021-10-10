{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] grf_ate" "help grf_ate"}{...}
{vieweralsosee "[R] grf_test_calibration" "help grf_test_calibration"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{vieweralsosee "[R] parsnip" "help parsnip"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Generalized Random Forest Functions}

{phang}
{bf:grf_variable_importance} {hline 2} Get an "importance value" of each predictor in a forest from R's grf


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:grf_variable_importance} , {it:options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt decay_exponent(real 2)}} A tuning parameter that controls the importance of split depth{p_end}
{synopt:{opt max_depth(integer 4)}} Maximum depth of splits to consider.{p_end}
{synopt:{opt print_only}} For especially long lists of predictors, or importance matrices for which all importances are zero, {cmd: rcall} may have some issues returning the results.
If you have problems, you may try this option, which just prints out the R output and doesn't attempt to actually return any results to Stata.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:grf_variable_importance}

{marker description}{...}
{title:Description}

{pstd}
{cmd:grf_variable_importance} is an interface between Stata and the "variable_importance" function in the R package {cmd: grf}, by Athey, Tibshirani, and Wager (2019).

{pstd}
This is a postestimation function for {cmd:grf}, and can be used with any of the forests.
See {cmd: rcall: help(variable_importance, package = 'grf')} or {browse "https://grf-labs.github.io/grf/"} for more information.
Note that this will report variable importance using the {it: system} variable names, which likely don't match what you expect if you used factor variables or time-series operators in your list of predictors.
Creating lag/lead or dummy variables ahead of time and naming them yourself is adviced if you plan to use {cmd: grf_variable_importance}.

{pstd}
This function creates an "importance value" of each predictor and how important it is in building the tree.
It is a simple weighted sum of how many times a given predictor was split on at each depth in the forest.


{pstd}
Unfortunately, troubleshooting your model if it does not work is rather difficult when using a wrapper like this.
You can get some help on the GitHub page at {browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you may be a bit on your own.
You may be able to use {cmd: rcall} to see what error messages come up if things are not being returned to Stata.

{pstd}
The use of any MLRtime function will often result in flashing blue screens.
If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Athey, S., Tibshirani, J., and Wager, S. (2019) Generalized Random Forests. The Annals of Statistics 47 (2), 1148-1178. {browse "https://doi.org/10.1214/18-AOS1709":Link}.

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{marker examples}{...}
{title:Examples}

Note that this syntax example produces estimates of zero importance for all variables - none are ever selected for a split!

{phang}{cmd:. sysuse auto.dta, clear}{p_end}
{phang}{cmd:. g model = word(make, 1)}{p_end}
{phang}{cmd:. encode model, g(modeln)}{p_end}
{phang}{cmd:. g hold = runiform() > .5}{p_end}
{phang}{cmd:. * Make dummies ourselves so the names are readable}{p_end}
{phang}{cmd:. xi i.modeln}{p_end}
{phang}{cmd:. grf price mpg headroom trunk _I*, forest_type(causal_forest) w(foreign) replace clearR pred(estimated_effect) se(SE_effect) hold(hold)}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. grf_variable_importance}{p_end}


