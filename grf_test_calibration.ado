*! grf_test_calibration v.2.1.0 Test the calibration of a forest in R's grf package. 09oct2021 by Nick CH-K
cap prog drop grf_test_calibration
prog def grf_test_calibration, eclass
	
	syntax, [vcov_type(string)]
	
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
		* blank if missing, extract from data otherwise
		* List of string options to turn into a string vector
		if (!inlist("`vcov_type'","","HC0","HC1","HC2","HC3")) {
			display as error "vcov_type(), if specified, must be HC0, HC1, HC2, or HC3."
			exit
		}
		local hcdisplay = "HC3"
		if "`vcov_type'" != "" {
			local hcdisplay = "`vcov_type'"
		}
		
		foreach opt in vcov_type {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`dots' = `vec',"
			}
		}
		
		noi rcall: grf_tc <- matrix(grf::test_calibration(M,`vcov_type'), nrow = 2)

		* ereturn pulls straight from the table
		matrix T = r(grf_tc)
		matrix b = T[1..2,1]
		matrix b = b'
		matrix se = T[1..2,2]
		matrix V = diag(se)

		forvalues r = 1(1)2 {
			forvalues c = 1(1)4 {
				local r`r'c`c': display %9.0g T[`r',`c']
			}
		}
			
		noi di "Best linear fit using forest predictions (on held-out data)"
		noi di "as well as the mean forest prediction as regressors, along"
		noi di "with one-sided heteroskedasticity-robust (`hcdisplay') SEs:"
		noi di ""
		noi di as smcl "{hline 31}{c TT}{hline 48}"
		noi di as smcl "{dup 31: }{c |}  Estimate   Std. Err.   {dup 8: }t   {dup 4: }P>|t|" 
		noi di as smcl "{hline 31}{c +}{hline 48}"
		noi di as smcl "{dup 8: }mean.forest.prediction {c |} `r1c1'   `r1c2'   `r1c3'   `r1c4'"
		noi di as smcl "differential.forest.prediction {c |} `r2c1'   `r2c2'   `r2c3'   `r2c4'"
		noi di as smcl "{hline 31}{c BT}{hline 48}"
		
		ereturn post b V
		}		
end
