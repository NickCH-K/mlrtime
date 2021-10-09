*! grf v.2.1.0 Run a forest estimation in R's grf package. 09oct2021 by Nick CH-K
cap prog drop grf
prog def grf
	
	syntax anything [if] [in] [iweight], forest_type(string) ///
	[clearR seed(integer -1) replace  /// Base options
	hold(varname) pred(string) se(string) id(varname) /// Stata variables
	otheropts(string) predopts(string) precedes(string) /// Customization
	w(varname) y_hat(varname) w_hat(varname)  num_trees(integer -1) /// causal_forest and shared options
	clusters(varname) equalize_cluster_weights sample_fraction(real -1) ///
	mtry(integer -1) min_node_size(integer -1) no_honesty honesty_fraction(real -1) ///
	no_honesty_prune_leaves alpha(real -1) imbalance_penalty(real -1) no_stabilize_splits ///
	ci_group_size(integer -1) tune_parameters(string) tune_num_trees(integer -1) ///
	tune_num_reps(integer -1) tune_num_draws(integer -1) no_compute_oob_predictions num_threads(integer -1) ///
	z(varname) z_hat(varname) reduced_form_weight(real -1) /// instrumental_forest options
	enable_ll_split ll_split_weight_penalty ll_split_lambda(real -1) /// ll_regression_forest options
	ll_split_variables(varlist) ll_split_cutoff(real -1) ///
	quantiles(string) quantiles_predict(string) regression_splitting /// quantile_forest options
	d(varname) failure_times(string) failure_times_predict(string) prediction_type(string) /// survival_forest options
	]
	
	version 15
	
	marksample touse
	
	* c'mon Stata
	local W = "`w'"
	local Y_hat = "`y_hat'"
	local W_hat = "`w_hat'"
	local Z = "`z'"
	local Z_hat = "`z_hat'"
	local D = "`d'"
	
	* This check nicked from Jonathan Roth's staggered package
	capture findfile rcall.ado
	if _rc != 0 {
	 display as error "rcall package must be installed. Run MLRtimesetup."
	 error 198
	}
	
	* grf requires version 3.5+
	rcall_check, rversion(3.5)
		
	if "`clearR'" == "clearR" {
		rcall clear
	}
	
	capture rcall: library(grf)
	if _rc != 0{
		display as error "Package (grf) is missing. Run MLRtimesetup."
		exit
	} 
	
	* Prepare for later results merging
	if "`id'" == "" {
		capture confirm variable grf_merge_id
		if _rc == 0 {
			local id = "grf_merge_id"
		}
		else {
			if "`replace'" == "replace" {
				cap drop grf_merge_id
			}
			g grf_merge_id = _n
			local id = "grf_merge_id"
		}
	}
	qui duplicates report `id'
	if !(r(unique_value) == _N) {
		display as error "id() variable must uniquely identify rows."
		exit
	}

	quietly {
		**** PREPARE VARIABLES
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
		
		* Must be categorical for probability_forest
		if ("`forest_type'" == "probability_forest") {
			qui count if `Y' < 0
			if r(N) > 0 {
				display as error "For forest_type(probability_forest), {help depvar} must be a nonnegative integer."
			}
			qui count if round(`Y') != `Y'
			if r(N) > 0 {
				display as error "For forest_type(probability_forest), {help depvar} must be a nonnegative integer."
			}
		}
		
		* Predictors
		fvrevar `anything'
		local indvars = trim("`r(varlist)'")
		local numinds = wordcount("`indvars'")
		
		foreach var of varlist `Y' `indvars' {
			drop if missing(`var')
		} 
		
		* Optional specified variables
		foreach optv in iweight W Y_hat W_hat Z Z_hat clusters D {
			if "``optv''" != "" {
				drop if missing(``optv'')
				
				if "`optv'" == "D" {
					qui count if !inlist(`D', 0, 1) 
					if r(N) > 0 {
						display as error "d() must contain only 0 or 1 values."
						exit
					}
				}
				
				fvrevar ``optv''
				local `optv' = trim("`r(varlist)'")
			}	
		}
		
		* Get rid of value labels, they pass to R as strings
		label drop _all 
		
		* Put the independent variables first so they can be easily extracted as a matrix
		order `indvars'
		
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		if (!inlist("`forest_type'","causal_forest","instrumental_forest","ll_regression_forest", ///
			"multi_regression_forest","probability_forest","quantile_forest","regression_forest", ///
			"survival_forest")) {
			display as error "forest_type() entry not supported. Must be: causal_forest, instrumental_forest,"
			display as error "ll_regression_forest, multi_regression_forest, probability_forest,"
			display as error "quantile_forest, regression_forest, or survival_forest."
			exit
		}
		if ("`equalize_cluster_weights'" == "equalize_cluster_weights" & "`iweight'" != "") {
			display as error "equalize_cluster_weights cannot be combined with sample weights."
			exit
		}
		* hold
		if ("`hold'" == "") {
			local hold = "training <- dataset; holding <- dataset;"
			display as error "hold() has not been specified."
			display as error "All observations will be used for estimation and prediction."
			display as error "This will often lead to overfitting."
		}
		else {
			local hold = "training <- dataset[dataset[['`hold'']] == 0,]; holding <- dataset[dataset[['`hold'']] == 1,]; "
		}
		* seed
		if (`seed' != -1) {
			local setseed = "set.seed(`seed') ;"
		}
		else {
			local setseed = ""
		}
		if substr(strtrim("`precedes'"),-1,1) != ";" & "`precedes'" != "" {
			local precedes = "`precedes'; "
		}
		* blank if missing, extract from data otherwise
		local sample_weights = "`iweight'"
		foreach opt in sample_weights Y W Z Y_hat W_hat Z_hat clusters D {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","_",".",.)
				if ("`forest_type'" == "probability_forest" & "`opt'" == "Y") {
					local `opt' = "`dots' = factor(as.vector(training[['``opt''']])),"
				}
				else {
					local `opt' = "`dots' = as.vector(training[['``opt''']]),"
				}
			}
			else {
				local `opt' = ""
			}
		}
		* blank if missing, produce value otherwise
		foreach opt in num_trees sample_fraction mtry min_node_size honesty_fraction alpha ///
			imbalance_penalty ci_group_size tune_num_trees tune_num_reps tune_num_draws num_threads seed ///
			reduced_form_weight ll_split_lambda ll_split_cutoff {
			if ``opt'' != -1 {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		* FALSE by default, but turn true
		foreach opt in equalize_cluster_weights enable_ll_split ll_split_weight_penalty ///
			regression_splitting {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = TRUE,"
			}
		}
		* TRUE by default, but turn false
		foreach opt in no_honesty no_honesty_prune_leaves no_stabilize_splits no_compute_oob_predictions {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","no_","",1)
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = FALSE,"
			}
		}
		* List of string options to turn into a string vector
		if !inlist("`prediction_type'","","Kaplan-Meier", "Nelson-Aalen") {
			display as error "prediction_type must be Kaplan-Meier or Nelson-Aalen."
			exit
		}
		
		foreach opt in tune_parameters ll_split_variables prediction_type {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* List of numeric options to turn into a numeric vector		
		foreach opt in quantiles quantiles_predict failure_times failure_times_predict {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", ", ", .)
				local vec = "c(`vec')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* Process pure R code to turn @@ into $
		foreach opt in precedes predopts otheropts secode {
			if "``opt''" != "" {
				local `opt' = subinstr("``opt''","@@","\"+ustrunescape("\u0024"),.)
			}
		}
		* do pred and se last to wait until predopts is processed
		* pred
		if ("`pred'" == "") {
			local pred = "predicted"
		}
		cap confirm var `pred'
		if _rc == 0 & "`replace'" == "" {
			display as error "Variable `pred' already defined, and replace is not specified."
			exit
		}
		local predcode = "`pred' <- data.frame(`pred' = as.vector(predict(M,newdata=holdingX,`predopts')[['predictions']])); "
		if (inlist("`forest_type'","probability_forest","quantile_forest","survival_forest")) {
			if "`replace'" == "" {
				display as error "probability_forest, quantile_forest, and survival_forest require replace to avoid confusion."
				exit
			}
		
			local predcode = "`pred' <- data.frame(predict(M,newdata=holdingX,`quantiles_predict'`failure_times_predict'`predopts')[['predictions']], check.names = FALSE); names(`pred') <- paste0('`pred'',names(`pred'));"
		}
		* se
		local secode = ""
		local secbind = ""
		if ("`se'" != "") {
			if (inlist("`forest_type'","multi_regression_forest","quantile_forest","survival_forest")) {
				display as error "se() not supported for multi_regression_forest, quantile_forest, or survival_forest."
				exit
			}
		
			cap confirm var `se'
			if _rc == 0 & "`replace'" == "" {
				display as error "Variable `se' already defined, and replace is not specified."
				exit
			}
			local secode = "`se' <- data.frame(`se' = sqrt(as.vector(predict(M, newdata = holdingX, estimate.variance = TRUE,`predopts')[['variance.estimates']])));"
			if ("`forest_type'" == "probability_forest") {
				if "`replace'" == "" {
					display as error "probability_forest requires replace to avoid confusion."
				}
				local secode = "`se' <- data.frame(predict(M,newdata=holdingX, estimate.variance=TRUE,`predopts')[['variance.estimates']], check.names = FALSE); names(`se') <- paste0('`se'',names(`se'));"
				local secbind = "returndat <- cbind(returndat, `se'); "
			}
			else {
				local secbind = "returndat <- cbind(returndat, `se');"
			}
		}
		
		* Necessary options for different forest types
		if "`W'" == "" {
			if inlist("`forest_type'","causal_forest","instrumental_forest") {
				display as error "For causal_forest or instrumental_forest, the w() option must be specified."
				exit
			}
		} 
		else {
			if !inlist("`forest_type'","causal_forest","instrumental_forest") {
				display as error "The w() option can only be specified with causal_forest or instrumental_forest."
				exit
			}
		}
		if "`Z'" == "" {
			if inlist("`forest_type'","instrumental_forest") {
				display as error "For instrumental_forest, the z() option must be specified."
				exit
			}
		} 
		else {
			if !inlist("`forest_type'","instrumental_forest") {
				display as error "The z() option can only be specified for instrumental_forest."
				exit
			}
		}
		
		noisily rcall: dataset <- st.data(); ///
			`hold' ///
			X <- as.matrix(training[, 1:`numinds']); ///
			holdingX <- as.matrix(holding[, 1:`numinds']); ///
			`setseed' ///
			`precedes' ///
			M <- `forest_type'(X=X, `Y' `W' `Z' `Y_hat' `W_hat' `Z_hat' `D' `sample_weights' `clusters' ///
						`num_trees' `sample_fraction' `mtry' `min_node_size' `honesty_fraction' ///
						`alpha' `imbalance_penalty' `ci_group_size' `tune_num_trees' `tune_num_reps' ///
						`tune_num_draws' `num_threads' `seed' `equalize_cluster_weights' ///
						`no_honesty' `no_honesty_prune_leaves' `no_stabilize_splits' `no_compute_oob_predictions' ///
						`tune_parameters' `reduced_form_weight' ///
						`enable_ll_split' `ll_split_weight_penalty' `ll_split_lambda' /// 
						`ll_split_variables' `ll_split_cutoff' ///
						`regression_splitting' `quantiles' ///
						`failure_times' `prediction_type'); ///
			`predcode' ///
			`secode' ///
			returndat <- cbind(data.frame(`id'=holding[['`id'']]), `pred'); ///
			`secbind' ///
			readstata13::save.dta13(returndat, 'temp_grf_merge.dta')
		
		restore
		
		if "`replace'" == "replace" {
			if (inlist("`forest_type'","probability_forest","quantile_forest","survival_forest")) {
				cap drop `pred'*
			}
			else {
				cap drop `pred'
			}
			cap drop `se'
		}
		
		merge 1:1 `id' using temp_grf_merge.dta, nogen
		erase temp_grf_merge.dta
	}	
	
end
