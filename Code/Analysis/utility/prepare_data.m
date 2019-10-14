function results = prepare_data(subjectID,dataPath)


% load the data
data = str2fullfile(fullfile(dataPath,subjectID),['2018*' subjectID '*' '.mat']);

for d = 1:length(data)
    load(data{d},'B','P')
    if d == 1
        V        = B(:,1);
        response = B(:,5);
        trialMatrix = P.trialMatrix;
    else 
        V        = [V; B(:,1)];
        response = [response; B(:,5)];
        trialMatrix = [trialMatrix;P.trialMatrix];
    end
    clear B
end

% determine manipulated and fixed grating
M = P.manipulateGrating; F = P.fixGrating; 
if M == 2; M = 3; end
if F == 2; F = 3; end;

% recode the responses
dom = response; dom(response == 2) = 0.5; % mixed
dom(response == M) = 1; 
dom(response == F) = 0;

if M == 3; M = 2; end
if F == 3; F = 2; end
con = trialMatrix(:,M+1); 
cue = trialMatrix(:,1) == M; % imagine manipulated grating (congruency)

% remove mocktrials
mockTrials = trialMatrix(:,2) == 99;
D = dom(~mockTrials); % dominance
C = con(~mockTrials); % contrast
P = cue(~mockTrials); % cue

% split per cue
B = zeros(length(P)/2,2);
for c = 1:2
    if c == 1 % manipulated grating
        idx = P;
    elseif c == 2 % fixed grating
        idx =~ P;
    end
    tmp1 = D(idx); tmp2 = C(idx);
    [contrast,ind] = sort(tmp2,'ascend');
    B(:,c) = tmp1(ind);
end
    
fprintf('Percentage mixed is %.2f \n',sum(D==0.5)/length(dom)*100)
fprintf('Percentage primed is %.2f \n',sum(D==1)/sum(D~=0.5)*100) % exclude mixed

%% Calculate dominance percentage using sliding window

win = 11;
mid = median(1:win);

% with all trials
dominance = zeros(size(B));
for i = 1:length(B)-win  
    idx = i:i+win-1;
    
    for c = 1:2
        dominance(i+mid-1,c) = sum(B(idx,c))/win;
    end
end

% cut off the tails
dominance = dominance(mid:length(B)-mid,:);
contrast = contrast(mid:length(B)-mid);

results.intensity = contrast;
results.response = dominance;



