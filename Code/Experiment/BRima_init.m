function BRima_init(subjectID, location, session)

%   BRima_init(subject, session, location)
%   
%   Binocular rivalry imagery task initialization code. Calls the function
%   BRima_task with the desired set of P.
%
%   subject:       String with subject ID  
%   session:       Session integer
%   location:      'debug'        = 0 = Laptop
%                  'behavioural'  = 1 = Behavioural lab
%                  'meg'          = 2 = MEG scanner
%                  'mri'          = 3 = MRI scanner
%
%   If no other input arguments are given, the code will assume it needs 
%   to run in demonstration mode. If only situation isn't entered, the default
%   assumption is that you're running the code for the scanner.
%
%   Written by SEB in FEB 2017, adapted by ND MAY 2018


addpath('functions');
P = struct;

%% Initialize randomness & keycodes
P.rngSeed = rng('shuffle', 'twister');
KbName('UnifyKeyNames');
RestrictKeysForKbCheck([]); % reenable all keys for KbCheck
Screen('Preference', 'SkipSyncTests', 1); 

%% User-defined input
if nargin == 0
    subjectID = 'S00';
    session = 1;
    location = 'debug';
end

% infer which is the manipulated and fixed grating
load(sprintf('trialMatrix_%s.mat',subjectID)) % load the trial matrix
if length(unique(trialMatrix(:,2))) == 2; P.fixGrating = 1; P.manipulateGrating = 2;
else P.fixGrating = 2; P.manipulateGrating = 1; end


switch location
    case 'debug'
        P.situation = 0; % 0 = Desktop, 1 = Behavioural, 2 = Trio, 3 = Random computer
        P.windows   = true;
        P.dataPath  = fullfile(pwd,'debugData/',subjectID);
        P.leftKey   = 's'; % vividness indicatons
        P.rightKey  = 'f';
        P.keys      = {'j','k','l'}; % response keys        
    case 'behavioural'
        P.situation = 1; % 0 = Desktop, 1 = Behavioural, 2 = Trio, 3 = Random computer
        P.windows   = false;
        P.dataPath  = fullfile(pwd,'behaviouralData/',subjectID);
        P.leftKey   = 's'; % vividness indicatons
        P.rightKey  = 'f';
        P.keys      = {'j','k','l'}; % response keys
    case 'meg'
        P.situation = 2;
        P.windows   = false;
        P.dataPath  = 'megData/';
        P.leftKey   = 97;
        P.rightKey  = 98;
        P.leftKeyOff = 65;
        P.rightKeyOff = 66;
    case 'mri'
        P.situation = 3;
        P.windows   = false;
        P.dataPath  = 'mriData/';
        P.leftKey   = 97;
        P.rightKey  = 98;
        P.leftKeyOff = 65;
        P.rightKeyOff = 66;
end

if ~exist(P.dataPath, 'dir'), mkdir(P.dataPath); end

P.subject = subjectID;
P.theDate = datestr(now, 'yyyymmdd');

% Determine current session
[P.session, P.sessionName] = current_session([P.theDate '_brima_' subjectID], session, P.dataPath); 
if strcmp(P.session, 'abort'), error('No response given, exiting.'); end

%% Screen parameters
[frameHz,pixPerDeg,calibrationFile] = get_monitor_info(location);

P.frameHz          = frameHz;
P.pixPerDeg        = pixPerDeg;
P.calibrationFile  = calibrationFile;
P.screen           = 0; % main screen
if P.situation < 1
P.resolution       = [750 50 1250 550]; %Screen('Rect', P.screen); %
else
P.resolution       = Screen('Rect', P.screen); %
end
P.backgroundColour = 0;
P.fontName         = 'Arial';
P.fontSize         = 26;

%% Gamma-corrected CLUT
P.meanLum = 0.5;
P.contrast = 1;
P.stimContrast = 0.2;
P.amp = P.meanLum * P.contrast;

nColours = 255;	% number of gray levels to use in mpcmaplist, should be uneven
mpcMapList = zeros(256,3);	% color look-up table of 256 RGB values, RANGE 0-1
tempTrial = linspace(P.meanLum-P.amp, P.meanLum+P.amp, nColours)';	% make grayscale gradient

P.meanColourIdx = ceil((nColours)/2) -1; % mean colour number (0-255) of stimulus (used to index rows 1:256 in mpcmaplist)
P.ampColourIdx  = floor(P.stimContrast*(nColours-1)); % amplitude of colour variation for stimulus

if ~isempty(P.calibrationFile)
    load(P.calibrationFile);	% function loads inverse gamma table and screen dacsize from most recent calibration file
    
    mpcMapList(1:nColours,:) = repmat(tempTrial, [1 3]);
    mpcMapList(256,1:3) = 1;
    mpcMapList = round(map2map(mpcMapList,gammaInverse));
    
    P.CLUT = mpcMapList;
end

%% Experiment parameters

if P.situation < 1 % debug mode
    P.nRuns = 1;
    P.nTrialsPerRun = 30;
else
    P.nRuns = 11;
    P.nTrialsPerRun = size(trialMatrix,1)/P.nRuns;
end

P.runIdx = ((P.session-1)*P.nTrialsPerRun+1):(P.session*P.nTrialsPerRun);
P.trialMatrix = trialMatrix(P.runIdx,:);

%% Stimulus parameters

% colour
P.Red = [255 0 0]/2; % luminance
P.Blue = [0 0 255];
P.Grey = [255 255 255]/2;

% Stimulus parameters
P.stimSizeInDegree = 5;
P.distFromFixInDeg = 1;
P.distFromFixInPix = round(P.pixPerDeg * P.distFromFixInDeg);
P.stimSizeInPix = round([P.stimSizeInDegree*P.pixPerDeg P.stimSizeInDegree*P.pixPerDeg]);	% Width, height of stimulus
P.baseRect = [0 0 160 160]; % stimulus frame
P.fixRadiusInDegree = .6;

% Gabor grating parameters
P.gaborSize = P.stimSizeInPix(1); % 
P.cosEdge   = 15; % cosine blurred edge thickness
P.targDev   = 10; % grating deviation from vertical
P.nCycles   = 5; % how many cycles?
P.Phase     = 3.5;

P.preContrastMultiplier = 1;
P.initialContrast = 0.5;

%% Time Parameters                                                        
P.fix               = 0.2;	
P.startDur          = 0.4;
P.postStartDur      = 0.3;

P.cueDur            = 0.75; 
P.imageryDur        = 7; 
P.confDur           = 3; % time the conf stimulus will be on screen for (=response epoch)
P.BRstimDur         = 0.75;
P.responseDur       = 3; % so slow, then continue

P.ISIrange          = [0.4, 0.6];
P.postStimRange     = [0.4, 0.6];
P.ITIrange          = [0.4, 0.6]; 
P.confDim           = P.confDur - 1; % how far into the conf task should the rating start to dim?
P.postStimDur       = 0.2;

%% Fixation parameters
P.fixRadiusInDegree = .6;

%% Retrocue parameters
P.retroCueID = {'R','B'};
P.retroCueColour = [255 255 255];

%% Vividness rating parameters
P.lineLengthPix            = 300;
P.sliderLengthPix          = 40;
P.matchMean                = P.backgroundColour;
P.matchContrast            = 0.4;
P.matchAmp                 = P.matchMean * P.matchContrast;
P.lineDiamPix              = 5;
P.midX                     = (P.resolution(3)-P.resolution(1))/2+P.resolution(1);
P.midY                     = (P.resolution(4)-P.resolution(2))/2+P.resolution(2);
P.lineRect                 = [P.midX-P.lineLengthPix/2 P.midY-P.lineLengthPix/2 P.midX+P.lineLengthPix/2 P.midY+P.lineLengthPix/2];
P.sliderRect               = [P.midX-P.sliderLengthPix/2 P.midY-P.sliderLengthPix/2 P.midX+P.sliderLengthPix/2 P.midY+P.sliderLengthPix/2];
P.yOffset                  = 120;

%% Trigger parameters
P.triggerStart = 66; 
P.triggerCue   = 70; % + identity of the cue
P.triggerResponseOnset = 80;
P.triggerResponse = 90; % + identity of the response
% perception = first-or-second stim   | stim identity
% imagery =    first-or-second stim+2 | stim identity

%% Run the experiment
BRima_task(P);

end 