cap prog drop causal_forest
prog def causal_forest, rclass
	
	syntax anything [if] [in], [clearR] [replace] [seed(integer -1)] [pred(string)] [varreturn(string)] [return(string)] [varsend(varlist)] [precedesCF(string)] [followsCF(string)] [opts(string)]

	version 13

	marksample touse
	
	capture which rcall
	if _rc > 0 {
		display as error "The use of causal_forest requires the rcall package. Run MLRtimesetup first."
		exit 133
	}
	
	capture rcall_check grf>=1.0.0
	if _rc > 0 {
		display as error "causal_forest requires that the R package grf be installed. Run MLRtimesetup first."
		exit 133
	}
	
	if strpos("`varsend'",".") > 0 | strpos("`varsend'","#") {
		display as error "There is no support for i., c., ibn., L., F., or # in varsend() as their variable names change significantly in use, and it is not possible for you to predict what you'll need to call the actual variables by in opts(). Make these variables by hand."
		exit 184
	}
	
	if "`clearR'" == "clearR" {
		rcall clear
	}
	

	quietly {
		
		local dv = word("`anything'", 1)
		fvrevar `dv'
		local dv2 = trim("`r(varlist)'")
		local iv = word("`anything'", 2)
		fvrevar `iv'
		local iv2 = trim("`r(varlist)'")
		
		local indvars = "`anything'"
		local indvars = substr("`indvars'",strpos("`indvars'"," ")+1,.)
		local indvars = substr("`indvars'",strpos("`indvars'"," ")+1,.)	
		fvrevar `indvars'
		local indvars2 = trim("`r(varlist)'")
		local numinds = wordcount("`indvars2'")
		
		foreach var of varlist `dv2' `iv2' `indvars2' `varsend' {
			replace `touse' = 0 if missing(`var')
		} 
	
		preserve
		
		keep if `touse'
		
		* Get rid of value labels, they pass to R as strings
		label drop _all 
		
		keep `dv2' `iv2' `indvars2' `varsend'
		order `dv2' `iv2' `indvars2' `varsend'
		
		* R variable names can't start with _
		* but fvrevar gives us a lot of those!
		foreach var of varlist * {
			local newname = "`var'"
			if strpos("`newname'","_") == 1 {
				local newname = "X`newname'"
				rename `var' `newname'
			}
		}
		
		
		if "`opts'" != "" {
			local opts = ", `opts'"
		}
		
		* Build the R command in locals to avoid calling rcall too many times, each time brings up a console
		
		* Standard stuff
		local start = "library(grf); df <- st.data(); Y <- as.matrix(df[,1]); W <- as.matrix(df[,2]); X <- as.matrix(df[,3:(2+`numinds')])"
		
		* List of other variables to send:
		local vs = ""
		foreach v in `varsend' {
			local vs = "`vs'; `v' <- as.matrix(df[,'`v''])"
		}
				
		* Seed
		if "`seed'" != "-1" {
			local seedn = "; set.seed(`seed')"
		}
		
		* Our causal forest command
		local comm = "; CF <- causal_forest(X,Y,W`opts')"
		
		* Do we want predictions?
		if "`pred'" != "" {
			local prcode = "; pr_000001 <- as.matrix(predict(CF)\"+ustrunescape("\u0024")+"predictions)"
	
			cap confirm var `pred'
			if _rc == 0 & "`replace'" == "" {
				display as error "variable `pred' already defined."
				exit 110
			}
		}
		
		* List of functions to run / objects to return
		local objreturn = ""
		if "`return'" != "" {		
			local eatreturn = subinstr("`return' ;","<-","=",.)
			local return = "; `return'"
			local first = 1
			while strpos("`eatreturn'",";") > 0 | `first' == 1 {
				local name = trim(substr("`eatreturn'",1,strpos("`eatreturn'","=") - 1))
				local objreturn = trim("`objreturn' `name'")
				local eatreturn = substr("`eatreturn'",strpos("`eatreturn'",";")+1,.)
				
				local first = 0
			}
			
		}
		
		local varnameret = ""
		local matrixify = ""
		if "`varreturn'" != "" {
			local eatvarn = subinstr("`varreturn' ;","<-","=",.)
			local varreturn = "; `varreturn'"
		
			local first = 1
			while strpos("`eatvarn'",";") > 0 | `first' == 1 {
				local name = trim(substr("`eatvarn'",1,strpos("`eatvarn'","=") - 1))
				local varnameret = trim("`varnameret' `name'")
				local eatvarn = substr("`eatvarn'",strpos("`eatvarn'",";")+1,.)
				
				local matrixify = "`matrixify'; `name' <- as.matrix(`name')"
						
				cap confirm var `name'
				if _rc == 0 & "`replace'" == "" {
					display as error "variable `name' already defined."
					exit 110
				}
				
				local first = 0
			}
		}
		
		local clean = "; rm(df)"
		
		* Make R code usable
		local return = subinstr("`return'","@@","\"+ustrunescape("\u0024"),.)
		local varreturn = subinstr("`varreturn'","@@","\"+ustrunescape("\u0024"),.)
		if "`precedesCF'" != "" {
			local precedesCF = "; `precedesCF'"
			local precedesCF = subinstr("`precedesCF'","@@","\"+ustrunescape("\u0024"),.)
		}
		if "`followsCF'" != "" {
			local followsCF = "; `followsCF'"
			local followsCF = subinstr("`followsCF'","@@","\"+ustrunescape("\u0024"),.)
		}
	
		* Send data over, run causal forest, do whatever else necessary, and bring it back
		noisily rcall: `start'`vs'`seedn'`precedesCF'`comm'`followsCF'`prcode'`clean'`return'`varreturn'`matrixify'
				
		* For objects being returned in r(), do that
		if "`objreturn'" != "" {
			foreach x in `objreturn' {
				return local `x' = `r(`x')'
			}
		}	
		
		* and pred
		if "`pred'" != "" {		
			matrix `pred' = r(pr_000001)
			matrix list r(pr_000001)
		}
		
		* and other vars
		if "`varnameret'" != "" {
			foreach x in `varnameret' {
				matrix `x' = r(`x')
			}
		}
		
		restore
		
		* Organize data so that returning variables can be saved, even if not all obs were sent
		tempvar origorder
		g `origorder' = _n
		gsort -`touse' `origorder'
		
		
		count if `touse'
		local numshould = r(N)
		
		* Returning predictions
		if "`pred'" != "" {
			if "`replace'" == "replace" {
				cap drop `pred'
				cap drop `pred'1
			}
		
			svmat `pred'
			rename `pred'1 `pred'
			
			count if !missing(`pred')
			if r(N) != `numshould' {
				display as error "Warning: length of `pred' variable does not match number of observations in analysis. These may be true missings, or there may be an error."
				display as text ""
			}
		}
		
		* Returning other variables
		if "`varnameret'" != "" {
			foreach x in `varnameret' {
				if "`replace'" == "replace" {
					cap drop `x'
					cap drop `x'1
				}
			
				svmat `x'
				rename `x'1 `x'
				
				count if !missing(`x')
				if r(N) != `numshould' {
					display as error "Warning: length of `x' variable does not match number of observations in analysis. These may be true missings, or there may be an error."
					display as text ""
				}
			}
		}
		
		sort `origorder'
		
	}	
	
end