*! grf_ate v.2.1.0 Estimate an average treatment effect in R's grf package. 09oct2021 by Nick CH-K
cap prog drop grf_ate
prog def grf_ate, rclass
	
	syntax, [target_sample(string) method(string) subset(string) debiasing_weights(string) compliance_score(string) num_trees_for_weights(integer -1)]
	
	version 15
	
	* This check nicked from Jonathan Roth's staggered package
	capture findfile rcall.ado
	if _rc != 0 {
	 display as error "rcall package must be installed. Run MLRtimesetup."
	 error 198
	}
	
	* grf requires version 3.5+
	rcall_check, rversion(3.5)
	
	capture rcall: library(grf)
	if _rc != 0{
		display as error "Package (grf) is missing. Run MLRtimesetup."
		exit
	} 
	
	* Did you previously run a successful model?
	capture rcall: M
	if _rc != 0 {
		display as error "Cannot find the estimated forest in the R session. Did you maybe clear the R session since running it?"
		exit
	}
	capture rcall: forest_type <- class(M)[1]
	if !inlist(r(forest_type), "causal_forest","instrumental_forest") {
		local forest_type = r(forest_type)
		display as error "grf_ate only applies to a causal forest or instrumental forest. Your forest is of the type `forest_type'."
		exit
	}
	

	quietly {
		
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		* blank if missing, extract from data otherwise
		foreach opt in subset debiasing_weights compliance_score {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","_",".",.)
				if ("`forest_type'" == "probability_forest" & "`opt'" == "Y") {
					local `opt' = "`dots' = factor(as.vector(holding[['``opt''']])),"
				}
				else {
					local `opt' = "`dots' = as.vector(holding[['``opt''']]),"
				}
			}
			else {
				local `opt' = ""
			}
		}
		if "`subset'" != "" {
			* Take out comma
			local subset = substr("`subset'",1,length("`subset'") - 1)
			local subset = "`subset' == 1,"
		}
		* blank if missing, produce value otherwise
		foreach opt in num_trees_for_weights {
			if ``opt'' != -1 {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		* List of string options to turn into a string vector
		if (!inlist("`target_sample'","","all","treated", "control", "overlap")) {
			display as error "target_sample(), if specified, must be all, treated, control, or overlap."
			exit
		}
		if (!inlist("`method'","","AIPW","TMLE")) {
			display as error "method(), if specified, must be AIPW or TMLE."
			exit
		}
		
		foreach opt in target_sample method {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`dots' = `vec',"
			}
		}
		
		noi rcall: grf_ate <- average_treatment_effect(M,`target_sample' `method' ///
			`subset' `debiasing_weights' `compliance_score' `num_trees_for_weights'); ///
			estimate <- grf_ate[1]; std.err <- grf_ate[2]; rm(grf_ate)

			
		local estshow: display %9.0g r(estimate)
		local seshow: display %9.0g r(std_err)
			
		noi di as smcl "{hline 13}{c TT}{hline 23}"
		noi di as smcl "{dup 4: }Estimate {c |} {dup 4: }Coef.   Std. Err." 
		noi di as smcl "{hline 13}{c +}{hline 23}"
		noi di as smcl "{dup 9: }ATE {c |} `estshow'   `seshow'" 
		noi di as smcl "{hline 13}{c BT}{hline 23}"
		
		return add
		}		
end
