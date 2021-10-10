{smcl}
{* *! version 2.1.0  09oct2020}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtime" "help MLRtime"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] parsnip" "help parsnip"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Generalized Synthetic Control Plots}

{phang}
{bf:gsynth} {hline 2} Visualizes estimation results of the generalized synthetic control method from R's gsynth


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:gsynth_plot}, [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Graph Saving Options}
{synopt:{opt saving(string)}} Filename to save to.
Can be .png, .pdf, .gif, .tiff, .bmp, or any 
{browse "https://stat.ethz.ch/R-manual/R-devel/library/grDevices/html/Devices.html":other graphics device}
 supported by R.
Defaults to "gsynth_plot.png".{p_end}
{synopt:{opt dim(string)}} Dimensions of the saved image, in terms of 
{opt dim(width height units)}, where {opt units} can be px, in, cm, or mm.
Defaults to {opt dim(480 480 px)}.
If width and height are specified but units are not, {opt units} defaults to 
px.{p_end}
{synopt:{opt savingopts(string)}} A set of options, in R syntax, separated by 
commas, to use in saving the file.
Rarely needed.
See {cmd: rcall: help(png)}, or similarly for the other image types; 
{opt width}, 
{opt height} and {opt units} are already covered by the {opt dim} option.
R true/false options must be specified in all-caps as {cmd:TRUE} or {cmd:FALSE},
 for example {cmd:restoreConsole=FALSE, pointsize=14}{p_end}
{synoptline}
{syntab:Plotting Options}
{synopt:{opt type(string)}} The type of the plot.
Must be one of the following: "gap" (plotting the average treatment effect on 
the treated; "raw" (plotting the raw data); "counterfactual", or "ct" for short,
 (plotting predicted Y(0)'s); "factors" (plotting estimated factors); "loadings"
 (plotting the distribution of estimated factor loadings);
 or "missing" (plotting status of each unit at each time point).{p_end}
{synopt:{opt xlab(string)}} Title for the x-axis.{p_end}
{synopt:{opt ylab(string)}} Title for the y-axis.{p_end}
{synopt:{opt main(string)}} Plot title.{p_end}
{synopt:{opt xlim(string)}} Two numbers specifying the range of x-axis.
When the time variable is a string, specify not original value but a counting
 number e.g.
{opt xlim(1 30)}.{p_end}
{synopt:{opt ylim(string)}} Two numbers specifying the range of y-axis, e.g.
{opt ylim(.5 1.5)}.{p_end}
{synopt:{opt legendOff}} Remove the legend.{p_end}
{synopt:{opt raw(string)}} Whether or how raw data for the outcome variable will
 be shown in the "counterfactual" plot.
Ignored if {opt type(counterfactual)} is not selected.
Must be one of the following: "none" (not showing the raw data); "band" (showing
 the middle 90 percentiles of the raw data); and "all" 
(showing the raw data as they are).
Default is "none".{p_end}
{synopt:{opt nfactors(integer)}} A positive integer that specifies the number of
 factors to be shown.
The maximum number if 4.
Ignored if {opt type(factors)} is not selected.{p_end}
{synopt:{opt id(string)}} A unit identifier that was in the data before running
 {cmd: gsynth} of which the predicted counterfactual or the 
difference between actual and predicted counterfactual is to be shown.
It can also be a vector specifying units to be plotted if {opt type(missing)} is
 selected when data magnitude is large.
Ignored if type is none of "missing", "counterfactual", or "gap".{p_end}
{synopt:{opt axis_adjust}} Adjust labels on x-axis.
Useful when class of time variable is string and data magnitude is large.{p_end}
{synopt:{opt no_theme_bw}} Don't use a black/white theme.{p_end}
{synopt:{opt shade_post}} Shade the post-treatment periods.{p_end}

{synoptline}
{p2colreset}{...}

{p 4 6 2}
{cmd:gsynth}

{marker description}{...}
{title:Description}

{pstd}
{cmd:gsynth_plot} is an interface between Stata and the generalized synthetic 
control {cmd: plot.gsynth} function in the R package {cmd: gsynth},
 by Xu (2017).
 It is a postestimation command for {cmd: gsynth} which can plot the results of
 the estimation, or the raw data used to get there.

{pstd}
The resulting plot will not be shown in Stata directly, but instead will be 
saved to file at filename {opt saving()}.

{pstd}
Unfortunately, troubleshooting your model if it does not work is rather 
difficult when using a wrapper like this.
You can get some help on the GitHub page at 
{browse "https://github.com/NickCH-K/MLRtime"} but I can't help everyone, 
you may be a bit on your own.
You may be able to use {cmd: rcall} to see what error messages come up if 
things are not being returned to Stata.

{pstd}
See {browse "https://yiqingxu.org/packages/gsynth/gsynth_examples.html"} for
 details on method and usage, as well as 
{cmd: rcall: help(plot.gsynth, package = 'gsynth')} for further documentation.

{pstd}
The use of any MLRtime function will often result in flashing blue screens.
If you are photosensitive you may want to look away.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing 
between R and Stata. The Stata Journal, 19(1), 61–82. 
{browse "https://doi.org/10.1177/1536867X19830891":Link}.

{phang} Xu, Y. (2017). Generalized Synthetic Control Method: Causal Inference 
with Interactive Fixed Effects Models. Political Analysis, 25 (1), 57-76.

{marker examples}{...}
{title:Examples}

Note that this syntax example uses an arbitrary treatment.

{phang}{cmd:. import delimited "https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/gapminder.csv", clear}{p_end}
{phang}{cmd:. g treat = continent == "Asia" & year >= 2001}{p_end}
{phang}{cmd:. * Using interactive fixed effects, and getting standard errors}{p_end}
{phang}{cmd:. gsynth lifeexp treat pop gdppercap, index(country year) se}{p_end}
{phang}{cmd:. gsynth_plot}{p_end}



