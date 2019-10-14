function [c, d, true_values] = simulate_data(sim_opts)

gausscdf = @(x, g, l, u, v) g+(1-g-l)*normcdf(x, u, v);
truncnormrnd = @(mu, sigma2, l, u) mu + sqrt(sigma2)*trandn((l-mu)/sqrt(sigma2), (u-mu)/sqrt(sigma2));

N = sim_opts.nsubjects;
M = sim_opts.ntrials;
K = sim_opts.nconditions;

c = linspace(1/M, 1.0, M);

g = zeros(N, K);
l = zeros(N, K);
u = zeros(N, K);
v = zeros(N, K);


obs_noise = unifrnd(0.02, 0.07, [N, 1]);

d = zeros(N, M, K);

g_grp = [0.01, 0.03];
l_grp = [0.05, 0.01];
u_grp = [0.44, 0.51];
v_grp = [0.07, 0.12];

g_grp_var = [0.02, 0.06].^2;
l_grp_var = [0.03, 0.05].^2;
u_grp_var = [0.05, 0.04].^2;
v_grp_var = [0.01, 0.05].^2;

fprintf('Simulating data...\n')
for k = 1:K         
    % subject level statistics
    for i = 1:N
        g(i, k) = truncnormrnd(g_grp(k), g_grp_var(k), 0.0, 1.0);
        l(i, k) = truncnormrnd(l_grp(k), l_grp_var(k), 0.0, 1.0);
        u(i, k) = truncnormrnd(u_grp(k), u_grp_var(k), 0.0, 1.0);
        % Matlab uses shape&scale, JAGS uses shape&rate!
        v(i, k) = gamrnd(v_grp(k) /(v_grp_var(k) / v_grp(k)), v_grp_var(k) / v_grp(k));

        % observations
        for j = 1:M
            mu = gausscdf(c(j), g(i, k), l(i, k), u(i, k), v(i, k));
            d(i,j,k) = normrnd(mu, obs_noise(i)); % mean and sd
        end
    end    
end

true_values.g_grp = g_grp;
true_values.l_grp = l_grp;
true_values.u_grp = u_grp;
true_values.v_grp = v_grp;

true_values.g_grp_var = g_grp_var;
true_values.l_grp_var = l_grp_var;
true_values.u_grp_var = u_grp_var;
true_values.v_grp_var = v_grp_var;

true_values.g = g;
true_values.l = l;
true_values.u = u;
true_values.v = v;
true_values.obs_noise = obs_noise;
