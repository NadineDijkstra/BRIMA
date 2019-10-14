function BF_10 = SavageDickeyGroupLevel(posterior_samples, prior_samples, parameter, order, plotting)

[nchains, nsamples, K] = size(posterior_samples.g_grp);

param_samples_post = reshape(posterior_samples.(parameter), [nchains*nsamples, K]);
param_samples_prior = reshape(prior_samples.(parameter), [nchains*nsamples, K]);

param_samples_diff_post = param_samples_post(:,2) - param_samples_post(:,1);
param_samples_diff_prior = param_samples_prior(:,2) - param_samples_prior(:,1);

% model comparison at group level

if nargin < 4
    order = 'unrestricted';
end

BF_10 = SavageDickey(param_samples_diff_post, param_samples_diff_prior, order, plotting);