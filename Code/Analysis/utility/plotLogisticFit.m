function fit = plotLogisticFit(samples, c, d, plotting)

% assumes samples have been merged across chains with mergeChains.m

showsamples = false;
showHDI = true;

if nargin < 4
    plotting = true;
end

%
logit = @(x, phi, tau) 1 ./ (1+exp(-phi *(x - tau)));

samples2show = 50;    
sz = 10;    
HDI = 0.95;


[~, steepness_density, steepness_xmesh] = kde(samples.steepness_diff, 2^8, min(samples.steepness_diff)-5, max(samples.steepness_diff)+5);
fit.steepness.x = steepness_xmesh;
fit.steepness.density = steepness_density;

[~, offset_density, offset_xmesh] = kde(samples.offset_diff, 2^8, min(samples.offset_diff)-0.5, max(samples.offset_diff)+0.5);
fit.offset.x = offset_xmesh;
fit.offset.density = offset_density;

if plotting

    figure; 
    subplot(2, 3, [1, 2, 4, 5]);
    hold on;

    colors = [0, 0, 1; 1, 0, 0];

    K = 2;
    samplesize = size(samples.phi,1);

    HDI_l = round(samplesize * (1-HDI)/2);
    HDI_u = round(samplesize * (HDI + (1-HDI)/2));

    handles = [];

    for k=1:K
        phi_mean = mean(samples.phi(:,k));
        fprintf('%f\n', phi_mean);
        tau_mean = mean(samples.tau(:,k));
        fprintf('%f\n', tau_mean);
        p = plot(c, logit(c, phi_mean, tau_mean), 'color', colors(k,:), 'linewidth', 3);
        scatter(c, squeeze(d(:,k)), sz, 'filled', 'markeredgecolor', colors(k,:), 'markerfacecolor', colors(k,:));

        if showHDI
            sortedphi = sort(samples.phi(:,k),1);
            phi_l = sortedphi(HDI_l);
            phi_u = sortedphi(HDI_u);
            sortedtau = sort(samples.tau(:,k),1);
            tau_l = sortedtau(HDI_l);
            tau_u = sortedtau(HDI_u);
            plot(c, logit(c, phi_l, tau_l), 'color', colors(k,:), 'linestyle', '--', 'linewidth', 1);
            plot(c, logit(c, phi_u, tau_u), 'color', colors(k,:), 'linestyle', '--', 'linewidth', 1);
        end

        if showsamples
            for i = 1:samples2show
                sample_index = randi(samplesize);
                phi_sample = samples.phi(sample_index, k);
                tau_sample = samples.tau(sample_index, k);
                p1 = plot(c, logit(c, phi_sample, tau_sample), 'color', colors(k,:));
                p1.Color(4) = 0.1;
            end
        end   
        handles = [handles, p];
    end
    legend(handles, {'Condition 1', 'Condition 2'});

    xlabel('Contrast of stim1');
    ylabel('Dominance of stim1');
    title(sprintf('Logistic fit'));
    axis square;
    xlim([0, 1]);
    subplot(2, 3, 3);
    hold on;
    histogram(samples.steepness_diff, 30, 'normalization', 'pdf');
    plot(steepness_xmesh, steepness_density, 'color', 'k');
    axis square;
    title('Steepness difference');
    subplot(2, 3, 6);
    hold on;
    histogram(samples.offset_diff, 30, 'normalization', 'pdf');
    plot(offset_xmesh, offset_density, 'color', 'k');
    axis square;
    title('Offset difference');

end


