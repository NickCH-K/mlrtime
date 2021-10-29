*! mlrtime v.2.1.0 Get introduced to the mlrtime package. 09oct2021 by Nick CH-K
cap prog drop mlrtime
prog def mlrtime

	display "It's mlrtime!"
	display "Please install R from R-Project.org and then run {help mlrtimesetup} before using the rest of the functions in the package."
	display ""
	display "Functions available include:"
	display "{help grf} to estimate generalized random forests, including causal forests, with R's grf package."
	display "{help gsynth} to estimate the generalized synthetic control method, including matrix completion, with R's gsynth package."
	display "{help parsnip} to fit a wide array of machine-learning algorithms through R's parsnip package."
	display ""
	display "Note: If you see a warning when R is running that a package was built on a different version of R,"
	display "that's okay. It's probably not an issue, and you can make it go away by updating your R installation."
	
end
