function BF10 = SavageDickey(post, prior, order, plotting)

if ~isempty(order) && ~strcmp(order, 'unrestricted')
    if strcmp(order, 'smaller')
       post = post(post<0);
       prior = prior(prior<0);
       xbounds = [min([min(post), min(prior), 0.0])-0.5, 0.0];
       if numel(post) == 0
           % nothing survived ordered test
           fprintf('No posterior mass < 0.\n');
           BF10 = 0;
           return;
       end
    elseif strcmp(order, 'greater')
       post = post(post>0);
       prior = prior(prior>0);
       xbounds = [0.0, max([max(post), max(prior), 0.0])+0.5];
       if numel(post) == 0
           % nothing survived ordered test
           fprintf('No posterior mass > 0.\n');
           BF10 = 0;
           return;
       end
    end
else
    xbounds = [min([min(post), min(prior), 0.0])-0.5, max([max(post), max(prior), 0.0])+0.5];
end

post_fit = fit_kernel_density(post);
prior_fit = fit_kernel_density(prior);


% sum(post_fit.density)*diff(post_fit.x(1:2)) should be approx. 1.0


post_at_0 = interp1(post_fit.x, post_fit.density, 0.0);

prior_at_0 = interp1(prior_fit.x, prior_fit.density, 0.0);

BF10 = prior_at_0 / post_at_0;

if plotting
    hold on;
    plot(post_fit.x, post_fit.density, 'color', 'k', 'linewidth', 2);
    plot(prior_fit.x, prior_fit.density, 'color', 'k', 'linewidth', 2, 'linestyle', '--');
    scatter(0, post_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3]);
    scatter(0, prior_at_0, 'o', 'markeredgecolor', 'k', 'markerfacecolor', [0.3, 0.3, 0.3]);
    line([0, 0], ylim, 'color', 'k');
    xlim(xbounds);
    xlabel('Difference');
    ylabel('Density');

    title(sprintf('log BF_{10} = %0.2f', log(BF10)));

    legend('Posterior', 'Prior');
end

function fit = fit_kernel_density(samples)

[~, density, xmesh] = kde(samples, 2^8, min(samples)-1, max(samples)+1);
fit.x = xmesh;
fit.density = density;