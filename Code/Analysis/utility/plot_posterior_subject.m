function plot_posterior_subject(samples, subject, c, d)


[nchains, nsamples, N, K] = size(samples.g);

g_samples = reshape(samples.g, [nchains*nsamples, N, K]);
g_samples = g_samples(:, subject, :);
l_samples = reshape(samples.l, [nchains*nsamples, N, K]);
l_samples = l_samples(:, subject, :);
u_samples = reshape(samples.u, [nchains*nsamples, N, K]);
u_samples = u_samples(:, subject, :);
v_samples = reshape(samples.v, [nchains*nsamples, N, K]);
v_samples = v_samples(:, subject, :);

[g_mu, g_lb, g_ub] = get_stats(g_samples);
[l_mu, l_lb, l_ub] = get_stats(l_samples);
[u_mu, u_lb, u_ub] = get_stats(u_samples);
[v_mu, v_lb, v_ub] = get_stats(v_samples);

gausscdf = @(x, g, l, u, v) g+(1-g-l)*normcdf(x, u, v);

colors = [0.8, 0.0, 0.0; 0.0, 0.0, 0.8];

samples2show = 25;
sz = 8;
handles = [];

hold on;
for k=1:K    
    %area = fill([c, fliplr(c)], ...
    %    [gausscdf(c, g_ub(k), l_ub(k), u_ub(k), v_ub(k)), fliplr(gausscdf(c, g_lb(k), l_lb(k), u_lb(k), v_lb(k)))], colors(k,:), 'edgecolor', 'none');
    %set(area, 'facealpha', 0.1);
    plot(c, gausscdf(c, g_ub(k), l_ub(k), u_ub(k), v_ub(k)), 'color', colors(k,:), 'linewidth', 1, 'linestyle', '--');
    plot(c, gausscdf(c, g_lb(k), l_lb(k), u_lb(k), v_lb(k)), 'color', colors(k,:), 'linewidth', 1, 'linestyle', '--');
%     for i=1:samples2show
%         ix = randi(nchains*nsamples);        
%         p = plot(c, gausscdf(c, g_samples(ix, k), l_samples(ix, k), u_samples(ix, k), v_samples(ix, k)), 'color', colors(k,:), 'linewidth', 1); 
%         p.Color(4) = 0.1;
%     end
    scatter(c, squeeze(d(subject, :, k)), sz, 'filled', 'markeredgecolor', colors(k,:), 'markerfacecolor', colors(k,:));
    h = plot(c, gausscdf(c, g_mu(k), l_mu(k), u_mu(k), v_mu(k)), 'color', colors(k,:), 'linewidth', 2);  
    handles = [handles; h];
end
legend(handles, {'Condition 1', 'Condition 2'}, 'location', 'southeast');
axis square;
xlim([0.0, 1.0]);
ylim([0.0, 1.0]);
xlabel('Contrast');
ylabel('Stimulus dominance');
title(sprintf('Subject %d parameter estimates', subject));

function [mu, lb, ub] = get_stats(samples, HDI)

if nargin<2
    HDI = 0.95;
end

[m, K] = size(samples);

mu = mean(samples,1);
hdi_lb = round((1-HDI)/2 * m);
hdi_ub = round((1-(1-HDI)/2) * m);
lb = zeros(K,1);
ub = zeros(K,1);

for k=1:K
    samples_sorted = sort(samples(:,k));
    lb(k) = samples_sorted(hdi_lb);
    ub(k) = samples_sorted(hdi_ub);
end


