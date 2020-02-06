cap prog drop causal_forest
prog def causal_forest, rclass
	
	syntax anything [if] [in], [clearR] [replace] [seed(integer -1)] [pred(string)] [predopts(string)] [varreturn(string)] [return(string)] [varsend(varlist)] [precedes(string)] [follows(string)] [opts(string)]

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
	
		* Store original order and data so the new variable can be merged in
		tempvar orig
		g `orig' = _n
		* This variable is taking a trip into R and so can't start with a _
		rename `orig' X`orig'
		
		tempfile origdata
		save `origdata', replace
		
		keep if `touse'
		
		* Get rid of value labels, they pass to R as strings
		label drop _all 
		
		keep X`orig' `dv2' `iv2' `indvars2' `varsend'
		order X`orig' `dv2' `iv2' `indvars2' `varsend'
		
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
		if "`predopts'" != "" {
			local predopts = ", `predopts'"
		}
		
		* Build the R command in locals to avoid calling rcall too many times, each time brings up a console
		
		* Standard stuff
		local start = "library(grf); df <- st.data(); orig <- df[,1]; Y <- as.matrix(df[,2]); W <- as.matrix(df[,3]); X <- as.matrix(df[,4:(3+`numinds')])"
		
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
		local dfreturn = ""
		if "`pred'" != "" {
			local dfreturn = "`pred' = predict(CF`predopts')@@predictions"
	
			cap confirm var `pred'
			if _rc == 0 & "`replace'" == "" {
				display as error "variable `pred' already defined."
				exit 110
			}
		}
		
		* List of functions to run / objects to return
		local objreturn = ""
		local returnclass = ""
		if "`return'" != "" {		
			local eatreturn = subinstr("`return' ;","<-","=",.)
			local return = "; `return'"
			local first = 1
			while strpos("`eatreturn'",";") > 0 | `first' == 1 {
				local name = trim(substr("`eatreturn'",1,strpos("`eatreturn'","=") - 1))
				local objreturn = trim("`objreturn' `name'")
				local returnclass = "`returnclass'; class_`name' <- class(`name')"
				local eatreturn = substr("`eatreturn'",strpos("`eatreturn'",";")+1,.)
				
				local first = 0
			}
			
		}
		
		local varnameret = ""
		if "`varreturn'" != "" {
			local eatvarn = subinstr("`varreturn' ;","<-","=",.)
			local varreturn = "; `varreturn'"
		
			local first = 1
			while strpos("`eatvarn'",";") > 0 | `first' == 1 {
				local name = trim(substr("`eatvarn'",1,strpos("`eatvarn'","=") - 1))
				local varnameret = trim("`varnameret' `name'")
				local eatvarn = substr("`eatvarn'",strpos("`eatvarn'",";")+1,.)
				
				local dfreturn = "`dfreturn', `name' = `name'"
						
				cap confirm var `name'
				if _rc == 0 & "`replace'" == "" {
					display as error "variable `name' already defined."
					exit 110
				}
				
				local first = 0
			}
		}
		
		* If we're sending variables back
		local mergeflag = 0
		if length("`dfreturn'") > 0 {
			local dfreturn = "; df2 <- data.frame(X`orig' = orig,`dfreturn'); st.load(df2)"
			local mergeflag = 1
		}
		
		local clean = "; rm(df); rm(X); rm(Y); rm(W)"
		
		* Make R code usable
		local return = subinstr("`return'","@@","\"+ustrunescape("\u0024"),.)
		local varreturn = subinstr("`varreturn'","@@","\"+ustrunescape("\u0024"),.)
		local dfreturn = subinstr("`dfreturn'","@@","\"+ustrunescape("\u0024"),.)
		if "`precedes'" != "" {
			local precedes = "; `precedes'"
			local precedes = subinstr("`precedes'","@@","\"+ustrunescape("\u0024"),.)
		}
		if "`follows'" != "" {
			local follows = "; `follows'"
			local follows = subinstr("`follows'","@@","\"+ustrunescape("\u0024"),.)
		}
	
		* Send data over, run causal forest, do whatever else necessary, and bring it back
		noisily rcall: `start'`vs'`seedn'`precedes'`comm'`follows'`prcode'`return'`returnclass'`varreturn'`dfreturn'`clean'
			
				
		* For objects being returned in r(), do that
		if "`objreturn'" != "" {
			foreach x in `objreturn' {
				if "`r(class_`x')'" == "matrix" {
					matrix `x' = r(`x')
				}
				else {
					return local `x' `r(`x')'
				}
			}
		}	
		
		* If we had any variables coming back, that means we've cleared the data and 
		* are now working only with those variables
		if `mergeflag' == 1 {
			merge 1:1 X`orig' using `origdata', nogen
			order `pred' `varnameret', last
			sort X`orig'
		}
		
		* We changed the name, so tempvar won't drop it any more
		drop X`orig'
	}	
	
end