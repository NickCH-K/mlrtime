{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] grf_test_calibration" "help grf_test_calibration"}{...}
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
{bf:grf_ate} {hline 2} Estimate an average treatment effect following a causal forest or instrumental forest


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:grf_ate} , {it:options}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt target_sample(string)}} Which sample to aggregate treatment effects
 over.
This can be "all" (the default).
For causal forests you can alternately select "treated", "control", or 
"overlap".{p_end}
{synopt:{opt method(string)}} Method used for doubly robust inference.
Can be either augmented inverse-propensity weighting (AIPW), or targeted maximum
 likelihood estimation (TMLE).
Note: TMLE is currently only implemented for causal forests with a binary 
treatment..{p_end}
{synopt:{opt subset(string)}} A variable name for a variable that was 
{it:in the data before the call to {cmd: grf}} that specifies the subset of the
 training examples over which we estimate the ATE.
WARNING: For valid statistical performance, the subset should be defined only 
using features Xi, not using the treatment or the outcome.{p_end}
{synopt:{opt debiasing_weights(string)}} A variable name for a variable that 
was {it:in the data before the call to {cmd: grf}} giving the debiasing weights.
If not specified these are obtained via the appropriate doubly robust score 
construction, e.g., in the case of causal_forests with a binary treatment, 
they are obtained via inverse-propensity weighting.{p_end}
{synopt:{opt compliance_score(string)}} Only used with instrumental forests.
A variable name for a variable that was {it:in the data before the call to 
{cmd: grf}} Only used with instrumental forests.
An estimate of the causal effect of instrument Z on treatment W, i.e., 
Delta(X) = E[W | X, Z = 1] - E[W | X, Z = 0], which can then be used to produce 
debiasing_weights.
If not provided, this is estimated via an auxiliary causal forest.{p_end}
{synopt:{opt num_trees_for_weights(integer)}} In some cases (e.g., with causal 
forests with a continuous treatment), we need to train auxiliary forests to 
learn debiasing weights.
This is the number of trees used for this task.
Note: this argument is ignored if {opt debiasing_weights} is specified.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:grf_ate}

{marker description}{...}
{title:Description}

{pstd}
{cmd:grf_ate} is an interface between Stata and the "average_treatment_effect" 
function in the R package {cmd: grf}, by Athey, Tibshirani, and Wager (2019).

{pstd}
This is a postestimation function for {cmd:grf} specified with either the 
{opt forest_type(causal_forest)} or {opt forest_type(instrumental_forest)} 
options, and will calculate an average treatment effect for the estimated 
forest.
See {cmd: rcall: help(average_treatment_effect, package = 'grf')} or 
{browse "https://grf-labs.github.io/grf/"} for more information.

{pstd}
Results will be printed to screen, and also stored in {cmd: r(estimate)} and 
{cmd: r(std.err)}.

{pstd}
Unfortunately, troubleshooting your model if it does not work is rather 
difficult when using a wrapper like this.
You can get some help on the GitHub page at 
{browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you 
may be a bit on your own.
You may be able to use {cmd: rcall} to see what error messages come up if things
 are not being returned to Stata.

{pstd}
The use of any MLRtime function will often result in flashing blue screens.
If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Athey, S., Tibshirani, J., and Wager, S. (2019) Generalized Random 
Forests. The Annals of Statistics 47 (2), 1148-1178. 
{browse "https://doi.org/10.1214/18-AOS1709":Link}.

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between
 R and Stata. The Stata Journal, 19(1), 61–82. 
 {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{marker examples}{...}
{title:Examples}

Note that this syntax example produces some strange results, but this is an 
artifact of the not-well-thought-out analysis.

{phang}{cmd:. sysuse auto.dta, clear}{p_end}
{phang}{cmd:. g model = word(make, 1)}{p_end}
{phang}{cmd:. encode model, g(modeln)}{p_end}
{phang}{cmd:. g hold = runiform() > .5}{p_end}
{phang}{cmd:. grf price mpg headroom trunk i.modeln, forest_type(causal_forest) w(foreign) replace clearR pred(estimated_effect) se(SE_effect) hold(hold)}{p_end}
{phang}{cmd:. grf_ate}{p_end}


