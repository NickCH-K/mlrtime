{smcl}
{* *! version 1.2.2  15may2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:groupsearch}

{phang}
{bf:causal_forest} {hline 2} Run causal_forest in R's grf and return results


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:causal_forest} {help depvar} {help indvar} {help varlist} [{help if}] [{help in}] [{help weight}], [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt clearR}} start a new R environment before running {cmd: grf::causal_forest}.{p_end}
{synopt:{opt replace}} drop variables that have the same name as those about to be created.{p_end}
{synopt:{opt seed(integer)}} set the seed in R.{p_end}
{synopt:{opt pred(string)}} variable name to store effect predictions in. Must be a valid name in R and Stata.{p_end}
{synopt:{opt predopts(string)}} set of options, in R syntax, separated by commas, to use in the {cmd: predict} command. See {cmd: rcall: help(predict.causal_forest)}.{p_end}
{synopt:{opt opts(string)}} set of options, in R syntax, separated by commas, to pass to {cmd: causal_forest}. {it: Do not} use the character "$", as Stata will try to toss a global variable in there. Instead use "@@" and the {cmd:causal_forest} function will turn it to "$".{p_end}
{synopt:{opt varreturn(string)}} list of R commands, separated by semicolons ({cmd: ;}), each of which is of the format {cmd: newvariable = Rfunctioncreatingavariable}. Each of the {cmd: newvariable}s will be created in Stata as variables. Variable names must be valid in R and Stata. These functions can refer to the causal forest object as {cmd: CF}, and the covariate, treatment, and outcome matrices as {cmd: X}, {cmd: W}, and {cmd: Y}, respectively. Use "@@" instead of "$" where necessary. For example, to get effect standard errors, it would be {cmd: varreturn(effectSE = sqrt(predict(CF, X, estimate.variance = TRUE)@@variance.estimates))} {p_end}
{synopt:{opt return(string)}} list of R commands, separated by semicolons ({cmd: ;}), each of which is of the format {cmd: newmacro = Rfunctioncreatingsomething}. Each of the {cmd: newmacro}s will be created in Stata as macros, accessible as {cmd: r(newmacro)} (as named). Names must be valid in R and Stata. These functions can refer to the causal forest object as {cmd: CF}, and the covariate, treatment, and outcome matrices as {cmd: X}, {cmd: W}, and {cmd: Y}, respectively. Use "@@" instead of "$" where necessary. For example, to get the average treatment effect and its standard errors, it would be {cmd: return(ate = average_treatment_effect(CF)[1]; ateSE = average_treatment_effect(CF)[2])} and then in Stata {cmd: display r(ate)} and {cmd: display r(ateSE)}. See {help rcall} documentation for the kinds of objects that will pass back to Stata properly. {p_end}
{synopt:{opt varsend(varlist)}} A list of variables to be sent to R alongside {help depvar}, {help indvar}, and {help varlist}, where they will be turned into matrices, for whatever purposes you have. Perhaps using the {cmd: Y.hat} or {cmd:sample.weights} options in {cmd: opts()}, or for use in one of your {cmd: varreturn} commands.{p_end}
{synopt:{opt precedes}} list of R commands, separated by semicolons ({cmd: ;}), of whatever you'd like R to do just before running {cmd: grf::causal_forest}. These functions can refer to (and perhaps manipulate!) the covariate, treatment, and outcome matrices as {cmd: X}, {cmd: W}, and {cmd: Y}, respectively. Use "@@" instead of "$" where necessary.{p_end}
{synopt:{opt follows}} list of R commands, separated by semicolons ({cmd: ;}), of whatever you'd like R to do just after running {cmd: grf::causal_forest} but before generating any of the variables to return. These functions can refer to the causal forest object as {cmd: CF}, and the covariate, treatment, and outcome matrices as {cmd: X}, {cmd: W}, and {cmd: Y}, respectively. Use "@@" instead of "$" where necessary.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:causal_forest} is an interface between Stata and the function {cmd: causal_forest} in the R package {cmd: grf}, by Athey, Tibshirani, and Wager (2019). It will send data to an R session, run the causal forest, and then return the relevant results in variable or macro form. The relevant objects will remain in the R session and can be accessed and manipulated further with R code using {help rcall} afterwards (Haghish 2019). Run {help MLRtimesetup} before use for the first time. It is also strongly recommended that you read {cmd: rcall: help(causal_forest, package = 'grf')} to understand the options syntax and how to use the {cmd: CF} object after it is created.

{pstd} 
One weakness of this command is that it does not automate working with training/holdout sets. Stata just isn't really made for that. However, this is not too difficult to do. Before running {cmd: causal_forest}, load your holdout data. Limit the dataset to just the covariates in {cmd: X}, and just the nonmissing observations. Send this to R as a matrix with {cmd: rcall: X.hold <- as.matrix(st.data())}. Then, load your training data and run {cmd: causal_forest} as normal, but instead of using {cmd: pred()} to create predictions, instead use {cmd: varreturn()} and do {cmd: pred <- as.matrix(predict(CF, X.hold)@@predictions)}. See {browse "https://lost-stats.github.io/Machine_Learning/causal_forest.html":LOST} for a demonstration.

{pstd}
Syntax takes the form of {help depvar} {help indvar} {help varlist}. {help depvar} is the dependent variable being predicted ({cmd: Y} in {cmd: grf::causal_forest} syntax). {help indvar} is the treatment variable you are interested in seeing treatment effect heterogeneity for ({cmd: W}), and {help varlist} is the list of variables used to predict treatment effect heterogeneity. These should be variables in Stata and not matrices; {cmd: causal_forest} will convert them to matrices for {cmd: grf::causal_forest} use.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@fullerton.edu

{marker references}{...}
{title:References}

{phang} Athey, S., Tibshirani, J., and Wager, S. (2019) Generalized Random Forests. The Annals of Statistics 47 (2), 1148-1178. {browse "https://doi.org/10.1214/18-AOS1709":Link}.

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{marker examples}{...}
{title:Examples}

Note that this syntax example produces some strange {cmd: effectSE} results, but this is an artifact of the not-well-thought-out analysis; generally they won't all be identical.

{phang}{cmd:. sysuse auto.dta, clear}{p_end}
{phang}{cmd:. causal_forest price foreign mpg rep78 headroom trunk weight length turn, clearR replace seed(1002) pred(effect) opts(num.trees=50) varreturn(effectSE = sqrt(predict(CF, X, estimate.variance = TRUE)@@variance.estimates)) return(ate = average_treatment_effect(CF)[1]; ateSE = average_treatment_effect(CF)[2])}{p_end}
{phang}{cmd:. di r(ate)}{p_end}
{phang}{cmd:. di r(ateSE)}{p_end}

