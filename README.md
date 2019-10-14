# BRIMA
Between-subject variability in the influence of mental imagery on conscious perception 

The masterwrapper.m in the Analysis code performs the hierarchical Bayesian analysis. This analysis requires that JAGS is installed on your operating system (http://mcmc-jags.sourceforge.net/). S13-S17 contains the data for five subjects for all 10 blocks which can be used to run the analysis on and plot some figures. More details on what each variable means can be found in the Experiment code. The Experiment code is the code used for the task. BRima_init.m sets initialisation parameters (timing etc.) and calls BRima_task.m that contain the main task structure. BRima_task_practice.m is an independent short version of the task without different contrast values that can be used for practice. 

If you want to use the task without varying contrast values (the standard imagery task) you need to control for eye-dominance. BRima_staircase.m is an adapted version of the staircase procedure used in Bergmann et al. (2016) that adjusts the contrast of the two stimuli. The rationale is that presenting a stimulus at full dominance in between rivalry presentations should cause the participant to subsequently perceive the other stimulus (adaptation effect). If this is not the case, the contrast of the presented stimulus is too high and needs to be adjusted.  



