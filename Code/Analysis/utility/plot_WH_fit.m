function plot_WH_fit(samples, opts, c, d, subject)

[N, M, K] = size(d);

gausscdf = @(x, g, l, u, v) g+(1-g-l)*normcdf(x, u, v);

hold on;

if isempty(subject)
    
    gsamples = reshape(samples.g
    
    g_mean = samples.g
    
    
    
end

function [p_mean, p_ub, p_lb] = get_subject_stats(samples, opts, subject, param)

[nchains, nsamples, N, K] = size(samples.g);

samples_res = reshape(samples.(param), [nchains * nsamples, N, K]);

p_mean = mean(samples_res(:, subject, :), 1);