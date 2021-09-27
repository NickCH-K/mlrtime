*! gsynth v.2.0.0 Run a forest estimation in R's gsynth package. 20sep2021 by Nick CH-K
cap prog drop gsynth
prog def gsynth, eclass
	
	syntax anything [if] [in] [iweight], index(varlist) ///
	[clearR precedes(string) att_file_replace(string) /// Base option
	 force(string) cl(varname) r(integer -1) lambda(string) ///
	 nlambda(integer -1) no_cv criterion(string) k(integer -1) ///
	 em estimator(string) se nboots(integer -1) inference(string) ///
	 cov_ar(integer -1) no_parallel cores(integer -1) tol(real -1) ///
	 seed(integer -1) min_T0(integer 5) alpha(real -1) normalize ///
	]

	version 15
	
	marksample touse
	
	* c'mon Stata
	local CV = "`cv'"
	local EM = "`em'"
	
	* This check nicked from Jonathan Roth's staggered package
	capture findfile rcall.ado
	if _rc != 0 {
	 display as error "rcall package must be installed. Run MLRtimesetup."
	 error 198
	}
	
	* gsynth requires version 2.1+
	rcall_check, rversion(2.1)
		
	if "`clearR'" == "clearR" {
		rcall clear
	}
	
	capture rcall: library(gsynth)
	if _rc != 0{
		display as error "Package (gsynth) is missing. Run MLRtimesetup."
		exit
	} 
	
	quietly {
		**** PREPARE VARIABLES
		* Two different ways of getting data back, depending on SE
		local hasSE = 0
		local savopts = ", add.rownames = TRUE, convert.underscore = TRUE"
		if "`se'" == "se" {
			local retcode = "readstata13::save.dta13(as.data.frame(M[['est.avg']]), 'temp_gsynth_avg.dta'`savopts'); readstata13::save.dta13(as.data.frame(M[['est.beta']]), 'temp_gsynth_coef.dta'`savopts'); readstata13::save.dta13(as.data.frame(M[['est.att']]), 'temp_gsynth_att.dta'`savopts')"
			local hasSE = 1
		}
		else {
			local retcode = "readstata13::save.dta13(data.frame(Estimate = M[['att.avg']]), 'temp_gsynth_avg.dta'`savopts'); readstata13::save.dta13(as.data.frame(M[['beta']]), 'temp_gsynth_coef.dta'`savopts'); readstata13::save.dta13(data.frame(ATT = M[['att']]), 'temp_gsynth_att.dta'`savopts')"
		}
		* Limit to usable data
		preserve
		keep if `touse'
		if "`hold'" != "" {
			drop if missing(`hold')
			
			count if !inlist(`hold', 0, 1)
			if r(N) > 0 {
				display as error "hold() variable can only be 0 or 1"
				exit
			}
		}
		
		* Get variables out
		* Dependent var
		local Y = trim(word("`anything'", 1))
		local anything = trim(stritrim(subinstr("`anything'","`Y'","",1)))
		fvrevar `Y'
		local Y = trim("`r(varlist)'")
		
		local D = trim(word("`anything'", 1))
		local anything = trim(stritrim(subinstr("`anything'","`D'","",1)))
		fvrevar `D'
		local D = trim("`r(varlist)'")
		qui count if !inlist(`D', 0, 1) & !missing(`D') 
		if r(N) > 0 {
			display as error "Treatment variable must contain only 0 or 1 values, or be missing."
			exit
		}
		
		* Predictors
		fvrevar `anything'
		local X = trim("`r(varlist)'")
		local numinds = wordcount("`indvars'")
		
		
		foreach var of varlist `Y' `D' {
			drop if missing(`var')
		} 		
		
		* Get rid of value labels, they pass to R as strings
		label drop _all 
		
		
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		* Check that index has two variables
		local index = stritrim(strtrim("`index'"))
		if wordcount("`index'") != 2 {
			display as error "index() must contain two variables, one for an ID indicator and one for time"
		}

		* Make sure precedes ends with a code continue
		if substr(strtrim("`precedes'"),-1,1) != ";" & "`precedes'" != "" {
			local precedes = "`precedes'; "
		}
		* blank if missing, produce value otherwise
		foreach opt in r nlambda k nboots cov_ar cores tol seed alpha min_T0 {
			* Different default since -1 is valid answer
			local default = -1
			if "`opt'" == "min_T0" {
				local default = 5
			}
			if ``opt'' != `default' {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		* FALSE by default, but turn true
		foreach opt in em se normalize {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = TRUE,"
			}
		}
		* TRUE by default, but turn false
		foreach opt in no_parallel no_cv {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","no_","",1)
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = FALSE,"
			}
		}
		* List of string options to turn into a string vector
		if !inlist("`force'","","none","unit","time","two-way") {
			display as error "force() must be none, unit, time, or two-way."
			exit
		}
		if !inlist("`criterion'","","mspe","pc") {
			display as error "criterion() must be mspe or pc."
			exit
		}
		if !inlist("`estimator'","","ife","mc") {
			display as error "estimator() must be ife or mc."
			exit
		}
		if !inlist("`inference'","","parametric","nonparametric") {
			display as error "inference() must be parametric or nonparametric."
			exit
		}
		local weight = "`iweight'"
		
		foreach opt in X Y D index force cl criterion estimator inference weight {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* List of numeric options to turn into a numeric vector		
		foreach opt in lambda {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", ", ", .)
				local vec = "c(`vec')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* Process pure R code to turn @@ into $
		foreach opt in precedes {
			if "``opt''" != "" {
				local `opt' = subinstr("``opt''","@@","\"+ustrunescape("\u0024"),.)
			}
		}
				
		noisily rcall: dataset <- st.data(); ///
			`precedes' ///
			M <- gsynth(data=dataset,`Y' `D' `X' `index' ///
				`force' `cl' `r' `lambda' `nlambda' `CV' `criterion' ///
				`k' `EM' `estimator' `se' `nboots' `inference' ///
				`cov_ar' `no_parallel' `cores' `tol' ///
				`seed' `min_T0' `alpha' `normalize'); ///
			`retcode'
		
		* Get the Average ATT data
		use temp_gsynth_avg.dta, clear
		noi di "Average Treatment Effect on the Treated:"
		local count = 0
		foreach var of varlist * {
			if `count' == 0 {
				rename `var' EstType
				cap tostring EstType, replace
				replace EstType = "ATT.avg"
				local vartodrop = "EstType"
			}
			else {	
				local newname = subinstr("`var'","_","",.)
				rename `var' `newname'
			}
			local count = `count' + 1
		}
		noi list, noobs
		drop `vartodrop'
		mkmat *, matrix(att_avg)
		ereturn matrix att_avg = att_avg
				
		* Get the by-period ATT
		noi di ""
		noi di ""
		use temp_gsynth_att.dta, clear
		noi di "ATT by Period (including Pre-treatment Periods):"
		local count = 0
		foreach var of varlist * {
			if `count' == 0 {
				rename `var' Time
			}
			else {
				local newname = subinstr("`var'","_","",.)
				rename `var' `newname'
				local varend = "`newname'"
			}
			local count = `count' + 1
		}
		noi list, noobs
		
		if "`att_file_replace'" != "" {
			if !regex("`att_file_replace'", ".dta") {
				save "`att_file_replace'.dta", replace
			}
			else {
				save "`att_file_replace'", replace
			}
		}
		g Time_string = Time
		cap destring Time, replace
		if _rc > 0 {
			drop Time
			g Time = _n
			order Time
		}
		
		mkmat Time-`varend', matrix(att) rownames(Time_string)
		ereturn matrix att = att

		
		* Get the coefficients
		noi di ""
		noi di ""
		use temp_gsynth_coef.dta, clear
		cap rename V1 beta
		rename rownames Coef
		noi di "Coefficients for the Covariates:"
		local count = 0
		foreach var of varlist * {
			local newname = subinstr("`var'","_","",.)
			rename `var' `newname'
			if `count' == 1 {
				local varstart = "`newname'"
			}
			local varend = "`newname'"
			local count = `count' + 1
		}
		noi list, noobs
		
		mkmat `varstart'-`varend', matrix(coef) rownames(Coef)
		ereturn matrix coef = coef
		
		restore
		
		erase temp_gsynth_avg.dta
		erase temp_gsynth_att.dta
		erase temp_gsynth_coef.dta
	}	
	
end
