#' Fit nested partially latent class models (low-level)
#'
#' Uses WinBUGS in Windows system for Bayesian inference
#' (see README file for an instruction to install WinBUGS on windows 7 or 8.).
#' For stratification/regression functionalities, true positive rates are constant
#' across stratum or covariate values.\cr
#' Developer Note (DN):\cr
#' \itemize{
#' \item need to add checking empty cell functionality when performing
#'          stratification
#' \item need to use formula \code{cbind(Y1, Y2)~X1+X2} kind of symbolic
#'  model specification
#' to enable model estimation.
#' \item need to add ppd regression functionality
#'}
#'
#' @param Mobs A list of measurements. The elements of the list
#' should include \code{MBS}, \code{MSS}, and \code{MGS}.
#' \itemize{
#' \item \code{MBS} is a data frame of bronze-standard (BrS) measurements.
#' Rows are subjects, columns are pathogens targeted in the BrS measurements
#' (e.g. nasalpharyngeal PCR). These mesaurements have imperfect sensitivity/specificty.
#' \item \code{MSS} is a data frame of silver-standard (SS) measurements. Rows are subjects,
#'   columns are pathogens targeted in the SS measurements (e.g. blood culture).
#'   These measurements have perfect specificity but imperfect sensitivity.
#' \item \code{MGS} is a data frame of gold-standard (GS) measurements. Rows are subject,
#' columns are pathogens targeted in the GS measurements. These measurements
#' have both perfect sensitivity and perfect specificity.
#' }
#'
#' @param Y A vector of binary variables specifying the disease status (1 for case;
#' 0 for control).
#' @param X A design matrix. For FPR and etiology regressions.
#' @param model_options A list of model options.
#'
#' \itemize{
#' \item \code{M_use} List of measurements to be used in the model;
#' \item \code{k_subclass}The number of nested subclasses. It equals 1 if the
#' model is plcm; its value will be useful if the model is nplcm.
#' \item \code{TPR_prior} the prior for the measurements used. Its length should be
#' the same with \code{M_use};
#' \item \code{Eti_prior} the vector of parameters in etiology prior;
#' \item \code{pathogen_BrS_list} The vector of pathogen names with BrS measure;
#' \item \code{cause_list} The vector of causes, singleton, combinations, or 'NoA';
#' \item \code{X_reg_FPR} The vector of covariate names that stratify/regress
#' false positive rates (FPR);
#' \item \code{X_reg_Eti} The vector of covariate names that stratify/regress
#'  etiologies;
#' \item \code{pathogen_cat} The two-column dataframe that has category of pathogens: virus (V), bacteria (B)
#' and fungi (F);
#' \item \code{pathogen_SSonly_list} The vector of pathogens with only
#' SS measure;
#' \item \code{pathogen_SSonly_cat} The category of pathogens with only SS measure.
#'}
#'
#' @param mcmc_options A list of Markov chain Monte Carlo (MCMC) options.
#'
#' \itemize{
#' \item \code{debugstatus} for whether to pause WinBUGS after it finishes
#' model fitting;
#' \item \code{n.chains} for the number of MCMC chains;
#' \item \code{n.burnin} for the number of burn-in samples;
#' \item \code{n.thin} keep every other n.thin samples after burn-in period;
#' \item \code{individual.pred} whether to perform individual prediction;
#' \item \code{ppd} whether to perform posterior predictive checking
#' \item \code{result.folder} for the path to folder storing the results;
#' \item \code{bugsmodel.dir} for the directory to WinBUGS model files;
#' \item \code{winbugs.dir} for the directory where WinBUGS 1.4 is installed.
#' }
#' @return A WinBUGS result, fitted by function \code{bugs()} from
#' the R2WinBUGS package.
#'
#' @export

nplcm <- function(Mobs,Y,X,model_options,mcmc_options){
  parsing <- assign_model(Mobs,Y,X,model_options)
  if (!any(unlist(parsing$reg))){
    # if no stratification or regression:
    if (parsing$measurement$quality=="BrS+SS"){
          if (!parsing$measurement$SSonly){
              if (!parsing$measurement$nest){
                # model 1, DONE
                    res <- nplcm_fit_NoReg_BrSandSS_NoNest(Mobs,Y,X,model_options,mcmc_options)
              }else{
                # model 2, DONE
                    res <- nplcm_fit_NoReg_BrSandSS_Nest(Mobs,Y,X,model_options,mcmc_options)
              }
          } else{
              if (!parsing$measurement$nest){
                # model 3, DONE
                res <- nplcm_fit_NoReg_BrSandSS_NoNest_SSonly(Mobs,Y,X,model_options,mcmc_options)
              }else{
                # model 4, DONE
                res <- nplcm_fit_NoReg_BrSandSS_Nest_SSonly(Mobs,Y,X,model_options,mcmc_options)
              }
          }
    }else if (parsing$measurement$quality=="BrS"){
          if (!parsing$measurement$SSonly){
              if (!parsing$measurement$nest){
                # model 5, DONE
                   res <- nplcm_fit_NoReg_BrS_NoNest(Mobs,Y,X,model_options,mcmc_options)
              }else{
                # model 6, DONE
                   res <- nplcm_fit_NoReg_BrS_Nest(Mobs,Y,X,model_options,mcmc_options)
              }
          }
    }
  }

#   else{
#     # with stratification or regression:
#     res <- nplcm_fit_reg(Mobs,Y,X,model_options,mcmc_options)
#   }
  res
}
