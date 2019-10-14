addpath utility
addpath matjags

% subjects
subjects = {'S13','S14','S15','S16','S17','S18','S19','S20','S30','S31','S32','S33','S34','S35','S36','S37','S38','S39','S40','S41','S42','S43','S44','S45','S46','S47','S49','S50','S51','S52','S53','S54','S55','S56','S57','S58','S59','S60','S61','S62','S63','S64','S65','S66','S67','S68','S69','S70','S71','S72','S73','S74','S75','S76','S77','S78','S79','S80','S81'};
nsubjects= length(subjects);
dataPath = 'your_folder/Data';

% Get the data
d = zeros(nsubjects,89,2);

for sub = 1:nsubjects
    
    fprintf('PREPARING DATA SUBJECT %d OUT OF %d \n',sub,nsubjects)
    
    % prepare the data
    results = prepare_data(subjects{sub},dataPath);
    
    if sub == 1; c = results.intensity; end
    d(sub,:,:) = results.response;
    
    clear results
    
end

%% Run BAYES analysis

[posterior_samples, prior_samples] = hierarchical_brima(c,d);

save results_narrow posterior_samples prior_samples


%% Plot posterior estimates curves per subject and group
load results_1e5
N = size(posterior_samples.u,3);

% Group level parameter estimates - mean and 95% HDI
% HDI is expected to be wider than the subject-level estimates.
figure('Name', 'Group-level psychometric curves');
plot_posterior_group(posterior_samples, c);

% Subject level parameter estimates - mean and 95% HDI
% Verify that most data points are within the 95% HDI.
figure('Name', 'Subject-level psychometric curves');
for i=1:N
    subplot(floor(sqrt(N)), ceil(sqrt(N)), i);
    plot_posterior_subject(posterior_samples, i, c, d);
end

%% Model comparison / hypothesis testing

% Note: Plot titles show log(BF_10)

nchains = size(posterior_samples.u,1);
nsamples = size(posterior_samples.u,2);
N        = size(posterior_samples.u,3);

% Hypothesis order-restriction is indicated by
% 'unrestricted'    (d != 0),
% 'smaller'         (d < 0) and
% 'greater'         (d > 0).

figure('Name', 'Group-level model comparison');
subplot 121;
BF_10_u_grp = SavageDickeyGroupLevel(posterior_samples, prior_samples, 'u_grp', 'unrestricted', true);
axis square;
subplot 122;
BF_10_v_grp = SavageDickeyGroupLevel(posterior_samples, prior_samples, 'v_grp', 'unrestricted', true);
axis square;

figure('Name', 'Subject-level model comparison');
for i=1:5
    subplot(1, 5, i);
    BF_10_u_i = SavageDickeySubjectLevel(posterior_samples, prior_samples, i, 'u', 'unrestricted', true);
    axis square;
end

parameter = 'u';

BFs = zeros(N,1);
for i=1:N
    BFs(i) = SavageDickeySubjectLevel(posterior_samples, prior_samples, i, parameter, 'unrestricted', false);
end

BFgroup = SavageDickeyGroupLevel(posterior_samples, prior_samples, [parameter, '_grp'], 'unrestricted', false);

samples = posterior_samples.(parameter);
diff_data = reshape(samples(:, :, :, 2) - samples(:, :, :, 1), [nchains*nsamples, N]);
samples_grp = posterior_samples.([parameter, '_grp']);
diff_data_grp = reshape(samples_grp(:, :, 2) - samples_grp(:, :, 1), [nchains*nsamples, 1]);

bflims = [floor(min(log(BFs)) / 10)*10, ceil(max(log(BFs)) / 10)*10];

% main figure difference
figure('Name', sprintf('Difference in parameter %s', parameter));
subplot(3, 5, [1, 6]);
boxplot(diff_data_grp,'plotstyle', 'traditional', 'symbol', '');
ylim([-0.6, 0.6]);
xlabel('Group'); ylabel(sprintf('Difference in %s', parameter));
line(xlim, [0, 0], 'color', [0 0 0], 'linestyle', '--');
title('Group estimate');

subplot(3, 5, 11);
bar(log(BFgroup), 'edgecolor', [0 0 0]);
xlim([0 2])
ylim(bflims);
ylabel(sprintf('Log Bayes factor for difference in %s', parameter));
title('Group effect Bayes factor');

subplot(3, 5, [2,3,4,5,7,8,9,10]);
boxplot(diff_data, 'plotstyle', 'traditional', 'symbol', '');
ylim([-0.6, 0.6]);
xlabel('Subject number'); ylabel(sprintf('Difference in %s', parameter));
line(xlim, [0, 0], 'color', [0 0 0], 'linestyle', '--');
title('Subject estimates');
set(gca,'Xtick',0:5:N); set(gca,'XTickLabel',{int2str([0:5:N]')});


subplot(3, 5, [12, 13, 14, 15]);
bar(log(BFs), 'edgecolor', [0 0 0]);
xlabel('Subject number'); ylabel(sprintf('Log Bayes factor for difference in %s', parameter));
ylim(bflims);
set(gca,'Xtick',0:5:N); set(gca,'XTickLabel',{int2str([0:5:N]')});
title('Subject Bayes factors');


%% Diagnostics

K = 2; true_values = [];

% Observation noise per subject
obs_samples = reshape(posterior_samples.obs_sd, [nchains*nsamples, N]);
nbins = 50;
figure('Name', 'Subject-level noise estimates');
for i=1:N
    subplot(floor(sqrt(N)), ceil(sqrt(N)),i);
    hold on;
    for k=1:K
        plot_posterior(obs_samples(:,i), linspace(0.0, 0.1, nbins), [0 0 0]);
    end
    xlabel('Noise level'); ylabel('Density');
    axis square;
    if ~isempty(true_values)
        for k=1:K
            line([true_values.obs_noise(i), true_values.obs_noise(i)], ylim, 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--');
        end
    end
    title(sprintf('Subject %d obs. noise', i));
end

% Plot posterior parameter estimates (mostly for diagnostics)

params = {'g', 'l', 'u', 'v'};

colors = [0, 0, 1; 1, 0, 0];
nbins = 100;
bounds.g = [0.0, 0.2];
bounds.l = [0.0, 0.2];
bounds.u = [0.0, 1.0];
bounds.v = [0.0, 0.4];

bounds.g_var = [0.0, 0.2];
bounds.l_var = [0.0, 0.2];
bounds.u_var = [0.0, 4.0];
bounds.v_var = [0.0, 0.4];

P = length(params);

% group level plot
figure('Name', 'Group-level parameter estimates');
for i = 1:P
    param = params{i};
    param_samples = reshape(posterior_samples.([param, '_grp']), [nchains*nsamples, K]);
    b = bounds.(param);
    lb = b(1); ub = b(2);
    range = linspace(lb, ub, nbins);
    subplot(2, P, i);
    hold on;
    for k=1:K
        plot_posterior(param_samples(:,k), range, colors(k,:));
    end
    if ~isempty(true_values)
        true_vals = true_values.([param, '_grp']);
        for k=1:K
            line([true_vals(k), true_vals(k)], ylim, 'color', colors(k, :), 'linewidth', 2, 'linestyle', '--');
        end
    end
    xlim([lb, ub]);
    xlabel(sprintf('%s', param)); ylabel('Density')
    title(sprintf('Group level parameter'));
end
for i = 1:P
    param = params{i};
    param_samples = reshape(posterior_samples.([param, '_var']), [nchains*nsamples, K]);
    b = bounds.([param, '_var']);
    lb = b(1); ub = b(2) / 10;
    range = linspace(lb, ub, nbins);
    subplot(2, P, P+i);
    hold on;
    for k=1:K
        plot_posterior(param_samples(:,k), range, colors(k,:));
    end
    if ~isempty(true_values)
        true_vals = true_values.([param, '_grp_var']);
        for k=1:K
            line([true_vals(k), true_vals(k)], ylim, 'color', colors(k, :), 'linewidth', 2, 'linestyle', '--');
        end
    end
    xlim([lb, ub]);
    xlabel(sprintf('Var(%s)', param)); ylabel('Density')
    title(sprintf('Group level variance'));
end

% subject level plots
figure('Name', 'Subject-level parameter estimates');
for p=1:P
    param = params{p};
    param_samples = reshape(posterior_samples.(param), [nchains*nsamples, N, K]);
    b = bounds.(param);
    lb = b(1); ub = b(2);
    range = linspace(lb, ub, nbins);
    for i=1:N
        ix=  p+(i-1)*P;
        subplot(N, P, ix);
        hold on;
        for k=1:K
            plot_posterior(param_samples(:, i, k), range, colors(k, :));
        end
        if ~isempty(true_values)
            true_vals = true_values.(param);
            for k=1:K
                line([true_vals(i, k), true_vals(i, k)], ylim, 'color', colors(k, :), 'linewidth', 2, 'linestyle', '--');
            end
        end
        xlim([lb, ub]);
        xlabel(sprintf('%s', param)); ylabel('Density')
        title(sprintf('Subject %d', i));
    end
end

%% Plot Bayes factor versus median posterior
diff_med_u = zeros(N,1); diff_med_v = zeros(N,1);
BFs_u      = zeros(N,1); BFs_v      = zeros(N,1);

diff_data_u = reshape(posterior_samples.u(:, :, :, 2) - posterior_samples.u(:, :, :, 1), [nchains*nsamples, N]);
diff_data_v = reshape(posterior_samples.v(:, :, :, 2) - posterior_samples.v(:, :, :, 1), [nchains*nsamples, N]);

for n = 1:N    
   diff_med_u(n) = median(diff_data_u(:,n));
   diff_med_v(n) = median(diff_data_v(:,n));
   BFs_u(n) = SavageDickeySubjectLevel(posterior_samples, prior_samples, n, 'u', 'unrestricted', false);
   BFs_v(n) = SavageDickeySubjectLevel(posterior_samples, prior_samples, n, 'v', 'unrestricted', false);
end

subplot(2,1,1);
scatter(diff_med_u,log(BFs_u))
xlim([-0.3 0.6]); ylim([-10 20])
hold on; plot(xlim,[0 0],'k'); hold on; plot([0 0],ylim,'k');
subplot(2,1,2);
scatter(diff_med_v,log(BFs_v))
xlim([-0.3 0.6]); ylim([-10 20])
hold on; plot(xlim,[0 0],'k'); hold on; plot([0 0],ylim,'k');

%% Effect eye-dominance

% check effects eye-dominance
[nchains, nsamples, N, K] = size(posterior_samples.g);
u_samples = reshape(posterior_samples.u, [nchains*nsamples, N, K]);
v_samples = reshape(posterior_samples.v, [nchains*nsamples, N, K]);

u_subjects = zeros(N,2);
v_subjects = zeros(N,2);
for n = 1:N
    samples_sub     = u_samples(:, n, :);
    u_subjects(n,:) = squeeze(median(samples_sub,1));
    samples_sub     = v_samples(:, n, :);
    v_subjects(n,:) = squeeze(median(samples_sub,1));
end

u_mean = mean(u_subjects,2);
u_diff = u_subjects(:,2)-u_subjects(:,1);   
v_diff = v_subjects(:,2)-v_subjects(:,1);

figure; subplot(1,2,1);
scatter(u_mean,u_diff,300,'.'); 
ylim([-0.6 0.6]); xlim([0 1]);
hold on; plot(xlim,[0 0],'k--','LineWidth',2)
xlabel('Mean offset','FontSize',20)
ylabel('Incongruent-congruent','FontSize',20)
title('Main effect (bias)')
subplot(1,2,2);
scatter(u_mean,v_diff,300,'.');
ylim([-0.6 0.6]); xlim([0 1]);
hold on; plot(xlim,[0 0],'k--','LineWidth',2)
xlabel('Mean offset','FontSize',20)
ylabel('Incongruent-congruent','FontSize',20)
title('Interaction sensory evidence (slope)')
