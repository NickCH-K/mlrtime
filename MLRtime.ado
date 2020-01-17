cap prog drop MLRtime
prog def MLRtime

	display "Welcome to MLRtime!"
	display "Please install R from R-Project.org and run {help MLRtimesetup} before using the rest of the functions in the package."
	display ""
	display "Functions available include:"
	display "{help causal_forest} to estimate causal forests with R's grf package."
	display "{help ranger} to estimate random forests with R's ranger package."
	
end