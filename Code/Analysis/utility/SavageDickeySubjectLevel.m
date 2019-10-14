function BF_10 = SavageDickeySubjectLevel(posterior_samples, prior_samples, subject, parameter, order, plotting)

[nchains, nsamples, N, K] = size(posterior_samples.g);

param_samples_post = reshape(posterior_samples.(parameter), [nchains*nsamples, N, K]);
param_samples_prior = reshape(prior_samples.(parameter), [nchains*nsamples, N, K]);

param_samples_diff_post = param_samples_post(:, subject, 2) - param_samples_post(:, subject, 1);
param_samples_diff_prior = param_samples_prior(:, subject, 2) - param_samples_prior(:, subject, 1);

% model comparison at group level

if nargin < 4
    order = 'unrestricted';
end

BF_10 = SavageDickey(param_samples_diff_post, param_samples_diff_prior, order, plotting);