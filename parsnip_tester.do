sysuse auto.dta, clear
g model = word(make, 1)
encode model, g(modeln)
g hold = runiform() > .5
g binaryout = runiform() > .5
tostring binaryout, replace
g multinomout = floor(runiform()*4)
tostring multinomout, replace

cap prog drop tester
prog def tester
	syntax anything, [results] dv(string)
	
	if "`results'" == "results" {
		preserve
		parsnip `dv' mpg headroom trunk, `anything' hold(hold) clearR results(replace)
		list *
		restore
	}
	else {
		parsnip `dv' mpg headroom trunk, `anything' hold(hold) clearR replace pred(predict)
		summ predict
	}
	
end


* Models running and returning predictions
tester model(linear_reg), dv(price)
tester model(linear_reg) engine(glmnet) penalty(.5), dv(price)
*tester model(linear_reg) engine(keras) penalty(.5), dv(price)
tester model(linear_reg) engine(stan) penalty(.5), dv(price)
tester model(logistic_reg), dv(binaryout)
tester model(logistic_reg) engine(glmnet) penalty(.5), dv(binaryout)
tester model(logistic_reg) engine(LiblineaR) penalty(.5), dv(binaryout)
tester model(multinom_reg), dv(multinomout)
tester model(multinom_reg) engine(glmnet) penalty(.5), dv(multinomout)
tester model(boost_tree) mode(regression), dv(price)
tester model(boost_tree) mode(classification), dv(multinomout)
tester model(boost_tree) mode(classification) engine(C5.0), dv(multinomout)
tester model(gen_additive_mod) mode(regression), dv(price)
parsnip binaryout mpg headroom trunk, model(gen_additive_mod) mode(classification) clearR pred(none)
tester model(mars) mode(regression), dv(price)
tester model(mars) mode(classification), dv(multinomout)
tester model(mlp) mode(regression), dv(price)
tester model(mlp) mode(classification), dv(multinomout)
tester model(nearest_neighbor) mode(regression), dv(price)
tester model(nearest_neighbor) mode(classification), dv(multinomout)
tester model(rand_forest) mode(regression), dv(price)
tester model(rand_forest) mode(classification), dv(multinomout)
tester model(rand_forest) mode(regression) engine(randomForest), dv(price)
tester model(rand_forest) mode(classification) engine(randomForest), dv(multinomout)
tester model(svm_linear) mode(regression), dv(price)
tester model(svm_linear) mode(regression) engine(kernlab), dv(price)
tester model(svm_linear) mode(classification), dv(multinomout)
tester model(svm_linear) mode(classification) engine(kernlab), dv(multinomout)
tester model(svm_linear) mode(regression), dv(price)
tester model(svm_linear) mode(classification), dv(multinomout)
tester model(svm_rbf) mode(regression), dv(price)
tester model(svm_rbf) mode(classification), dv(multinomout)

* Models running and returning results
tester model(linear_reg), results dv(price)
tester model(linear_reg) engine(glmnet) penalty(.5), results dv(price)
*tester model(linear_reg) engine(keras) penalty(.5), results dv(price)
tester model(linear_reg) engine(stan) penalty(.5), results dv(price)
tester model(logistic_reg), dv(binaryout) results
tester model(logistic_reg) engine(glmnet) penalty(.5), dv(binaryout) results
tester model(logistic_reg) engine(LiblineaR) penalty(.5), dv(binaryout) results
* NOT VALID tester model(multinom_reg), dv(multinomout) results
tester model(multinom_reg) engine(glmnet) penalty(.5), dv(multinomout) results
* tester model(boost_tree) mode(regression), dv(price) results
* tester model(boost_tree) mode(classification), dv(multinomout) results
* tester model(boost_tree) mode(classification) engine(C5.0), dv(multinomout) results
* tester model(gen_additive_mod) mode(regression), dv(price) results
* tester model(mars) mode(regression), dv(price) results
* tester model(mars) mode(classification), dv(multinomout) results
* tester model(mlp) mode(regression), dv(price) results
* tester model(mlp) mode(classification), dv(multinomout) results
* tester model(nearest_neighbor) mode(regression), dv(price) results
* tester model(nearest_neighbor) mode(classification), dv(multinomout) results
tester model(svm_linear) mode(regression), dv(price) results
tester model(svm_linear) mode(classification), dv(multinomout) results
tester model(svm_linear) mode(regression), dv(price) results
tester model(svm_linear) mode(classification), dv(multinomout) results


