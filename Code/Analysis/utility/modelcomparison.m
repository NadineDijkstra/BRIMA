function BF_10 = modelcomparison(fit_posterior, fit_prior)

% find posterior density at x=0 (or as close to zero as the grid allows)
[~, ix0_steepness_post] = min(abs(fit_posterior.steepness.x));
steepness_post_at_0 = fit_posterior.steepness.density(ix0_steepness_post);

% idem for prior
[~, ix0_steepness_prior] = min(abs(fit_prior.steepness.x));
steepness_prior_at_0 = fit_prior.steepness.density(ix0_steepness_prior);
BF_10.steepness = steepness_prior_at_0 / steepness_post_at_0;

% find posterior density at x=0 (or as close to zero as the grid allows)
[~, ix0_offset_post] = min(abs(fit_posterior.offset.x));
offset_post_at_0 = fit_posterior.offset.density(ix0_offset_post);

% idem for prior
[~, ix0_offset_prior] = min(abs(fit_prior.offset.x));
offset_prior_at_0 = fit_prior.offset.density(ix0_offset_prior);

BF_10.offset = offset_prior_at_0 / offset_post_at_0;

% plotting

figure;
subplot 121;
hold on;
plot(fit_posterior.steepness.x, fit_posterior.steepness.density, 'color', 'k');
plot(fit_prior.steepness.x, fit_prior.steepness.density, 'color', 'k', 'linestyle', '--');
scatter(fit_posterior.steepness.x(ix0_steepness_post), steepness_post_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3])
scatter(fit_prior.steepness.x(ix0_steepness_prior), steepness_prior_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3])
axis square;
line([fit_posterior.steepness.x(ix0_steepness_post), fit_posterior.steepness.x(ix0_steepness_post)], ylim, 'color', 'k', 'linestyle', ':')
% xlim([-1, 1]);
xlabel('Difference in steepness');
ylabel('Density')
title(sprintf('Hypothesis test for different steepness; BF_{10} = %0.2e', BF_10.steepness));
legend('Posterior', 'Prior');

subplot 122;
hold on;
plot(fit_posterior.offset.x, fit_posterior.offset.density, 'color', 'k');
plot(fit_prior.offset.x, fit_prior.offset.density, 'color', 'k', 'linestyle', '--');
scatter(fit_posterior.offset.x(ix0_offset_post), offset_post_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3])
scatter(fit_prior.offset.x(ix0_offset_prior), offset_prior_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3])
axis square;
line([fit_posterior.offset.x(ix0_offset_post), fit_posterior.offset.x(ix0_offset_post)], ylim, 'color', 'k', 'linestyle', ':')
% xlim([-1, 1]);
xlabel('Difference in steepness');
ylabel('Density')
title(sprintf('Hypothesis test for different offset; BF_{10} = %0.2e', BF_10.offset));
legend('Posterior', 'Prior');






