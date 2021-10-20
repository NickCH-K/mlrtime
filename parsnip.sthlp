{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Parsnip}

{phang}
{bf:parsnip} {hline 2} Run a machine learning model in R's parsnip and return 
results


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:parsnip} {help depvar} {help varlist} [{help if}] [{help in}], 
model(string) [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{help depvar}} The dependent variable being predicted.
Depending on the {opt model()} and {opt mode()} there may be restrictions on 
the variable's type.
If {opt depvar} is a factor variable, it is generally recommended that you 
convert it to a string variable.
All value labels will be dropped by {cmd: parsnip}.{p_end}
{synopt:{help varlist}} The set of predictors.
Factor-variable and time series operators are allowed, although their names are 
not preserved, so postestimation may become more difficult to interpret.
Additionally, a number of the estimators do not have built-in ways to drop 
variables with no variation.
So if, for example, you have a factor variable where one of the levels is absent
 in the training data, you may want to make dummies by hand, excluding
 that one.{p_end}
{synopt:{opt model}} Required.
The type of model to fit.
See details below for how to check for documentation these models.
Currently supports: {it: boost_tree}, {it: gen_additive_mod}, {it: linear_reg}, 
{it: logistic_reg}, {it: mars}, {it: mlp}, {it: multinom_reg}, 
{it: nearest_neighbor}, {it: rand_forest}, {it: svm_linear}, {it: svm_poly}, 
 {it: svm_rbf}.{p_end}
{synoptline}
{syntab:Main Options}
{synopt:{opt clearR}} Start a new R environment before running your 
command.{p_end}
{synopt:{opt seed(integer)}} Set the R seed to this.{p_end}
{synopt:{opt replace}} Drop variables that have the same names as those about 
to be created by {opt pred()}.
Note that in the case of models that produce more than one column of 
predictions, this may lead to variables being dropped even if they just have 
{opt pred()} as a stem rather than being the exact name given in 
{opt pred()}.{p_end}
{synopt:{opt results(string)}} What to do with the results (i.e. coefficients, 
not predictions, noting that not all models will have coefficients) other than 
printing them to screen.
Setting this to {opt results(replace)} will replace the data in memory with the 
result of running the R {cmd: tidy()} function on the results.
Setting {opt results()} to a string that ends in .dta or .csv will instead 
write the {cmd: tidy()} output to a Stata or CSV file, respectively.
If you forget the extension (and didn't write "results") it will assume you 
wanted a .dta and output one.
{it: Importantly, note that tidy() doesn't work with any model that does not 
produce coefficients.
For these models there are no results to return, only predictions.}{p_end}
{syntab:Stata Variables}
{synopt:{opt hold(varname)}} Variable name indicating a hold/train split.
A value of 0 will be used in estimation, predictions will be generated for 
values of 1, and missing values will be excluded from both.{p_end}
{synopt:{opt pred(string)}} New variable name to store model predictions in.
For methods that produce more than one column of predictions, multiple columns 
will be made that all start with {opt pred} as a stem.
Must be a valid name in R and Stata.
{cmd: predicted} by default.
If this variable already exists, be sure {opt replace} is specified so it can 
be overwritten.
Specify {opt pred(none)} to skip prediction.{p_end}
{synopt:{opt id(varname)}} A unique row identifier that will be used to merge 
predictions from R back into Stata.
If not specified, a new variable called {it:parsnip_merge_id} will be 
created.{p_end}
{syntab:Additional Customization}
{synopt:{opt predopts(string)}} A set of options, in R syntax, separated by 
commas, to use in the {cmd: predict} command.
See {cmd: rcall: help(predict.modeltype, package = 'packagename')} if you know 
the object type your estimation method produces and the name of the package it 
comes from, which then takes the place of "modeltype" in that help command.
Do not specify the {cmd:newdata} option.
R true/false options must be specified in all-caps as {cmd:TRUE} or {cmd:FALSE},
 for example {cmd:ll.weight.penalty=TRUE, num.threads=4}{p_end}
{synopt:{opt otheropts(string)}} A set of options supported by the 
{opt engine()}, in R syntax, separated by commas, to pass to your 
{cmd: set_engine()} command and thus on to the estimation command.
See details below for accessing help files for your command; these help files 
will specify other options you can set.
You can refer to other variables in your data as part of the overall data set 
{cmd: dataset}, i.e. {cmd: dataset@@varname}, or similarly {cmd: holding} and 
{cmd: training} for the holding and training subsets.
Use "@@" instead of "$" where $ appears in the R code to avoid confusing Stata.
This will be ignored if {opt engine()} is not specified.{p_end}
{synopt:{opt predformula(string)}} A custom prediction formula, in R syntax, to 
pass to your {cmd: fit()} command.{p_end}
{synopt:{opt precedes(string)}} A list of R commands, separated by semicolons 
({cmd: ;}), of whatever you'd like R to do after importing your data but before 
running your {cmd: parsnip} command.
You can refer to other variables in your data as part of the data set 
{cmd: dataset}, i.e. {cmd: dataset@@varname}, or similarly {cmd: holding} and 
{cmd: training} for the holding and training subsets.
Use "@@" instead of "$" where $ appears in the R code to avoid confusing 
Stata.{p_end}
{synoptline}
{syntab:Shared parsnip Estimation Options (repeated below)}
{synopt:{opt mode(string)}} the prediction outcome mode.
Different options available depending on which {opt model()} you have, 
specified below.{p_end}
{synopt:{opt engine(string)}} The computational engine to use for fitting.
There is a default option selected for each {opt model()} but you will usually 
want to specify this.
Options specified below.{p_end}
{synoptline}
{syntab:model(boost_tree) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can be "xgboost" (default) or "C5.0".
{opt engine(C5.0)} only works with {opt mode(classification)}.
"spark" is not supported in {cmd: MLRtime}.{p_end}
{synopt:{opt mtry(real)}} A number for the number (or proportion) of predictors 
that will be randomly sampled at each split when creating the tree models 
(specific engines only).{p_end}
{synopt:{opt trees(integer)}} An integer for the number of trees contained in 
the ensemble.{p_end}
{synopt:{opt min_n(integer)}} An integer for the minimum number of data points 
in a node that is required for the node to be split further.{p_end}
{synopt:{opt tree_depth(integer)}} An integer for the maximum depth of the tree 
(i.e. number of splits) (specific engines only).{p_end}
{synopt:{opt learn_rate(real)}} A number for the rate at which the boosting 
algorithm adapts from iteration-to-iteration (specific engines only).{p_end}
{synopt:{opt loss_reduction(real)}} A number for the reduction in the loss 
function required to split further (specific engines only).{p_end}
{synopt:{opt sample_size(real)}} A number for the number (or proportion) of 
data that is exposed to the fitting routine.
For xgboost, the sampling is done at each iteration while C5.0 samples once 
during training.{p_end}
{synopt:{opt stop_iter(integer)}} The number of iterations without improvement 
before stopping (specific engines only).{p_end}
{synoptline}
{syntab:model(gen_additive_mod) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".
Because {opt mode(classification)} does not work in the standard way with 
predictions {it:or} tables of coefficients, you probably won't get much out of 
it unless you can do your postestimation in R code using {cmd: rcall}; you 
should specify {opt pred(none)} if specifying 
{opt mode(classification) model(gen_additive_mod)}.{p_end}
{synopt:{opt engine(string)}} For now can only be "mgcv", the default.{p_end}
{synopt:{opt select_features}} If specified, the model has the ability to 
eliminate a predictor (via penalization).
Increasing {opt adjust_deg_free} will increase the likelihood of removing 
predictors.{p_end}
{synopt:{opt adjust_deg_free(real)}} If {opt select_features} is specified, 
then this acts as a multiplier for smoothness.
Increase this beyond 1 to produce smoother models.{p_end}
{synoptline}
{syntab:model(linear_reg), model(logistic_reg), and model(multinom_reg) Additional Options}
{synopt:{opt mode(string)}} Prediction outcome mode.
Can only be the defaults, which are "regression" for {opt model(linear_reg)} 
or "classification" for {opt model(logistic_reg)} or 
{opt model(multinom_reg)}.{p_end}
{synopt:{opt engine(string)}} All three models have access to "glmnet" and 
"keras" (see Description for notes on "keras").
{opt model(linear_reg)} can also be "stan" or its default "lm".
{opt model(logistic_reg)} can also be "LiblineaR" or its default "glm".
{opt model(multinom_reg)} can also be its default "nnet" (does not allow 
{opt results(replace)}).
"spark" is not supported in {cmd: MLRtime}.{p_end}
{synopt:{opt penalty(real)}} Required if {opt engine(glmnet)} is specified.
A non-negative number representing the total amount of regularization (specific 
engines only).
For keras models, this corresponds to purely L2 regularization (aka weight 
decay) while the other models can be either or a combination of L1 and L2 
(depending on the value of {opt mixture}).{p_end}
{synopt:{opt mixture(real)}} A number between zero and one (inclusive) that is 
the proportion of L1 regularization (i.e. lasso) in the model.
When mixture = 1, it is a pure lasso model while mixture = 0 indicates that 
ridge regression is being used (specific engines only).
For LiblineaR models, mixture must be exactly 0 or 1 only.{p_end}
{synoptline}
{syntab:model(mars) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can only be its default "earth".{p_end}
{synopt:{opt num_terms(integer)}} The number of features that will be retained 
in the final model, including the intercept.{p_end}
{synopt:{opt prod_degree(integer)}} The number of features that will be retained
 in the final model, including the intercept.{p_end}
{synopt:{opt prune_method(string)}} The pruning method.
Can be the default "backward", or "none", "exhaustive", "forward", "seqrep", or
 "cv".{p_end}
{synoptline}
{syntab:model(mlp) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can be "keras" or default "nnet" (see Description
 for notes on "keras").{p_end}
{synopt:{opt hidden_units(integer)}} An integer for the number of units in the 
hidden model.{p_end}
{synopt:{opt penalty(real)}} A non-negative numeric value for the amount of 
weight decay.{p_end}
{synopt:{opt dropout(real)}} A number between 0 (inclusive) and 1 denoting the 
proportion of model parameters randomly set to zero during model 
training.{p_end}
{synopt:{opt epochs(integer)}} An integer for the number of training 
iterations.{p_end}
{synopt:{opt activation(string)}} The type of relationship between the original 
predictors and the hidden unit layer.
The activation function between the hidden and output layers is automatically 
set to either "linear" or "softmax" depending on the type of outcome.
Possible values are: "linear", "softmax", "relu", and "elu".{p_end}
{synoptline}
{syntab:model(nearest_neighbor) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can only be the default "kknn".{p_end}
{synopt:{opt neighbors(integer)}} The number of neighbors to consider (often 
called k).
For kknn, a value of 5 is used if neighbors is not specified.{p_end}
{synopt:{opt weight_func(string)}} The type of kernel function used to weight 
distances between samples.
Valid choices are: "rectangular", "triangular", "epanechnikov", "biweight", 
"triweight", "cos", "inv", "gaussian", "rank", or "optimal".{p_end}
{synopt:{opt dist_power(real)}} The parameter used in calculating Minkowski 
distance.{p_end}
{synoptline}
{syntab:model(rand_forest) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can be the default "ranger", or "randomForest".
"spark" is not supported in {cmd: MLRtime}.{p_end}
{synopt:{opt mtry(integer)}} The number of predictors that will be randomly 
sampled at each split when creating the tree models.{p_end}
{synopt:{opt trees(integer)}} The number of trees contained in the 
ensemble.{p_end}
{synopt:{opt min_n(integer)}} The minimum number of data points in a node that 
are required for the node to be split further.{p_end}
{synoptline}
{syntab:model(svm_linear) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can be the default "LiblineaR", or 
"kernlab".{p_end}
{synopt:{opt cost(real)}} A positive number for the cost of predicting a sample
 within or on the wrong side of the margin{p_end}
{synopt:{opt margin(real)}} A positive number for the epsilon in the SVM 
insensitive loss function (regression only){p_end}
{synoptline}
{syntab:model(svm_poly) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can only be the default "kernlab".{p_end}
{synopt:{opt cost(real)}} A positive number for the cost of predicting a sample
 within or on the wrong side of the margin{p_end}
{synopt:{opt degree(real)}} A positive number for polynomial degree.{p_end}
{synopt:{opt scale_factor(real)}} A positive number for the polynomial scaling
 factor.{p_end}
{synopt:{opt margin(real)}} A positive number for the epsilon in the SVM
 insensitive loss function (regression only){p_end}
{synoptline}
{syntab:model(svm_rbf) Additional Options}
{synopt:{opt mode(string)}} Required.
Prediction outcome mode.
Options "regression" or "classification".{p_end}
{synopt:{opt engine(string)}} Can only be the default "kernlab".{p_end}
{synopt:{opt cost(real)}} A positive number for the cost of predicting a sample
 within or on the wrong side of the margin{p_end}
{synopt:{opt rbf_sigma(real)}} A positive number for radial basis
 function.{p_end}
{synopt:{opt margin(real)}} A positive number for the epsilon in the SVM
 insensitive loss function (regression only){p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:parsnip}

{marker description}{...}
{title:Description}

{pstd}
{cmd:parsnip} is an interface between Stata and the various machine learning
 functions in the R package {cmd: parsnip}, by Kuhn and Vaughn (2021).
Note the "spark" engine accessible in the R package is not included since
 managing a Spark connection with in-memory Stata data doesn't make all that
 much sense anyway.

{pstd}
parsnip is a common API for modeling a wide range of analysis functions, 
focusing on those popular in machine learning (including many that are not
 machine-learning-specific, like logistic regression).
The full list of supported models and engines is quite long, and is likely to
 continue being updated (hopefully without breaking this Stata function).
The list can be seen at 
{browse "https://www.tidymodels.org/find/parsnip/":the tidymodels website}.

{pstd}
{cmd:parsnip} will send data to an R session, fit the model of interest, and 
then return model results or predicted values, as desired and appropriate for
 the model.
Results will be printed to screen but {it:not} in Stata-table format, and 
results will not be available by matrix after estimation; this is a consequence
 of the wide range of available models with different forms of output.
Predicted values are of course available in the {opt pred()} variable after
 estimation.
Model results itself, i.e. things like coefficients, can be accessed using the
 option {opt results(replace)}, which will replace the data in memory with the
 results.
There is not a suite of postestimation commands for these results, although you
 can use {cmd:rcall} to run postestimation in R, referring to the estimated 
 model object as {cmd: M}.

{pstd}
The R {cmd: parsnip} package itself is a common API that refers out to a long
 list of other estimation packages.
Some of these do not run in R and require additional installation.
For example, {opt engine(keras)} will require that you have a TensorFlow 
installation already on your system that is accessible from R.
Before using {opt engine(keras)}, you must have a valid installation of 
TensorFlow.
See {browse "https://tensorflow.rstudio.com/installation/": this page} for
 instructions on installing TensorFlow in R.
If you do not have TensorFlow installed where R can find it, you can try 
{cmd: rcall: tensorflow::install_tensorflow()}, although this process may be
 finicky.
Yes, this means that if {opt engine(keras)} is specified, the Stata package
 {cmd: MLRtime} contains the function {cmd:parsnip} which calls the Stata
 {cmd: rcall} package, which calls the R package {cmd: parsnip}, which calls
 the R package {cmd: keras}, which calls the R package {cmd: tensorflow}, which
 calls the platform TensorFlow, which itself is written in (and calls on 
 libraries in) Python, C++, and CUDA.
Welcome to computing in the 2020s.

{pstd}
Unfortunately, troubleshooting your model if it does not work is rather 
difficult when using a wrapper like this.
You can get some help on the GitHub page at 
{browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, you
 may be a bit on your own.
You may be able to use {cmd: rcall} to see what error messages come up if things
 are not being returned to Stata, or try putting {cmd: set trace on} before
 running {cmd: parsnip} so you can see the R error message being read back, if
 it doesn't print to the console.

{pstd}
Syntax takes the form of {help depvar} {help varlist}, {opt model()}.
{opt model()} is the type of model you'll be fitting.
You'll likely also want to specify {opt engine()}, which determines which
 estimation engine / algorithm will be used to fit the model, {opt pred()},
 which is the name of the variable where predictions will be stored in Stata,
 {opt replace} if that variable already exists, and {opt hold()} to specify a
 hold-out set to predict for, using only the training data to fit the model.

{pstd}
See {cmd: rcall help('linear_reg', package = 'parsnip')} (or other models
 besides {cmd: linear_reg}, as approprate) for details on the different kinds
 of engines available for that model.
The help page includes links to more information on the different engines.
These links unfortunately don't work when calling R's {cmd: help} using 
{cmd: rcall}, but you can get more information by searching 
{browse "https://www.tidymodels.org/find/parsnip/":the tidymodels website}
 for the model, or doing 
 {cmd: rcall help('detail_model_engine', package = 'parsnip')}, replacing 
 "model" and "engine" with the model and engine of interest, respectively.

{pstd}
Note that if you know R you can add your own code as you like using 
{cmd: rcall}.
The {opt precedes} option allows the insertion of R code after data is imported
 but before estimating the model, and you can use {cmd: rcall} as normal 
 afterwards, referring to the fitted model object as {cmd: M}.
The relevant objects will remain in the R session and can be accessed and 
manipulated further with R code using {help rcall} afterwards (Haghish 2019).
Run {help MLRtimesetup} before use for the first time.


{pstd}
Additional note: while {help depvar} and {help varlist} accept time-series,
 interaction, and factor operators, the names of these variables are not 
 maintained in an interpretable way.
This may be a problem if you plan to do some sort of postestimation that 
reports the variable names of predictors.
In this case you should create factor and time-series variables by hand and
 store them directly in the data.

{pstd}
The use of any MLRtime function will often result in flashing blue screens.
If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Kuhn, M. and Vaughan, D. (2021). parsnip: A Common API to Modeling
 and Analysis Functions. R package version 0.1.7. 
 {browse "https://CRAN.R-project.org/package=parsnip": Link}.

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
{phang}{cmd:. * I wonder how LASSO predictions compare to random forest!}{p_end}
{phang}{cmd:. parsnip price mpg headroom trunk i.modeln, model(linear_reg) hold(hold) engine(glmnet) penalty(.5) replace clearR pred(lasso_prediction)}{p_end}
{phang}{cmd:. parsnip price mpg headroom trunk i.modeln, model(rand_forest) hold(hold) engine(ranger) mode(regression) replace clearR pred(RF_prediction)}{p_end}
{phang}{cmd:. * We could, like in help grf, swap the training and holdout sets to get predictions for everyone}{p_end}
{phang}{cmd:. * but let's just look at which prediction correlates to the truth better (among our holdouts)}{p_end}
{phang}{cmd:. pwcorr price lasso_prediction RF_prediction}{p_end}
{phang}{cmd:. * Looks like the random forest does better here!}{p_end}

