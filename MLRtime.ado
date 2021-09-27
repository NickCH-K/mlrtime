*! MLRtime v.2.0.0 Get introduced to the MLRtime package. 23sep2021 by Nick CH-K
cap prog drop MLRtime
prog def MLRtime

	display "It's MLRtime!"
	display "Please install R from R-Project.org and run {help MLRtimesetup} before using the rest of the functions in the package."
	display ""
	display "Functions available include:"
	display "{help grf} to estimate generalized random forests, including causal forests, with R's grf package."
	display "{help gsynth} to estimate the generalized synthetic control method, including matrix completion, with R's gsynth package."
	
end
