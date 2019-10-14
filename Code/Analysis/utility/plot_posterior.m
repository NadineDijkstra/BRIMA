function counts_norm = plot_posterior(samples, bins, color)


[counts, ~] = hist(samples, bins);
% bar(bins, counts / trapz(bins, counts), 'facecolor', color);

counts_norm = counts / trapz(bins, counts);
plot(bins, counts_norm, 'color', color);

