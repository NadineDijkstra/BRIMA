function plot_simulation_data(c, d, true_values, sim_opts)

gausscdf = @(x, g, l, u, v) g+(1-g-l)*normcdf(x, u, v);

N = sim_opts.nsubjects;
K = sim_opts.nconditions;

colors = [0, 0, 1; 1, 0, 0];
sz = 6;

figure('Name', 'Simulation Data');
subplot(2,N,floor(N/2)+1);
hold on;
for k = 1:K
    plot(c, gausscdf(c, true_values.g_grp(k), true_values.l_grp(k), true_values.u_grp(k), true_values.v_grp(k)), 'color', colors(k,:), 'linewidth', 2);
end
legend({sprintf('g = %0.2f, l = %0.2f, u = %0.2f, v = %0.2f', true_values.g_grp(1), true_values.l_grp(1), true_values.u_grp(1), true_values.v_grp(1)), ...
        sprintf('g = %0.2f, l = %0.2f, u = %0.2f, v = %0.2f', true_values.g_grp(2), true_values.l_grp(2), true_values.u_grp(2), true_values.v_grp(2))}, ...
        'location', 'southeast');
ylim([0, 1]);
axis square;
title('Group level curves');
for i = 1:N
    subplot(2,N,N+i);
    hold on; 
    % plot subject curves
    handles = [];
    for k = 1:K
        h = plot(c, gausscdf(c, true_values.g(i, k), true_values.l(i, k), true_values.u(i, k), true_values.v(i, k)), 'color', colors(k,:), 'linewidth', 2);   
        handles = [handles, h];
        scatter(c, squeeze(d(i, :, k)), sz, 'filled', 'markeredgecolor', colors(k, :), 'markerfacecolor', colors(k, :));
    end
    legend(handles, ...
            {sprintf('g = %0.2f, l = %0.2f, u = %0.2f, v = %0.2f', true_values.g(i, 1), true_values.l(i, 1), true_values.u(i, 1), true_values.v(i, 1)), ...
             sprintf('g = %0.2f, l = %0.2f, u = %0.2f, v = %0.2f', true_values.g(i, 2), true_values.l(i, 2), true_values.u(i, 2), true_values.v(i, 2))}, ...
        'location', 'southeast');
    title(sprintf('Subject %d', i));
    ylim([0, 1]);
    axis square;
end