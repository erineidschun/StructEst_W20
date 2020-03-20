clear
clear mata
clear matrix

mata:
void GMM_DLW(todo,betas,crit,g,H) 
{
	PHI=st_data(.,("phi")) 
    PHI_LAG=st_data(.,("phi_lag"))
    Z=st_data(.,("l_lag","k"))
    X=st_data(.,("l","k"))
    X_lag=st_data(.,("l_lag","k_lag"))
    Y=st_data(.,("y"))
	C=st_data(.,("const"))
    
	OMEGA=PHI-X*betas' 
	OMEGA_lag=PHI_LAG-X_lag*betas'
	
    OMEGA_lag_pol= (OMEGA_lag,C)
	g_b = invsym(OMEGA_lag_pol'OMEGA_lag_pol)*OMEGA_lag_pol'OMEGA
	XI=OMEGA-OMEGA_lag_pol*g_b
	crit=(Z'XI)'(Z'XI) //GMM
}

void DLW()
	{
initialvalue=st_data(1,("initiall","initialk"))
//These functions find parameter vector or scalar p such that function f(p) is a maximum or a minimum
S=optimize_init() //begins the definition of a problem and returns S, aproblem-description handle
//set to contain default values.
optimize_init_evaluator(S, &GMM_DLW())
optimize_init_evaluatortype(S,"d0")
optimize_init_technique(S, "nm")
optimize_init_nmsimplexdeltas(S, 0.01)
C = (1,1)
c = (1)
Cc = (C, c)
optimize_init_constraints(S, Cc)
optimize_init_which(S,"min")
optimize_init_params(S,initialvalue) 
optimize_init_conv_maxiter(S, 90) 

p=optimize(S) //perform opt. returns real rowvector p containing the
//values of the parameters that produce a maximum or minimum. should return S and initial vlaue
f=optimize_result_value(S) //optimize result value(S) returns the value of f()
//evaluated at p equal to optimize result params()
p 
f 
st_matrix("beta_dlw",(p,f)) //name of matrix is beta_dlw, with values p and f
    } 
end

capture program drop dlw	
program dlw, rclass
preserve 
sort id t
mata DLW() //mata is something that makes this run fast(?)
end


