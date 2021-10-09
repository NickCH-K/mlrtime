cap prog drop causal_forest
prog def causal_forest, rclass
	
	syntax anything [if] [in], [clearR] [replace] [seed(integer -1)] [pred(string)] [predopts(string)] [varreturn(string)] [return(string)] [varsend(varlist)] [precedes(string)] [follows(string)] [opts(string)]
	
	display as smcl "The {cmd:causal_forest} function is deprecated. Use {cmd:grf} instead."
	
end
