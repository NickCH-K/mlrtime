*! parsnip v.2.1.0 Estimate a machine learning model using the R parsnip package. 09oct2021 by Nick CH-K
cap prog drop parsnip
prog def parsnip
	
	syntax anything [if] [in] [iweight], model(string) ///
	[clearR seed(integer -1) replace  /// Base options
	hold(varname) pred(string) id(varname) results(string) /// Stata variables
	otheropts(string) predopts(string) precedes(string) predformula(string) /// Customization
	engine(string) mode(string) /// Shared options
	mtry(real -1) trees(integer -1) min_n(integer -1) tree_depth(integer -1) /// boost_tree and rand_forest options
	learn_rate(real -1) loss_reduction(real -1) sample_size(real -1) stop_iter(integer -1) ///
	select_features adjust_deg_free(real -1) /// GAM options
	penalty(real -1) mixture(real -1) /// linear / logistic / multinom reg options
	num_terms(integer -1) prod_degree(integer -1) prune_method(string) /// mars options
	hidden_units(integer -1) dropout(real -1) epochs(integer -1) activation(string) /// mlp options
	neighbors(integer -1) weight_func(string) dist_power(real -1) /// nearest_neighbor options
	cost(real -1) margin(real -1) scale_factor(real -1) rbf_sigma(real -1) /// svm options
	]
	
	version 15
	
	marksample touse
		
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
	
	capture rcall: library(parsnip)
	if _rc != 0{
		display as error "Package (parsnip) is missing. Run MLRtimesetup."
		exit
	} 
	
	* Incompatible settings
	if "`mode'" == "" {
		if inlist("`model'", "boost_tree","gen_additive_mod","mars","mlp","nearest_neighbor","rand_forest","svm_linear","svm_poly","svm_rbf") {
			display as error "model(`model') requires a mode() setting."
			exit
		}
	}
	if "`mode'" != "classification" & "`engine'" == "C5.0" & "`model'" == "boost_tree" {
		display as error "engine(C5.0) only works with mode(classification). Try engine(xgboost)."
		exit
	}
	if "`engine'" == "glmnet" & inlist("`model'","linear_reg","logistic_reg","multinom_reg") & `penalty' == -1 {
		display as error "engine(glmnet) requires a penalty() setting."
	}
	if "`results'" != "" {
		if inlist("`engine'", "nnet", "kernlab") | inlist("`model'","boost_tree","gen_additive_mod","mars","mlp","nearest_neighbor","rand_forest","svm_rbf") {
			display as error "This model() and/or engine() does not produce a usable table of coefficients,"
			display as error "(or at least does not have a working tidy() implementation)"
			display as error "and so is not compatible with results(). Specify pred() instead to get predicted values."
			exit
		}
	}

	* Prepare for later results merging
	if "`id'" == "" {
		capture confirm variable parsnip_merge_id
		if _rc == 0 {
			local id = "parsnip_merge_id"
		}
		else {
			if "`replace'" == "replace" {
				cap drop parsnip_merge_id
			}
			g parsnip_merge_id = _n
			local id = "parsnip_merge_id"
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
		
		* Make a valid R name
		if substr("`Y'",1,1) == "_" {
			local newname = "V`Y'"
			rename `Y' `newname'
			local Y = "`newname'"
		}
				
		* Predictors
		fvrevar `anything'
		local indvars = trim("`r(varlist)'")
		local numinds = wordcount("`indvars'")
		
		foreach var of varlist `Y' `indvars' {
			drop if missing(`var')
		} 
		
		* Put the independent variables first so they can be easily extracted as a matrix
		* Irrelevant now since we use a formula, but in case it's necessary later
		* order `indvars'
		
		* construct the formula
		* Use fit() instead of fit_xy() because some engines won't allow fit_xy()
		if "`predformula'" == "" {	
			local predformula = "`Y'~"
			local pluschar = ""
			foreach var of varlist `indvars' {
				* Make a valid R name
				local newname = "`var'"
				if substr("`var'",1,1) == "_" {
					local newname = "V`var'"
					rename `var' `newname'
				}
			
				local predformula = "`predformula'`pluschar'`newname'"
				local pluschar = " + "
			}
		}
				
		* Get rid of value labels, they pass to R as strings
		label drop _all 
		
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		if "`engine'" == "" & "`otheropts'" != "" {
			display as error "engine() is not specified, so otheropts() will be ignored."
		}
		if (!inlist("`model'","boost_tree", "gen_additive_mod", "linear_reg", "logistic_reg", "mars", "mlp", "multinom_reg", "nearest_neighbor") & ///
			!inlist("`model'","rand_forest", "svm_linear", "svm_poly", "svm_rbf")) {
			display as error "model() entry not supported. Must be: boost_tree, gen_additive_mod, "
			display as error "linear_reg, logistic_reg, mars, mlp, multinom_reg, nearest_neighbor, "
			display as error "rand_forest, svm_linear, svm_poly, or svm_rbf."
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
		* Convert the dependent variable to a factor if necessary!
		local depconvert = "if (is.character(dataset[['`Y'']])) { dataset[['`Y'']] = as.factor(dataset[['`Y'']]) };"
				
		* blank if missing, produce value otherwise
		foreach opt in mtry trees min_n learn_rate loss_reduction sample_size stop_iter ///
			adjust_deg_free penalty mixture num_terms prod_degree hidden_units dropout epochs ///
			neighbors dist_power cost margin scale_factor rbf_sigma {
			if ``opt'' != -1 {
				local `opt' = "`opt' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		
		* FALSE by default, but turn true
		foreach opt in select_features {
			if "``opt''" != "" {
				local `opt' = "`opt' = TRUE,"
			}
		}
		* List of string options to turn into a string vector
		if !inlist("`mode'","","unknown","regression","classification") {
			display as error "mode must be unknown, regression, or classification."
			exit
		}
		if !inlist("`prune_method'","","backward", "none", "exhaustive", "forward", "seqrep", "cv") {
			display as error "prune_method must be none, backward, exhaustive, forward, seqrep, or cv."
			exit
		}
		if !inlist("`activation'","","linear", "softmax", "relu", "elu") {
			display as error "activation must be linear, softmax, relu, or elu."
			exit
		}
		if !inlist("`weight_func'","","rectangular", "triangular", "epanechnikov", "biweight", "triweight") & ///
			!inlist("`weight_func'", "cos", "inv", "gaussian", "rank", "optimal") {
			display as error "weight_func must be rectangular, triangular, epanechnikov, biweight,"
			display as error "triweight, cos, inv, gaussian, rank, or optimal."
			exit
		}
		
		foreach opt in mode prune_method activation weight_func {
			if !("``opt''" == "") {
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`opt' = `vec',"
			}
		}
		* Process pure R code to turn @@ into $
		foreach opt in precedes predopts otheropts {
			if "``opt''" != "" {
				local `opt' = subinstr("``opt''","@@","\"+ustrunescape("\u0024"),.)
			}
		}
		* If engine is not specified, go to default and skip set_engine
		if "`engine'" == "" {
			local setengine = ""
		}
		else {
			local setengine = "set_engine('`engine'',`otheropts') %>%"
		}
		* Deal with the results
		local resultscode = ""
		local norestore = ""
		if "`results'" == "replace" {
			local resultscode = "readstata13::save.dta13(tidy(M), 'temp_parsnip_results.dta');"
			local norestore = ", not"
		}
		if !inlist("`results'","","replace") {
			if lower(substr("`results'",-4,.)) == ".csv" {
				* This is the only data.table call in the whole package! But we use it here
				* because write_csv fills in missing values with a string, which confuses Stata when loaded back in
				local resultscode = "data.table::fwrite(tidy(M), '`results'');"
			}
			else {
				if !(lower(substr("`results'",-4,.)) == ".dta") {
					local results = "`results'.dta"
				}
				local resultscode = "readstata13::save.dta13(tidy(M), '`results'');"
			}
		}
		* do pred and se last to wait until predopts is processed
		* pred
		if ("`pred'" == "") {
			local pred = "predicted"
		}
		if "`pred'" != "none" & "`results'" != "replace" {
			cap confirm var `pred'
			if _rc == 0 & "`replace'" == "" {
				display as error "Variable `pred', your pred() option, is already defined, and replace is not specified."
				exit
			}
			local predcode = "preddata <- cbind(data.frame(`id' = holding[['`id'']]),as.data.frame(predict(M,holding,`predopts'))); names(preddata) <- c('`id'', ifelse(ncol(preddata) == 2, '`pred'',paste0('`pred'',1:ncol(preddata)))); readstata13::save.dta13(preddata, 'temp_parsnip_merge.dta');"
		} 
		else {
			local predcode = ""
		}
		local loadearth = ""
		if "`model'" == "mars" & inlist("`engine'","","earth") {
			local loadearth = "library(earth); "
		}
		
		noisily rcall: library(parsnip); library(broom); library(broom.mixed); `loadearth' dataset <- st.data(); ///
			`depconvert' ///
			`hold' ///
			`setseed' ///
			`precedes' ///
			M <- `model'(`mtry' `trees' `min_n' `learn_rate' `loss_reduction' `sample_size' `stop_iter' ///
			`adjust_deg_free' `penalty' `mixture' `num_terms' `prod_degree' `hidden_units' `dropout' `epochs' ///
			`neighbors' `dist_power' `cost' `margin' `scale_factor' `rbf_sigma' `select_features' ///
			`mode' `prune_method' `activation' `weight_func') %>% ///
			    `setengine' ///
				fit(`predformula', data = training); ///
			`resultscode' ///
			`predcode'
		
		noisily rcall: print(M)
		
		restore `norestore'
		
		if "`norestore'" == "" {
			if "`pred'" != "none" {
				if "`replace'" == "replace" {
					* Go through this rigamarole because we may be producing more than one column of predictions
					preserve
					use temp_parsnip_merge.dta, clear
					local todrop = ""
					local idfirst = 1
					foreach var of varlist * {
						if `idfirst' == 0 {
							local todrop = "`todrop' `var'"
						}
						local idfirst = 0
					}
					restore
					cap drop `todrop'
				}
				merge 1:1 `id' using temp_parsnip_merge.dta, nogen
			}
		}
		else {
			use temp_parsnip_results.dta, clear
		}
		cap erase temp_parsnip_merge.dta
		cap erase temp_parsnip_results.dta

	}	
	
end
