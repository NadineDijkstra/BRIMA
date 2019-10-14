function plot_logistic_fit(samples, c, d)

% assumes samples have been merged across chains with mergeChains.m

showsamples = 10;    

figure; 
subplot(2, 3, [1, 2, 4, 5]);
hold on;
for i = 1:showsamples
    sample_index = randi(nsamples*nchains);
    phi_sample = samples.phi(sample_index, 1);
    tau_sample = samples.tau(sample_index, 1);
    p1 = plot(c, logit(c, phi_sample, tau_sample), 'b');
    p1.Color(4) = 0.2;

    phi_sample = samples.phi(sample_index, 2);
    tau_sample = samples.tau(sample_index, 2);
    p2 = plot(c, logit(c, phi_sample, tau_sample), 'r');
    p2.Color(4) = 0.2;
end
scatter(c, squeeze(d(:,1)), sz, 'filled', 'markeredgecolor', [0, 0, 1]);
scatter(c, squeeze(d(:,2)), sz, 'filled', 'markeredgecolor', [1, 0, 0]);
xlabel('Contrast of stim1');
ylabel('Dominance of stim1');
title(sprintf('Logistic fit'));
axis square;
xlim([0, 1]);
subplot(2, 3, 3);
histogram(merged_samples.steepness_diff, 30, 'normalization', 'pdf');
axis square;
title('Steepness difference');
subplot(2, 3, 6);
histogram(merged_samples.offset_diff, 30, 'normalization', 'pdf');
axis square;
title('Offset difference');

