{smcl}
{* *! version 2.0.0  20sep2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] gsynth_plot" "help gsynth_plot"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Generalized Random Forest Functions}

{phang}
{bf:gsynth} {hline 2} Implements the generalized synthetic control method based using R's gsynth


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:gsynth} {help depvar} {opt treatvar} {help varlist} [{help if}] [{help in}] [{help iweight}], index(varlist) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{help depvar}} The dependent variable being predicted.{p_end}
{synopt:{opt treatvar}} The treatment variable, which must contain only 0 and 1 values.{p_end}
{synopt:{help varlist}} The set of time-varying covariates. Factor-variable and time series operators are allowed, although their names are not preserved, so coefficient results tables may be difficult to interpret. If you want to use the coefficient results table you may want to explicitly create and name your own factor and time-series variables.{p_end}
{synopt:{opt index}} Required. A list of exactly two variables specifying the ID indicator and time indicator.{p_end}
{synopt:{opt clearR}} Start a new R environment before running your command.{p_end}
{synopt:{opt seed(integer)}} Set the random generation seed to this.{p_end}
{synopt:{opt precedes(string)}} list of R commands, separated by semicolons ({cmd: ;}), of whatever you'd like R to do after importing your data but before running your {cmd: grf} command. These functions can refer to variables in your data as part of the data set {cmd: dataset}, i.e. {cmd: dataset@@varname}. Use "@@" instead of "$" where $ appears in the R code to avoid confusing Stata. As of this writing, all options should be supported, but this may come in handy if gsynth updates but MLRtime hasn't caught up yet.{p_end}
{synopt:{opt att_file_replace(string)}} Save the by-period average treatment on the treated estimates to a Stata dataset in addition to returning it as a matrix.{p_end}
{synoptline}
{syntab:Estimation Options}
{synopt:{opt se}} Produce estimates of uncertainty (standard errors, confidence intervals) with the results.{p_end}
{synopt:{opt estimator(string)}} Either "ife" for interactive fixed effects or "mc" for the matrix completion method. The default is {opt estimator(ife)}.{p_end}
{synopt:{opt force(string)}} A string indicating whether unit or time fixed effects will be imposed. Must be one of the following: "none", "unit", "time", or "two-way". The default is "unit".{p_end}
{synopt:{opt cl(varname)}} The cluster variable. If not specified, bootstrap will be blocked at unit level (only for non-parametric bootstrap).{p_end}
{synopt:{opt r(integer 0)}} The number of factors. If {opt cv} is specified, the cross validation procedure will select the optimal number of factors from r to 5.{p_end}
{synopt:{opt lambda(string)}} A single or sequence of positive numbers (i.e. {opt lambda(.1 .2 .3)}; sequences like {opt lambda(.1(.1).3)} are not supported) specifying the hyper-parameter sequence for matrix completion method. If lambda is a sequence and {opt cv} is specified, cross-validation will be performed.{p_end}
{synopt:{opt nlambda(integer 10}} The length of hyper-parameter sequence for matrix completion method.{p_end}
{synopt:{opt no_cv}} Don't perform cross-validation to select the optimal number of factors or hyper-parameter in matrix completion algorithm. If {opt r} is not specified, the procedure will search through r = 0 to 5.{p_end}
{synopt:{opt criterion(string)}} The criteria used for determining the number of factors. Choose from "mspe" or "pc". "mspe" stands for the mean squared prediction error obtained through the loocv procedure, and "pc" stands for a kind of information criterion. If {opt criterion(pc)}, the number of factors that minimize "pc" will be selected. Default is {opt criterion(mspe)}.{p_end}
{synopt:{opt k(integer 5)}} Cross-validation times for the matrix completion algorithm.{p_end}
{synopt:{opt em}} Use an Expectation Maximization algorithm (Gobillon and Magnac 2016).{p_end}
{synopt:{opt nboots(integer 200)}} The number of bootstrap runs. Ignored if {opt se} is not specified.{p_end}
{synopt:{opt inference(string)}} Which type of inferential method will be used, either "parametric" or "nonparametric". "parametric" is recommended when the number of treated units is small. parametric bootstrap is not valid for the matrix completion method. This option is ignored if {opt estimator(mc)} is specified.{p_end}
{synopt:{opt cov_ar(integer 1)}} The order of the auto regression process that the residuals follow. Used for parametric bootstrap procedure when data is in the form of unbalanced panel.{p_end}
{synopt:{opt no_parallel}} Do not use parallel computing in bootstrapping and/or cross-validation. Ignored if {opt se} is not specified.{p_end}
{synopt:{opt cores(integer)}} The number of cores to be used in parallel computing. If not specified, the algorithm will use the maximum number of logical cores of your computer (warning: this could prevent you from multi-tasking on your computer).{p_end}
{synopt:{opt tol(real 0.001)}} A positive number indicating the tolerance level.{p_end}
{synopt:{opt min_T0(integer 5}} An integer specifying the minimum value of pre-treatment periods. Treated units with pre-treatment periods less than that will be removed automatically. This item is important for unbalanced panels. If users want to perform cross validation procedure to select the optimal number of factors from (r.min, r.max), they should set {opt min_T0} larger than (r.max+1) if no individual fixed effects or (r.max+2) otherwise. If there are too few pre-treatment periods among all treated units, a smaller value of r.max is recommended.{p_end}
{synopt:{opt alpha(real .05)}} A positive number in the range of 0 and 1 specifying significant levels for uncertainty estimates.{p_end}
{synopt:{opt normalize}} Scale outcome and covariates. Useful for accelerating computing speed when magnitude of data is large.{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:gsynth}

{marker description}{...}
{title:Description}

{pstd}
{cmd:gsynth} is an interface between Stata and the generalized synthetic control {cmd: gsynth} function in the R package {cmd: gsynth}, by Xu (2017).  This also provides access to the matrix completion method of Athey, Bayati, and Doudchenko (2017).

{pstd}
It will send data to an R session, run the {cmd: gsynth} command there, and then return the relevant results. Results will be printed and are also available in the {cmd: e()} matrices {cmd: e(att_avg)} (average treatment-on-treated), {cmd: e(att)} (by-period treatment-on-treated), and {cmd: e(coef)} (coefficients on time-varying covariates). It can then be followed by {cmd: gsynth_plot} to plot the treatment effect over time. 

{pstd}
From the R description of {cmd: gsynth}: {cmd: gsynth} implements the generalized synthetic control method. It imputes counterfactuals for each treated unit using control group information based on a linear interactive fixed effects model that incorporates unit-specific intercepts interacted with time-varying coefficients. It generalizes the synthetic control method to the case of multiple treated units and variable treatment periods, and improves efficiency and interpretability. It allows the treatment to be correlated with unobserved unit and time heterogeneities under reasonable modeling assumptions. With a built-in cross-validation procedure, it avoids specification searches and thus is easy to implement. Data must be with a dichotomous treatment.

{pstd}
Unfortunately, troubleshooting your model if it does not work is rather difficult when using a wrapper like this. You can get some help on the GitHub page at {browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you may be a bit on your own. You may be able to use {cmd: rcall} to see what error messages come up if things are not being returned to Stata.

{pstd}
See {browse "https://yiqingxu.org/packages/gsynth/gsynth_examples.html"} for details on method and usage, as well as {cmd: rcall: help(gsynth, package = 'gsynth')} for further documentation.

{pstd}
Note that if you know R you can add your own code as you like using {cmd: rcall}. The {opt precedes} option allows the insertion of R code after data is imported but before estimating the model, and you can use {cmd: rcall} as normal afterwards, referring to the estimated model object as {cmd: M}. The relevant objects will remain in the R session and can be accessed and manipulated further with R code using {help rcall} afterwards (Haghish 2019). Run {help MLRtimesetup} before use for the first time. 

{pstd}
Additional note: while {help depvar}, {opt treatvar}, and {help varlist} accept time-series, interaction, and factor operators, the names of these variables are not maintained in an interpretable way. This may be a problem if you plan to use the matrix of covariate coefficients. If you plan to use this matrix you should create and name variables ahead of time.

{pstd}
The use of any MLRtime function will often result in flashing blue screens. If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Athey, S., Bayati, M., Doudchenko N., et al. (2017). Matrix completion methods for causal panel data models. arXiv preprint arXiv:1710.10251, 2017.

{phang} Gobillon, L. and Magnac, T. (2016). Regional Policy Evaluation: Interactive Fixed Effects and Synthetic Controls. The Review of Economics and Statistics, 98(3), 535–551.

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{phang} Xu, Y. (2017). Generalized Synthetic Control Method: Causal Inference with Interactive Fixed Effects Models. Political Analysis, 25 (1), 57-76.

{marker examples}{...}
{title:Examples}

Note that this syntax example uses an arbitrary treatment.

{phang}{cmd:. import delimited "https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/gapminder.csv", clear}{p_end}
{phang}{cmd:. g treat = continent == "Asia" & year >= 2001}{p_end}
{phang}{cmd:. * Using interactive fixed effects, and getting standard errors}{p_end}
{phang}{cmd:. gsynth lifeexp treat pop gdppercap, index(country year) se}{p_end}
{phang}{cmd:. * Or matrix completion with cross-validation to select terms}{p_end}
{phang}{cmd:. gsynth lifeexp treat pop gdppercap, index(country year) se estimator("mc")}{p_end}


