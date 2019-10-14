function makeTrialmatrix(subjectID,manipulateGrating)
% function makeTrialmatrix(subjectID, manipulateGrating)
%

directory = pwd;

%% Calculate the number of trials
trialTime       = 12.7;
nTrialsPerCond  = 100;
nCond           = 2;
nMocks          = 20; 
nTrials         = nCond*nTrialsPerCond+nMocks;
expTime         = nTrials*trialTime;
nRuns           = 12;
nTrialsPerCue   = nTrials/nCond;
nMockPerCue     = nTrialsPerCue - nTrialsPerCond;

fprintf('\t Experimental time is %.2f minutes, excluding breaks \n',expTime/60);

%%

if manipulateGrating == 1
    fixGrating = 2;
elseif manipulateGrating == 2
    fixGrating = 1;
end
fixedContrast = 0.5;

% contrasts
C = linspace(0,1,nTrialsPerCond);

%% Make the trial matrix 
M = zeros(nTrials,3);

M(1:nTrialsPerCond+nMocks/2,1) = 1; % cue red
M(1:nTrialsPerCond,fixGrating+1) = fixedContrast;
M(1:nTrialsPerCond,manipulateGrating+1) = C;
M(nTrialsPerCond+1:nTrialsPerCond+nMocks/2,2:3) = 99;

M(nTrialsPerCond+nMocks/2+1:nTrials,1) = 2; % cue blue 
M(nTrialsPerCond+nMocks/2+1:nTrials-nMocks/2,fixGrating+1) = fixedContrast;
M(nTrialsPerCond+nMocks/2+1:nTrials-nMocks/2,manipulateGrating+1) = C;
M(nTrials-nMocks/2+1:nTrials,2:3) = 99;

% shuffle everything
trialMatrix = M(randperm(nTrials),:);

% write it to a file
save(fullfile(directory,['trialMatrix_' subjectID '.mat']),'trialMatrix')