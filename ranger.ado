cap prog drop ranger
prog def ranger, rclass
	
	syntax anything [if] [in], [clearR] [replace] [seed(integer -1)] [pred(string)] [predopts(string)] [varreturn(string)] [return(string)] [varsend(varlist)] [precedes(string)] [follows(string)] [opts(string)]

	display as smcl "The {cmd:ranger} function is deprecated. Use {cmd:parsnip} instead."
	
end