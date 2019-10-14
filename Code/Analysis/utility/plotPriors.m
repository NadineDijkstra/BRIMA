function plotPriors(hyperparameters)

K = 2;

gam_x = 0:0.01:40;
norm_x = 0:0.01:1;
x = 0:0.01:1;
logit = @(x, phi, tau) 1 ./ (1+exp(-phi *(x - tau)));
colors = [0, 0, 1; 1, 0, 0];

figure;
for k=1:K
    steepness_exp = hyperparameters.steepness(k,1)*hyperparameters.steepness(k,2);
    offset_exp = hyperparameters.offset_mean(k);
    
    subplot(2,4,(k-1)*4+1);
    plot(gam_x, pdf('gamma', gam_x, hyperparameters.steepness(k,1), hyperparameters.steepness(k,2)), 'color', colors(k,:));    
    xlabel('x'); ylabel('p(x)');
    title('Steepness');
    axis square;
    line([steepness_exp, steepness_exp], ylim, 'color', colors(k, :), 'linestyle', ':');
    subplot(2,4,(k-1)*4+2);
    plot(norm_x, pdf('norm', norm_x, hyperparameters.offset_mean(k), hyperparameters.offset_variance), 'color', colors(k,:));
    xlabel('x'); ylabel('p(x)');
    title('Offset');
    axis square;   
    subplot(2,4, [3, 4, 7, 8]);
    hold on;
    plot(x, logit(x, steepness_exp, offset_exp), 'color', colors(k, :));  
    axis square;
    title('Prior expected logistic curves');
end




