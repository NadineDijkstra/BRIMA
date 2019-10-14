
function [posterior_samples, prior_samples] = hierarchical_brima(c,d)

N = size(d,1);
M = size(d,2);
K = size(d,3);


%% JAGS wrapper to collect samples from posterior and prior
nchains     = 4;
nburnin     = 1e5;
nsamples    = 1e5;

% sampling parameters
opts.nchains        = 4;                  % 4 is common heuristic
opts.nsamples       = nsamples;           % 1e5 for results, 1e4 for testing
opts.nburnin        = nburnin;
opts.priorsamples   = true;               % needed to compute Bayes factors via Savage-Dickey
opts.parallel       = 2;

% NB: the intuitions for mean/sd are based on Normal distributions.

% data and hyperparameters
datastruct = struct('d', d, ...
                    'c', c, ...
                    'N', N, ...
                    'M', M, ...
                    'K', K, ...
                    ... % priors on group level parameters
                    'g_grp_mean', 0.02, ...
                    'g_grp_sd', 0.05,...%0.1, ...
                    'l_grp_mean', 0.1, ...
                    'l_grp_sd', 0.05,...%0.1, ...
                    'u_grp_mean', 0.5, ...
                    'u_grp_sd', 0.25,...%0.5, ...
                    'v_grp_mean', 0.1, ...
                    'v_grp_sd', 0.05)%0.1); 

tic;              
[posterior_samples, prior_samples] = jagswrapper(datastruct, opts);                
toc;
