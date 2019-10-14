function [posterior_samples, prior_samples] = jagswrapper(datastruct, opts)

K = datastruct.K;
N = datastruct.N;
% some random initial values

for i = 1:opts.nchains                
    init0(i) = struct(  'g', betarnd(1, 1, [N, K]), ...
                        'l', betarnd(1, 1, [N, K]), ...
                        'u', betarnd(1, 1, [N, K]), ...
                        'v', gamrnd(1, 0.1, [N, K]), ...
                        'g_grp', betarnd(1, 1, [1, K]), ...
                        'l_grp', betarnd(1, 1, [1, K]), ...
                        'u_grp', betarnd(1, 1, [1, K]), ...
                        'v_grp', gamrnd(1, 0.1, [1, K])  );
end

if opts.parallel > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        poolObj = parpool(opts.parallel, 'IdleTimeout', Inf);
    end
    do_parallel = 1;
else
    do_parallel = 0;
end

fprintf('Collecting %d chains of %d posterior samples (first %d discarded as burn-in)...\n', opts.nchains, opts.nsamples+opts.nburnin, opts.nburnin);

[posterior_samples, ~, ~] = matjags( ...
        datastruct, ...                     % Observed data   
        fullfile(pwd, 'models/brima_group_posterior_tnorm.txt'), ...    % File that contains model definition       
        init0, ...                          % Initial values for latent variables
        'doparallel' , do_parallel, ...      % Parallelization flag
        'nchains', opts.nchains,...              % Number of MCMC chains
        'nburnin', opts.nburnin,...              % Number of burnin steps
        'nsamples', opts.nsamples, ...           % Number of samples to extract
        'thin', 1, ...                      % Thinning parameter
        'dic', 0, ...                       % Do the DIC?
        'monitorparams',   {'g', 'l', 'u', 'v', ...                            
                            'g_grp', 'l_grp', 'u_grp', 'v_grp', ...
                            'g_var', 'l_var', 'u_var', 'v_var', ...
                            'obs_sd'}, ...     % List of latent variables to monitor
        'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
        'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
        'cleanup' , 1 );                    % clean up of temporary files?

 

if opts.priorsamples
    fprintf('Collecting %d chains of %d prior samples (first %d discarded as burn-in)...\n', opts.nchains, opts.nsamples+opts.nburnin, opts.nburnin);
    clear init0;
    for i = 1:opts.nchains                
        init0(i) = struct(  'g', betarnd(1, 1, [N, K]), ...
                            'l', betarnd(1, 1, [N, K]), ...
                            'u', betarnd(1, 1, [N, K]), ...
                            'v', gamrnd(1, 0.1, [N, K]), ...
                            'g_grp', betarnd(1, 1, [1, K]), ...
                            'l_grp', betarnd(1, 1, [1, K]), ...
                            'u_grp', betarnd(1, 1, [1, K]), ...
                            'v_grp', gamrnd(1, 0.1, [1, K])  );
    end
    [prior_samples, ~, ~] = matjags( ...
        datastruct, ...                     % Observed data   
        fullfile(pwd, 'models/brima_group_prior_tnorm.txt'), ...    % File that contains model definition       
        init0, ...                          % Initial values for latent variables
        'doparallel' , do_parallel, ...      % Parallelization flag
        'nchains', opts.nchains,...              % Number of MCMC chains
        'nburnin', opts.nburnin,...              % Number of burnin steps
        'nsamples', opts.nsamples, ...           % Number of samples to extract
        'thin', 1, ...                      % Thinning parameter
        'dic', 0, ...                       % Do the DIC?
        'monitorparams',   {'g', 'l', 'u', 'v', ...                            
                            'g_grp', 'l_grp', 'u_grp', 'v_grp', ...
                            'g_var', 'l_var', 'u_var', 'v_var', ...
                            'obs_sd'}, ...     % List of latent variables to monitor
        'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
        'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
        'cleanup' , 1 );     
else
    prior_samples = [];
end


fprintf('Sampling complete.\n')
