*! grf_variable_importance v.2.1.0 Test the calibration of a forest in R's grf package. 09oct2021 by Nick CH-K
cap prog drop grf_variable_importance
prog def grf_variable_importance, eclass
	
	syntax, [decay_exponent(real -1) max_depth(integer -1) print_only]
	
	version 15
	
	* This check nicked from Jonathan Roth's staggered package
	capture findfile rcall.ado
	if _rc != 0 {
	 display as error "rcall package must be installed. Run mlrtimesetup."
	 error 198
	}
	
	* grf requires version 3.5+
	rcall_check, rversion(3.5)
	
	capture rcall: library(grf)
	if _rc != 0{
		display as error "Package (grf) is missing. Run mlrtimesetup."
		exit
	} 
	
	* Did you previously run a successful model?
	capture rcall: M
	if _rc != 0 {
		display as error "Cannot find the estimated forest in the R session. Did you maybe clear the R session since running it?"
		exit
	}

	quietly {
		
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		* blank if missing, produce value otherwise
		foreach opt in decay_exponent max_depth {
			if ``opt'' != -1 {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		
		if "`print_only'" == "print_only" {
			noi rcall: grf::variable_importance(M, `decay_exponent' `max_depth')
		}
			else {
			
			noi rcall: grf_vi <- as.vector(grf::variable_importance(M, `decay_exponent' `max_depth')[,1]); xnames <- colnames(X)

			* Turn into a matrix, and print a table while we're at it
			* How many predictors did we have
			local xnames = r(xnames)
			local numnames = 0
			foreach x in `xnames' {
				local numnames = `numnames' + 1
			}
			matrix table = J(`numnames',1,.)
			matrix rownames table = `xnames'
			
			noi di as smcl "{hline 13}{c TT}{hline 12}"
			noi di as smcl "    Variable {c |}Importance"
			noi di as smcl "{hline 13}{c +}{hline 12}"
			local count = 1
			foreach x in `xnames' {
				* Get values and fill in table
				local varshow: display %12s "`x'"
				local estval = word(r(grf_vi),`count')
				matrix table[`count',1] = `estval'
				local estshow: display %9.0g `estval'
				local count = `count' + 1
				
				* Write a row of the table
				noi di as smcl "`varshow' {c |} `estshow'"
			}
			noi di as smcl "{hline 13}{c BT}{hline 12}"
			
			
			ereturn matrix table = table
		}
	}		
end
