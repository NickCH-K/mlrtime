*! gsynth_plot v.2.1.0 Run a forest estimation in R's gsynth package. 09oct2021 by Nick CH-K
cap prog drop gsynth_plot
prog def gsynth_plot
	
	syntax, ///
	[saving(string) dim(string) savingopts(string) type(string) xlab(string) ylab(string) main(string) ///
	 xlim(string) ylim(string) legendOff raw(string) nfactors(integer -1) ///
	 id(string) axis_adjust no_theme_bw shade_post ///
	]

	version 15
	
	marksample touse
	
	* This check nicked from Jonathan Roth's staggered package
	capture findfile rcall.ado
	if _rc != 0 {
	 display as error "rcall package must be installed. Run MLRtimesetup."
	 error 198
	}
	
	* gsynth requires version 2.1+
	rcall_check, rversion(2.1)
	
	capture rcall: library(gsynth)
	if _rc != 0{
		display as error "Package (gsynth) is missing. Run MLRtimesetup."
		exit
	} 
	
	* Did you previously run a successful model?
	capture rcall: M
	if _rc != 0 {
		display as error "Cannot find the estimated model in the R session. Did you maybe clear the R session since running it?"
		exit
	}
	capture rcall: model_type <- class(M)[1]
	if !inlist(r(model_type), "gsynth") {
		local model_type = r(model_type)
		display as error "gsynth_plot only applies to a gsynth estimate. Your model is of the type `model_type'."
		exit
	}
	
	quietly {	
		**** CHECK OPTIONS AND PROCESS DEFAULTS
		* Process dimensions
		if "`dim'" != "" {
			if !inlist(wordcount("`dim'"),2,3) {
				display as error "dim() must have two entries for width and height, or three for width, height, and units."
				exit
			}
			local wd = word("`dim'",1)
			local ht = word("`dim'",2)
			local dims = ", width = `wd', height = `ht'"
			if wordcount("`dim'") == 3 {
				local un = word("`dim'",3)
				local dims = "`dims', units = '`un''"
			}
		}
		* Process filename
		if "`saving'" == "" {
			local filename = "gsynth_plot"
			local device = "png"
		}
		else {
			local filename = substr("`saving'",1,strrpos("`saving'",".")-1)
			local device = substr("`saving'",strrpos("`saving'",".")+1,.)
		}
		
		* blank if missing, produce value otherwise
		foreach opt in nfactors {
			if ``opt'' != -1 {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = ``opt'',"
			}
			else {
				local `opt' = ""
			}
		}
		* FALSE by default, but turn true
		foreach opt in legendOff axis_adjust {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = TRUE,"
			}
		}
		* TRUE by default, but turn false
		foreach opt in no_theme_bw {
			if "``opt''" != "" {
				local dots = subinstr("`opt'","no_","",1)
				local dots = subinstr("`opt'","_",".",.)
				local `opt' = "`dots' = FALSE,"
			}
		}
		
		* List of string options to turn into a string vector
		if !inlist("`type'","","gap","raw","counterfactual","ct","factors","loadings","missing") {
			display as error "type() must be gap, raw, counterfactual, ct, loadings, factors, or missing."
			exit
		}
		if !inlist("`raw'","","none","band","all") {
			display as error "raw() must be none, band, or all."
			exit
		}
		
		foreach opt in type xlab ylab main raw id {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", "', '", .)
				local vec = "c('`vec'')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* List of numeric options to turn into a numeric vector		
		foreach opt in xlim ylim {
			if !("``opt''" == "") {
				local dots = subinstr("`opt'","_",".",.)
				local vec = stritrim(strtrim("``opt''"))
				local vec = subinstr("`vec'", " ", ", ", .)
				local vec = "c(`vec')"
				local `opt' = "`dots' = `vec',"
			}
		}
		* Process pure R code to turn @@ into $
		foreach opt in savingopts {
			if "``opt''" != "" {
				local `opt' = subinstr("``opt''","@@","\"+ustrunescape("\u0024"),.)
			}
		}
				
				
		noisily rcall: `device'(filename = '`filename'.`device''`dims',`savingopts'); ///
			plot(M, `type' `xlab' `ylab' `main' ///
				`xlim' `ylim' `legendOff' `raw' `nfactors' ///
				`id' `axis_adjust' `no_theme_bw' `shade_post'); ///
			dev.off()
		
	}	
	
end
