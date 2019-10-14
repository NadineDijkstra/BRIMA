close all
load staircase_test0.5.mat

% This code comes from: 
% http://matlaboratory.blogspot.nl/2015/05/fitting-better-psychometric-curve.html

% calculate responses
D(:,3) = D(:,1)./sum(D,2);
D(:,4) = D(:,2)./sum(D,2);

names = {'red','blue'};
results.intensity = C(:,2);
results.response  = D(:,manipulateGrating+2);

% plot the data
figure, scatter(results.intensity,results.response)
ylabel('Proportion of time')
xlabel('Intensity of blue grating (red was fixed)')
axis([0,1,0,1])
hold on
 
% Set prior estimates for: 
% g (guess rate)
% l (lapse rate)
% u (mean value of distribution representing subject bias
% v (standard deviation of distribution representing subject bias
% 
% The g and l parameters represent the participant's fallibility: these
% parameters allow the curve to not run perfectly from 0 to 1.
% Here, we set a wide parameter space for all these parameters (all running
% from 0 to 1), so the function can search for the optimal fit
SPs = [1, 1, 1, 1; % Upper limits for g, l, u ,v
    0.01, 0.05, 0.5, 0.1; % Start points for g, l, u ,v
    0, 0, 0, 0]; % Lower limits for  g, l, u ,v

% fit the psychometric function
% (https://drive.google.com/file/d/0B7HUhnL3EUyYRFlsTlBnbzNPN0E/view)
%
% coeffs has the posterior estimations of g, l, u and v
% u = the bias or point of subjective equivalence (PSE): the intensity at
%       which performance is half of the maximum
% v = discrimination sensitivity
[coeffs, curve] = ...
    FitPsycheCurveWH(results.intensity, results.response, SPs);

% plot the fitted curve
plot(curve(:,1), curve(:,2), 'LineStyle', '--')

% plot PSE
xValue = coeffs.u;
line([xValue xValue],[0 1],'Marker','.','LineStyle',':', 'Color', 'k')
yValue = (1-coeffs.l)/2; % if upper boundary of curve is not 1, the midpoint is defined as half of the upper bound)
plot(0:1,yValue,'--')
line([0 1],[yValue yValue],'Marker','.','LineStyle',':', 'Color', 'k')
