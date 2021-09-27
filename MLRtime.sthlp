{smcl}
{* *! version 2.0.0 24sep2021}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{vieweralsosee "[R] MLRtimesetup" "help MLRtimesetup"}{...}
{vieweralsosee "[R] grf" "help grf"}{...}
{vieweralsosee "[R] gsynth" "help gsynth"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{viewerjumpto "References" "examplehelpfile##references"}{...}
{title:MLRtimesetup}

{phang}
{bf:MLRtime} {hline 2} It's MLRtime


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:MLRtime}

{marker description}{...}
{title:Description}

{pstd}
{cmd:MLRtime} is a package designed to make it easier for Stata to interface with R's machine learning tools, using {help rcall} (Haghish, 2019). 

{pstd}
{cmd:MLRtime} the {it: command} is really just here so something will pop up when you type {cmd: help MLRtime} after installing it.

{pstd}
The actual commands of interest are: {help MLRtimesetup} which will set up your machine properly, {help grf} for running honest random forests, including causal forests, {help gsynth} for the generalized synthetic control method, including matrix completion, and {help ranger} for running random forests.

{marker author}{...}
{title:Author}

Nick Huntington-Klein
nhuntington-klein@seattleu.edu

{marker references}{...}
{title:References}

{phang} Haghish, E. F. (2019). Seamless interactive language interfacing between R and Stata. The Stata Journal, 19(1), 61–82. {browse "https://doi.org/10.1177/1536867X19830891":Link}.


