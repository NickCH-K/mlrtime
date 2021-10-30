{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] mlrtime" "help mlrtime"}{...}
{vieweralsosee "[R] mlrtimesetup" "help mlrtimesetup"}{...}
{vieweralsosee "[R] grf_ate" "help grf_ate"}{...}
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
{bf:grf} {hline 2} Run a generalized random forest model in R's grf and return results


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:grf} {help depvar} {help varlist} [{help if}] [{help in}] [{help iweight}],
 forest_type(string) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{help depvar}} The dependent variable being predicted.
Note that for {opt forest_type(probability_forest)} this must be a nonnegative 
integer.
For {opt forest_type(survival_forest)} this is the event time, which may be
 negative.{p_end}
{synopt:{help varlist}} The set of predictors.
Factor-variable and time series operators are allowed, although their names are
 not preserved, so postestimation may become more difficult to interpret.{p_end}
{synopt:{opt forest_type}} The kind of forest to estimate.
Currently supports {it:causal_forest}, {it:instrumental_forest}, 
{it:ll_regression_forest} (local linear regression forest), 
{it:multi_regression_forest} (multi-task regression forest), 
{it: probability_forest}, {it:quantile_forest}, or {it:survival_forest}.
Experimental forest types are currently not supported.
Different tree types may require different data formats for variables; see 
{browse "https://grf-labs.github.io/grf/"}.{p_end}
{synopt:{opt clearR}} Start a new R environment before running your 
command.{p_end}
{synopt:{opt seed(integer)}} Set the seed to this in both R and C.{p_end}
{synopt:{opt replace}} Drop variables that have the same name as those about to
 be created.
With probability_forest, quantile_forest, and survival_forest this will drop all
 variables that start with {opt pred} as a stem.{p_end}
{syntab:Stata Variables}
{synopt:{opt hold(varname)}} Variable name indicating a hold/train split.
A value of 0 will be used in estimation, predictions will be generated for 
values of 1, and missing values will be excluded from both.{p_end}
{synopt:{opt pred(string)}} New variable name to store effect predictions in.
For methods that produce more than one column of predictions, multiple columns 
will be made that all start with {opt pred} as a stem.
Must be a valid name in R and Stata.
{cmd: predicted} by default.
If this variable already exists, be sure {opt replace} is specified so it can be
 overwritten.{p_end}
{synopt:{opt se(string)}} Variable name to store effect/prediction standard
 errors in.
For methods that produce more than one column of predictions, multiple columns
 will be made that all start with {opt se} as a stem.
Must be a valid name in R and Stata.
If omitted, standard errors will not be calculated.
Not available for {opt forest_type} values of {opt multi_regression_forest} or
 {opt quantile_forest}, {p_end}
{synopt:{opt id(varname)}} A unique row identifier that will be used to merge
 predictions from R back into Stata.
If not specified, a new variable called {it:grf_merge_id} will be
 created.{p_end}
{syntab:Additional Customization}
{synopt:{opt predopts(string)}} A set of options, in R syntax, separated by
 commas, to use in the {cmd: predict} command.
See {cmd: rcall: help(predict.causal_forest, package = 'grf')}, or similarly for
 the other forest types.
Do not specify the {cmd:object} or {cmd:newdata} options.
R true/false options must be specified in all-caps as {cmd:TRUE} or {cmd:FALSE},
 for example {cmd:ll.weight.penalty=TRUE, num.threads=4}{p_end}
{synopt:{opt otheropts(string)}} A set of options unsupported by this function,
 in R syntax, separated by commas, to pass to your {cmd: grf} command.
See {cmd: rcall: help(causal_forest, package = 'grf')}, or similarly for the
 other forest types.
These functions can refer to the covariate, treatment, and outcome matrices as
 {cmd: X}, {cmd: W}, and {cmd: Y}, respectively (or {cmd: holdingX} for X in
 the holding data).
You can refer to other variables in your data as part of the overall data set
 {cmd: dataset}, i.e.
{cmd: dataset@@varname}, or similarly {cmd: holding} and {cmd: training} for the
 holding and training subsets.
Use "@@" instead of "$" where $ appears in the R code to avoid confusing Stata.
As of this writing, all options should be supported, but this may come in handy
 if the grf package updates and mlrtime hasn't caught up yet.{p_end}
{synopt:{opt precedes(string)}} A List of R commands, separated by semicolons
 ({cmd: ;}), of whatever you'd like R to do after importing your data but before
 running your {cmd: grf} command.
These functions can refer to (and perhaps manipulate!) the covariate, treatment,
 and outcome matrices as {cmd: X}, {cmd: W}, and {cmd: Y}, respectively (or 
 {cmd: holdingX} for X in the holding data).
You can refer to other variables in your data as part of the data set 
{cmd: dataset}, i.e.
{cmd: dataset@@varname}, or similarly {cmd: holding} and {cmd: training} for the
 holding and training subsets.
Use "@@" instead of "$" where $ appears in the R code to avoid confusing 
Stata.{p_end}
{synoptline}
{syntab:Shared Forest Estimation Options}
{synopt:{opt num_trees(integer 2000)}} Number of trees grown in the forest.
Higher values recommended if estimating standard errors.
Default is only 1000 for {opt forest_type(survival_forest)}.{p_end}
{synopt:{opt clusters(varname)}} Variable name (integer or string) indicating 
clusters of observations.{p_end}
{synopt:{opt equalize_cluster_weights}} If omitted, each unit is given the same 
weight (so that bigger clusters get more weight).
If included, each cluster is given equal weight in the forest.
In this case, during training, each tree uses the same number of observations 
from each drawn cluster: If the smallest cluster has K units, then when we 
sample a cluster during training, we only give a random K elements of the 
cluster to the tree-growing procedure.
When estimating average treatment effects, each observation is given weight 
1/cluster size, so that the total weight of each cluster is the same.
Note that, if this argument is omitted, sample weights may also be directly 
adjusted via the {opt iweight}.
Cannot be used with sample weights.{p_end}
{synopt:{opt sample_fraction(real .5)}} Fraction of the data used to build 
each tree.
Note: unless you include {opt no_honesty}, these subsamples will further be cut
 by a factor of {opt honesty_fraction}.
Default is 0.5.{p_end}
{synopt:{opt mtry(integer)}} Number of variables tried for each split.
Default is 20 plus the square root of the number of variables.{p_end}
{synopt:{opt min_node_size(integer 5)}} A target for the minimum number of
 observations in each tree leaf.
Note that nodes with size smaller than min_node_size can occur, as in the
 original randomForest package.
Default is 5, or 15 for {opt forest_type(survival_forest)}.{p_end}
{synopt:{opt no_honesty}} Skip honest splitting (i.e., sub-sample splitting).
For a detailed description of {opt honesty}, {opt honesty_fraction}, 
{opt honesty_prune_leaves}, and recommendations for parameter tuning, see the 
{cmd: grf} algorithm reference.{p_end}
{synopt:{opt honesty_fraction(real .5)}} The fraction of data that will be used
 for determining splits.
Corresponds to set J1 in the notation of the paper.
Default is 0.5 (i.e.
half of the data is used for determining splits).{p_end}
{synopt:{opt no_honesty_prune_leaves}} Instead of pruning the estimation sample
 tree such that no leaves are empty, keep the same tree as determined in the
 splits sample (if an empty leave is encountered, that tree is skipped and
 does not contribute to the estimate).
Setting this may improve performance on small/marginally powered data, but
 requires more trees (note: tuning does not adjust the number of trees).
 Doesn't matter if {opt no_honesty} is set.{p_end}
{synopt:{opt alpha(real .05)}} A tuning parameter that controls the maximum
 imbalance of a split.
Default is 0.05.{p_end}
{synopt:{opt imbalance_penalty(real 0)}} A tuning parameter that controls how
 harshly imbalanced splits are penalized.
Default is 0.
Does not apply to {opt forest_type(survival_forest)}.{p_end}
{synopt:{opt ci_group_size(integer 2)}} The forest will grow ci_group_size trees
 on each subsample.
In order to provide confidence intervals, ci.group.size must be at least 2.
Default is 2.{p_end}
{synopt:{opt num_threads(integer)}} Number of threads used in training.
By default, the number of threads is set to the maximum hardware
 concurrency.{p_end}
{synoptline}
{syntab:Cross-Validation Parameters (for causal, instrumental,
 ll_regression, regression forests)}
{synopt:{opt tune_parameters(string)}} A list of parameter names to tune,
 separated by spaces.
If {opt all}: all tunable parameters are tuned by cross-validation.
Default is that no parameters are tuned.
See {cmd: rcall: help(causal_forest, package = 'grf')} (or similarly for 
other{opt forest_type}s) for detail on which parameters are tunable.
This option accepts either R-original .
or Stata _ in option names.{p_end}
{synopt:{opt tune_num_trees(integer 200)}} The number of trees in each 'mini
 forest' used to fit the tuning model.
Default is 200.{p_end}
{synopt:{opt tune_num_reps(integer 50)}} The number of forests used to fit the
 tuning model.
Default is 50.{p_end}
{synopt:{opt tune_num_draws(integer 1000)}} The number of random parameter
 values considered when using the model to select the optimal parameters.
Default is 1000.{p_end}
{synoptline}
{syntab:forest_type(causal_forest) Additional Options}
{synopt:{opt w(varname)}} Required.
Name of the treatment variable.
Required if {opt:forest_type(causal_forest)} is specified.{p_end}
{synopt:{opt y_hat(varname)}} Conditional predictions of Y, marginalizing over
 treatment, created yourself rather than relying on {cmd:grf} to do it for
 you.{p_end}
{synopt:{opt w_hat(varname)}} Conditional predictions of treatment propensities,
 created yourself rather than relying on {cmd:grf} to do it for you.{p_end}
{synopt:{opt no_stabilize_splits}} Don't take the treatment into account when
 determining the imbalance of a split.{p_end}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(instrumental_forest) Additional Options}
{synopt:{opt w(varname)}} Required.
Name of the treatment variable.
Required if {opt:forest_type(instrumental_forest)} is specified.{p_end}
{synopt:{opt z(varname)}} Required.
The (single) binary or real excluded instrument.
Required if {opt:forest_type(instrumental_forest)} is specified.{p_end}
{synopt:{opt y_hat(varname)}} Conditional predictions of Y, marginalizing over
 treatment, created yourself rather than relying on {cmd:grf} to do it for
 you.{p_end}
{synopt:{opt w_hat(varname)}} Conditional predictions of treatment propensities,
 created yourself rather than relying on {cmd:grf} to do it for you.{p_end}
{synopt:{opt z_hat(varname)}} Conditional predictions of the instrument, created
 yourself rather than relying on {cmd:grf} to do it for you.{p_end}
{synopt:{opt no_stabilize_splits}} Don't take the treatment into account when
 determining the imbalance of a split.{p_end}
{synopt:{opt reduced_form_weight(real 0)}} The extent to which splits should be
 regularized towards a naive splitting criterion that ignores the instrument
 (and instead emulates a causal forest).{p_end}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(ll_regression_forest) Additional Options}
{synopt:{opt enable_ll_split}} (experimental) Optional choice to make forest
 splits based on ridge residuals as opposed to standard CART splits.{p_end}
{synopt:{opt ll_split_weight_penalty}} If using local linear splits, user can
 specify whether or not to use a covariance ridge penalty, analogously to the
 prediction case.{p_end}
{synopt:{opt ll_split_lambda(real .1)}} Ridge penalty for splitting.
Defaults to 0.1.{p_end}
{synopt:{opt ll_split_variables(varlist)}} Linear correction variables for
 splitting.
Defaults to all predictors.
If you use this option, it is strongly recommended that you do not use factor or
 time-series operators in your set of predictors.{p_end}
{synopt:{opt ll_split_cutoff(real)}} Enables the option to use regression
 coefficients from the full dataset for LL splitting once leaves get
 sufficiently small.
Leaf size after which we use the overall beta.
Defaults to the square root of the number of samples.
If desired, users can enforce no regulation (i.e., using the leaf betas at each
 step) by setting this parameter to zero.{p_end}
{synoptline}
{syntab:forest_type(multi_regression_forest) Additional Options}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(probability_forest) Additional Options}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(quantile_forest) Additional Options}
{synopt:{opt quantiles(string)}} A list of quantiles used to calibrate the
 forest, separated by spaces, for example {opt quantiles(.1 .5 .9)} would
 replicate the default of the 10th, 50th, and 90th percentiles.{p_end}
{synopt:{opt quantiles_predict(string)}} A list of quantiles to predict,
 separated by spaces.
Defaults to being the same as {opt quantiles}.
Predictions will be returned as the variables named with the {opt pred} option
 followed by 1, 2, 3, etc., for the 1st quantile listed for 
 {opt quantiles_predict}, etc..
So by default, {it: predicted1} will give predictions for the 10th percentile,
 {it: predicted2} for the 50th, and {it: predicted3} for the 90th.
{p_end}
{synopt:{opt regression_splitting)}} Whether to use regression splits when
 growing trees instead of specialized splits based on the quantiles (the
 default).
Setting this flag to true corresponds to the approach to quantile forests from
 Meinshausen (2006).{p_end}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(regression_forest) Additional Options}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synoptline}
{syntab:forest_type(survival_forest) Additional Options}
{synopt:{opt d(varname)}} Required.
Event type; this is 0 if censored or 1 if failure.{p_end}
{synopt:{opt failure_times(string)}} A list of of event times to fit the
 survival curve at.
If not specified, then all the observed failure times are used.
This speeds up forest estimation by constraining the event grid.
Observed event times are rounded down to the last sorted occurance less than or
 equal to the specified failure time.
The time points should be in increasing order.{p_end}
{synopt:{opt failure_times_predict(string)}} A list of of event times to create
 predictionsat.
Defaults to being the same as {opt failure_times}.
The time points should be in increasing order.{p_end}
{synopt:{opt no_compute_oob_predictions}} Skip computing OOB predictions on the
 training set.{p_end}
{synopt:{opt prediction_type(string)}} The type of estimate of the survival
 function, choices are "Kaplan-Meier" or "Nelson-Aalen", with "Kaplan-Meier"
 as the default.
Irrelevant if {opt no_compute_oob_predictions} is applied.
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:grf}

{marker description}{...}
{title:Description}

{pstd}
{cmd:grf} is an interface between Stata and the various "honest random forest"
 functions in the R package {cmd: grf}, by Athey, Tibshirani, and Wager (2019).
 This notably includes {cmd: causal_forest}.

{pstd}
It will send data to an R session, run the causal forest, and then return the
 relevant results in variable form.
It can then be followed by {cmd: grf_ate} to get average treatment effects.


{pstd}
Unfortunately, troubleshooting your model if it does not work is rather
 difficult when using a wrapper like this.
You can get some help on the GitHub page at 
{browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you
 may be a bit on your own.
You may be able to use {cmd: rcall} to see what error messages come up if things
 are not being returned to Stata.

{pstd}
Syntax takes the form of {help depvar} {help varlist}, {opt forest_type()}.
{opt forest_type()} is the type of regression forest you'll be running.
{help depvar} is the dependent variable being predicted ({cmd:Y} in {cmd: grf}
 syntax), and {help varlist} is the list of variables used to predict the
 outcome or to predict treatment effect heterogeneity, depending on
 {opt forest_type()} ({cmd:X}).
These should be variables in Stata and not matrices.

{pstd}
See {browse "https://grf-labs.github.io/grf/"} for details on the different
 kinds of forests and the customization options available, as well as all forms
 of documentation.

{pstd}
{cmd: grf} can be followed by the postestimation commands {cmd: grf_ate} to get
 an average treatment effect, {cmd: grf_test_calibration} to test the 
 calibration of the forest, or {cmd: grf_variable_importance} to estimate an 
 "importance" measure for each variable.

{pstd}
Note that if you know R you can add your own code as you like using
 {cmd: rcall}.
The {opt precedes} option allows the insertion of R code after data is imported
 but before estimating the model, and you can use {cmd: rcall} as normal
 afterwards, referring to the estimated model object as {cmd: M}.
The relevant objects will remain in the R session and can be accessed and
 manipulated further with R code using {help rcall} afterwards (Haghish 2019).
Run {help mlrtimesetup} before use for the first time.
It is also strongly recommended that you read 
{cmd: rcall: help(causal_forest, package = 'grf')} (or similarly for other 
{it:forest_type} options) to understand the options syntax and how to use the 
{cmd: M} object after it is created.

{pstd}
Additional note: while {help depvar}, {help varlist} and most of the other ways
 of specifying variables ({opt w}, {opt y_hat}, {opt w_hat}) accept time-series,
 interaction, and factor operators, the names of these variables are not
 maintained in an interpretable way.
This may be a problem if you plan to do some sort of postestimation that reports
 the variable names of predictors.
In this case you should create factor and time-series variables by hand and
 store them directly in the data.

{pstd}
The use of any mlrtime function will often result in flashing blue screens.
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
{phang}{cmd:. }{p_end}
{phang}{cmd:. * Swap the training and holdout sets to get predictions for everyone}{p_end}
{phang}{cmd:. replace hold = 1-hold}{p_end}
{phang}{cmd:. grf price mpg headroom trunk i.modeln, forest_type(causal_forest) w(foreign) replace clearR pred(estimated_effect_2) se(SE_effect_2) hold(hold)}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. replace estimated_effect = estimated_effect_2 if hold == 1}{p_end}
{phang}{cmd:. replace SE_effect = SE_effect_2 if hold == 1}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. summ estimated_effect SE_effect}{p_end}


