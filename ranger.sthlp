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
{bf:ranger} {hline 2} Run ranger in R's ranger and return results


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ranger} {help depvar} {help varlist} [{help if}] [{help in}] [{help weight}], [{it:options}]

 [pred(string)] [predopts(string)] [varreturn(string)] [return(string)] [varsend(varlist)] [precedes(string)] [follows(string)] [opts(string)]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt clearR}} start a new R environment before running {cmd: grf::causal_forest}.{p_end}
{synopt:{opt replace}} drop variables that have the same name as those about to be created.{p_end}
{synopt:{opt seed(integer)}} set the seed in R.{p_end}
{synopt:{opt pred(string)}} variable name to store effect predictions in. Must be a valid name in R and Stata.{p_end}
{synopt:{opt predopts(string)}} set of options, in R syntax, separated by commas, to use in the {cmd: predict} command. See {cmd: rcall: help(predict.ranger)}.{p_end}
{synopt:{opt opts(string)}} set of options, in R syntax, separated by commas, to pass to {cmd: ranger}. {it: Do not} use the character "$", as Stata will try to toss a global variable in there. Instead use "@@" and the {cmd:ranger} function will turn it to "$".{p_end}
{synopt:{opt varreturn(string)}} list of R commands, separated by semicolons ({cmd: ;}), each of which is of the format {cmd: newvariable = Rfunctioncreatingavariable}. Each of the {cmd: newvariable}s will be created in Stata as variables. Variable names must be valid in R and Stata. These functions can refer to the estimated {cmd: ranger} object as {cmd: RF}, and the {cmd: data.frame} containing the data used in the {cmd: ranger} command as {cmd: rangerdata}. Use "@@" instead of "$" where necessary. {p_end}
{synopt:{opt varsend(varlist)}} A list of variables to be sent to R alongside {help depvar} and {help varlist}, where they will be turned into vectors, for whatever purposes you have. Perhaps in one of your {cmd: varreturn} commands.{p_end}
{synopt:{opt precedes}} list of R commands, separated by semicolons ({cmd: ;}), of whatever you'd like R to do just before running {cmd: ranger::ranger}. These functions can refer to (and perhaps manipulate!) the analysis data as {cmd: rangerdata}, or refer to {cmd: varsend} vectors by name. Use "@@" instead of "$" where necessary.{p_end}
{synopt:{opt follows}} list of R commands, separated by semicolons ({cmd: ;}), of whatever you'd like R to do just after running {cmd: ranger::ranger} but before generating any of the variables to return. These functions can refer to the {cmd: ranger} object as {cmd: RF}. These functions can refer to the analysis data as {cmd: rangerdata}, or refer to {cmd: varsend} vectors by name. Use "@@" instead of "$" where necessary.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:ranger} is an interface between Stata and the function {cmd: ranger} in the R package {cmd: ranger}, by Wright & Ziegler (2017). It will send data to an R session, run the random forest, and then return the relevant results in variable or macro form. The relevant objects will remain in the R session and can be accessed and manipulated further with R code using {help rcall} afterwards (Haghish 2019). Run {help MLRtimesetup} before use for the first time. It is also strongly recommended that you read {cmd: rcall: help(ranger, package = 'ranger')} to understand the options syntax and how to use the {cmd: RF} object after it is created.

{pstd} 
One weakness of this command is that it does not automate working with training/holdout sets. Stata just isn't really made for that. However, this is not too difficult to do. Before running {cmd: ranger}, load your holdout data. Limit the dataset to just the prediction variables, and just the nonmissing observations. Send this to R as with {cmd: rcall: X.hold <- st.data()}. Then, load your training data and run {cmd: ranger} as normal, and add {cmd: predopts(data = X.hold)}. 

{pstd}
Syntax takes the form of {help depvar} {help varlist}. {help depvar} is the dependent variable being predicted. {help varlist} is the list of variables used to predict the dependent variable. These should all be variables loaded normally in Stata.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@fullerton.edu

{marker references}{...}
{title:References}

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.

{phang} Wright, M. N., & Ziegler, A. (2017) ranger: A Fast Implementation of Random Forests for High Dimensional Data in C++ and R. The Journal of Statistical Software, 77, 1-17. {browse "https://doi.org/10.18637/jss.v077.i01":Link}.

{marker examples}{...}
{title:Examples}

Note that this syntax example produces some strange {cmd: effectSE} results, but this is an artifact of the not-well-thought-out analysis; generally they won't all be identical.

{phang}{cmd:. sysuse auto.dta, clear}{p_end}
{phang}{cmd:. ranger price foreign mpg rep78 headroom trunk weight length turn, clearR replace seed(1002) pred(pred_price) predopts(data=rangerdata) opts(num.trees=50, importance = 'permutation') return(importance = as.matrix(importance(RF)))}{p_end}
{phang}{cmd:. pwcorr price pred_price}{p_end}
{phang}{cmd:. matrix list importance}{p_end}


