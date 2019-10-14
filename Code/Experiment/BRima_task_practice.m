function BRima_task_practice(subjectID,location)

%   BRima_task(P)
%
%   Binocular rivalry imagery task  (after Bergmann et al. (2016). Cerebral
%   Cortex). 
%
%   P:    Struct containing various parameters
%
%   Written by ND in NOV 2017, adapted in JAN 2018


%% Paths
addpath('functions')

if nargin == 0
    subjectID = 'test';
    location = 'debug';
end

saveName = ['task_practice_' subjectID '.mat'];


%% Some parameters
P = struct;
if strcmp(location,'debug')
    outputPath = fullfile(pwd,'debugData',subjectID);
elseif strcmp(location,'behavioural')
    outputPath = fullfile(pwd,'behaviouralData',subjectID);
end
if ~exist(outputPath,'dir'); mkdir(outputPath); end
P.situation   = 0;

% Screen parameters
[frameHz,pixPerDeg,calibrationFile] = get_monitor_info(location);

P.situation = 0; % 0 = Desktop, 1 = Behavioural, 2 = Trio, 3 = Random computer
P.frameHz          = frameHz;

P.pixPerDeg        = pixPerDeg;
P.calibrationFile  = calibrationFile;
P.screen           = 0;%screenNumber; % main screen
P.resolution       = Screen('Rect', P.screen); %  [750 50 1250 550]; %
P.midX             = (P.resolution(3)-P.resolution(1))/2+P.resolution(1);
P.midY             = (P.resolution(4)-P.resolution(2))/2+P.resolution(2);
P.yOffset          = 120;
P.backgroundColour = 0;
P.fontName         = 'Arial';
P.fontSize         = 26;

% Response parameters
P.leftKey   = 's'; % vividness indicatons
P.rightKey  = 'f';
P.keys      = {'j','k','l'}; % response keys

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

% Time Parameters
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

% Vividness rating parameters
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

% Trigger parameters
P.triggerStart = 66; 
P.triggerCue   = 70; % + identity of the cue
P.triggerResponseOnset = 80;
P.triggerResponse = 90; % + identity of the response
% perception = first-or-second stim   | stim identity
% imagery =    first-or-second stim+2 | stim identity

% Retrocue parameters
P.retroCueID = {'R', 'B'};
P.retroCueColour = [255 255 255];

% number of trials
P.nTrials = 12;

% make trial matrix
P.trialMatrix = zeros(P.nTrials,1);
P.trialMatrix(1:P.nTrials/3) = 1; P.trialMatrix(P.nTrials/3+1:P.nTrials/3*2) = 2;
P.trialMatrix(P.nTrials/3*2+1:P.nTrials) = 3;
P.trialMatrix = P.trialMatrix(randperm(P.nTrials));

%% Gamma-corrected CLUT
P.meanLum = 0.5;
P.contrast = 1;
P.stimContrast = 0.5;
P.amp = P.meanLum * P.contrast;

nColours = 255;	% number of gray levels to use in mpcmaplist, should be uneven
mpcMapList = zeros(256,3);	% color look-up table of 256 RGB values, RANGE 0-1
tempTrial = linspace(P.meanLum-P.amp, P.meanLum+P.amp, nColours)';	% make grayscale gradient

P.meanColourIdx = ceil((nColours)/2) -1; % mean colour number (0-255) of stimulus (used to index rows 1:256 in mpcmaplist)
P.ampColourIdx  = floor(P.stimContrast*(nColours-1)); % amplitude of colour variation for stimulus

if ~isempty(P.calibrationFile)
    load(P.calibrationFile,'gammaInverse');	% function loads inverse gamma table and screen dacsize from most recent calibration file
    
    mpcMapList(1:nColours,:) = repmat(tempTrial, [1 3]);
    mpcMapList(256,1:3) = 1;
    mpcMapList = round(map2map(mpcMapList,gammaInverse));
    
    P.CLUT = mpcMapList;
end


%% Pre-allocate variables
% Determine fixed and manipulate grating contrast
redCon  = P.initialContrast;
blueCon = P.initialContrast;

% Luminance
if strcmp(location,'debug')
    P.Red = [255 0 0];
    P.Blue = [0 0 255];
elseif strcmp(location,'behavioural')
    P.Red = [255 0 0]/2;
    P.Blue = [0 0 255];
end

%% Initialize PTB
KbName('UnifyKeyNames')
% Screen('Preference', 'SkipSyncTests', 1);
[wPtr, rect] = Screen('OpenWindow', P.screen, P.backgroundColour, P.resolution);
[xCenter, yCenter] = RectCenter(rect);


Screen('TextStyle', wPtr, 1)
Screen('Preference', 'DefaultFontSize', P.fontSize);
Screen('Preference', 'DefaultFontName', P.fontName);
Screen('TextSize', wPtr, P.fontSize);
Screen('TextFont', wPtr, P.fontName);

enabledKeys = [KbName('ESCAPE'), KbName(P.leftKey), KbName(P.rightKey), KbName(P.keys), KbName('5%')]; % escape key for interrruption, 5 for scanner trigger
RestrictKeysForKbCheck(enabledKeys); % this speeds up KbCheck

if ~isempty(P.calibrationFile)
    hardwareCLUT = Screen('LoadCLUT', wPtr);
    Screen('LoadCLUT', wPtr, P.CLUT); % Loads gamma-corrected CLUT
end

Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_DST_ALPHA)%GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
refreshDur = Screen('GetFlipInterval',wPtr);
slack = refreshDur / 2;

%% Create Stimuli
% fixation cross
fixDiam = ceil(P.fixRadiusInDegree*P.pixPerDeg);
fixRect = [0 0 fixDiam fixDiam];
cueRect = [0 0 fixDiam*2 fixDiam*2];
fixBgd = zeros(fixDiam,fixDiam,2);
fixTexture = Screen('MakeTexture', wPtr, fixBgd);
elDiam = floor(fixDiam/3);
Screen('FillArc',fixTexture,255,CenterRect([0 0 elDiam elDiam],fixRect),255,360);
Screen('FrameArc',fixTexture,255,CenterRect([0 0 fixDiam fixDiam],fixRect),0,360,elDiam/2,elDiam/2);
% make grating stimulus 
stimRect    = [0 0 P.stimSizeInPix(1) P.stimSizeInPix(2)];
stim        = makeGrating(P,'Surya');

% Make the texture for the fixed grating
stimTexture = Screen('MakeTexture',wPtr,stim);

% Create cue
cueTexture = Screen('MakeTexture', wPtr, fixBgd);
Screen('FillArc',cueTexture,1,CenterRect([0 0 fixDiam*2 fixDiam*2],cueRect),0,360);

% Create vividness rating
confRect = [0 0  P.lineLengthPix P.lineLengthPix];
lineImg = makeLine(P.lineLengthPix, P.lineLengthPix, P.lineDiamPix);%, ceil(sqrt((fixDiam)^2+(fixDiam)^2)/2)); % at this point the lineImg is still an inverse, i.e. member pixels are 1
lineImg = cat(3, ones(size(lineImg))*255, lineImg*255); % alpha layer with member pixels opaque, revealing a uniform luminance layer with brightness defined by matchContrast
confTexture = Screen('MakeTexture', wPtr, lineImg);

sliderRect = [0 0 P.sliderLengthPix P.sliderLengthPix];
lineImg = makeLine(P.sliderLengthPix, P.sliderLengthPix, P.lineDiamPix)';%, ceil(sqrt((fixDiam)^2+(fixDiam)^2)/2)); % at this point the lineImg is still an inverse, i.e. member pixels are 1
lineImg = cat(3, ones(size(lineImg))*255, lineImg*255); % alpha layer with member pixels opaque, revealing a uniform luminance layer with brightness defined by matchContrast
sliderTexture = Screen('MakeTexture', wPtr, lineImg);

%% Standby screen until start
if P.situation ~= 3 % debug, BEH, MEG
    % Emulate scanner
    message = 'Press J for red stimulus and L for blue stimulus \n Press left key to start';    % Trigger string
else % MRI
    message = 'Stand by for scan';    % Trigger string
end
stimCenter = CenterRect(stimRect,rect);
Screen('FillRect', wPtr, P.backgroundColour, rect);

Screen('DrawTexture',wPtr,stimTexture,[], [stimCenter(1)/2 stimCenter(2)+P.stimSizeInPix(1) stimCenter(1)/2+P.stimSizeInPix(1) stimCenter(4)+P.stimSizeInPix(1) ], 45, [], [], P.Red*redCon)
Screen('DrawTexture',wPtr,stimTexture,[], [stimCenter(1)+stimCenter(1)/2 stimCenter(2)+P.stimSizeInPix(1) stimCenter(1)+stimCenter(1)/2+P.stimSizeInPix(1) stimCenter(4)+P.stimSizeInPix(1) ], 135, [], [], P.Blue*blueCon)

DrawFormattedText(wPtr, P.retroCueID{1}, P.midX-(stimCenter(1)-stimCenter(1)/2), P.midY-P.stimSizeInPix(1)/2+P.stimSizeInPix(1)*2.5, [255 255 255], [], [], [], 1.5);
DrawFormattedText(wPtr, P.retroCueID{2}, P.midX+(stimCenter(1)-stimCenter(1)/2), P.midY-P.stimSizeInPix(1)/2+P.stimSizeInPix(1)*2.5, [255 255 255], [], [], [], 1.5);
DrawFormattedText(wPtr, message, 'center', 'center', [255 255 255], [], [], [], 1.5);
Screen('Flip', wPtr);

% Wait for start of experiment
if P.situation == 0 % debug
    KbWait(-3,2);
elseif P.situation == 1 || P.situation == 2 % BEH || MEG
    BitsiBB.clearResponses();
    firstButtonPress = 0;
    while firstButtonPress == 0
        while BitsiBB.numberOfResponses() == 0
            WaitSecs(0.001);
        end
        [resp] = BitsiBB.getResponse(0.001, true);
        if resp == P.leftKey
            firstButtonPress = 1;
        end
    end
end

% define start of the experiment
T.startTime = GetSecs;

%% Timing calculation
flipmisscount = 0;

T.timings = zeros(P.nTrials,7);
T.realtimings = zeros(P.nTrials,7);

trialOnset     = 1;
cueOnset       = 2;
imageryOnset   = 3;
confOnset      = 4;
BRstimOnset    = 5;
responseOnset  = 6;
responseOffset = 7;


%% Some initiation of variables 

triggers = zeros(3000,2);
triggerCount = 1;

B = zeros(P.nTrials,6); % behavioural data
responseConf = 1;
confStartTime = 2;
confEndTime = 3; 
confReverse = 4; % scale reversed?
trialResponse = 5;
trialRT = 6;

%% Start trials
for iTrial = 1:P.nTrials
   
    %% Determine timings
    if iTrial == 1
        T.timings(iTrial,trialOnset) = T.startTime + P.fix;
    else
        T.timings(iTrial,trialOnset) = T.timings(iTrial-1,responseOffset) + (P.ITIrange(1) + (P.ITIrange(2)-P.ITIrange(1)).*rand(1));
    end
    
    T.timings(iTrial,cueOnset) = T.timings(iTrial,trialOnset) + P.startDur + P.postStartDur;

    T.timings(iTrial,imageryOnset) = T.timings(iTrial,cueOnset) + P.cueDur;
    
    T.timings(iTrial,confOnset) = T.timings(iTrial,imageryOnset) + P.imageryDur;
    
    T.timings(iTrial,BRstimOnset) = T.timings(iTrial,confOnset) + P.confDur;
    
    T.timings(iTrial,responseOnset) = T.timings(iTrial,BRstimOnset) + P.BRstimDur;
        
    %% Fixation point
    Screen('DrawTexture', wPtr, cueTexture, [], CenterRect(fixRect,rect));
    currTime = Screen('Flip', wPtr, T.timings(iTrial,trialOnset)-slack);
    T.realtimings(iTrial,trialOnset) = currTime - T.startTime;
    
    % Send trigger
    triggerCount = triggerCount + 1;
   
    triggers(triggerCount,:) = [P.triggerStart, T.realtimings(iTrial,trialOnset)];
    if P.situation == 2 % MEG
        BitsiBB.sendTrigger(P.triggerCue); % 
    end
    
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,trialOnset)+P.startDur-slack);
    
    %% Present cue
    Screen('DrawTexture', wPtr, cueTexture, [], CenterRect(fixRect,rect)); % Draws cue
    DrawFormattedText(wPtr, P.retroCueID{P.trialMatrix(iTrial,1)}, 'center', 'center', P.retroCueColour);
    currTime = Screen('Flip', wPtr, T.timings(iTrial,cueOnset)-slack);
    T.realtimings(iTrial,cueOnset) = currTime - T.startTime;
    
    % Send trigger
    triggerCount = triggerCount + 1;
    triggerCode = P.triggerCue+P.trialMatrix(iTrial,1);
    triggers(triggerCount,:) = [triggerCode, T.realtimings(iTrial,cueOnset)];
    if P.situation == 2 % MEG
        BitsiBB.sendTrigger(triggerCode);
    end
    
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,cueOnset)+P.cueDur-slack);

    %% Imagery
    Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    currTime = Screen('Flip', wPtr, T.timings(iTrial,imageryOnset)-slack);
    T.realtimings(iTrial,imageryOnset) = currTime - T.startTime;    
    
    %% Vividness rating
    
    % Show the screen
    Reverse = 0;%randi(2)-1; % reverse scale or not?
    if ~Reverse
        message = sprintf('How vivid was your imagery? \n Not vivid \t \t \t \t \t Very vivid');
    elseif Reverse
        message = sprintf('How vivid was your imagery? \n Very vivid \t \t \t \t \t Not vivid');
    end
    DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5); 
    Screen('DrawTexture', wPtr, confTexture, [], CenterRect(confRect,rect)); % pre-draw confidence scale
    Screen('DrawTexture', wPtr, sliderTexture, [], CenterRect(sliderRect,rect)); % pre-draw confidence line
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    lastFlip = Screen('Flip', wPtr,T.timings(iTrial,confOnset)-slack);
    T.realtimings(iTrial,confOnset) = lastFlip - T.startTime;
    
    startResponse = lastFlip;
    T.trials(iTrial,2) = startResponse - T.startTime;
    
    nextFlip = lastFlip + 1/P.frameHz; % update every frame
    FlushEvents('KeyDown');
    
    lateralMovement = 0;
    prevLoc = 0;
    firstKeyPress = true;
    keyPress = false;
    keyPressStart = 0;
    keyPressKey = 0;
    timeStamp = lastFlip;
    B(iTrial,confStartTime) = NaN;
    B(iTrial,confEndTime) = NaN;
    B(iTrial,confReverse) = Reverse;
    
    while nextFlip < (startResponse + P.confDur)
        while timeStamp < nextFlip - slack
            
            if P.situation == 0 || P.situation == 1
                
                [keyIsDown, timeStamp, keyCode] = KbCheck(-3);
                key = KbName(keyCode);
                
                if keyPress
                    if keyIsDown
                        if any(strcmp(keyPressKey, key))
                            time = timeStamp - keyPressStart;
                            if time>0 % prevent weird things happening if time becomes negative through clock inaccuracies
                                dtLoc = 218*time^(2.13);
                                switch keyPressKey
                                    case P.leftKey
                                        lateralMovement = prevLoc - dtLoc;
                                    case P.rightKey
                                        lateralMovement = prevLoc + dtLoc;
                                end
                            end
                        else
                            keyPress = false; % if none of the keys being pressed are the key that started the keypress, that ends the keypress
                            B(iTrial,confEndTime) = timeStamp - startResponse; % note that matchEnd can be updated several times during the match interval - it's the last one that matters
                        end
                    else
                        keyPress = false; % if no keys are being pressed, that ends the keypress
                        B(iTrial,confEndTime) = timeStamp - startResponse;
                    end
                else
                    if keyIsDown
                        if ~iscell(key) % only start a keypress if there is only one key being pressed
                            if any(strcmp(key, {P.leftKey, P.rightKey}))
                                keyPress = true;
                                keyPressKey = key;
                                keyPressStart = timeStamp;
                                prevLoc = lateralMovement;
                                if firstKeyPress
                                    firstKeyPress = false;
                                    B(iTrial,confStartTime) = timeStamp - startResponse;
                                end
                            elseif strcmp(key, 'ESCAPE')
                                save(fullfile(outputPath,saveName)); % save everything
                                Screen('FillRect', wPtr, P.backgroundColour, rect);
                                DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                                Screen('Flip',wPtr);
                                WaitSecs(0.5);
                                ShowCursor;
                                if P.situation ~= 0 && ~isempty(P.calibrationFile)
                                    Screen('LoadCLUT', wPtr, hardwareCLUT);
                                end
                                Screen('CloseAll');
                                disp(' ');
                                disp('Experiment aborted by user!');
                                disp(' ');
                                return
                                
                            end % exit on Escape press
                        end
                    end
                end % end keypress
                
            elseif P.situation == 2 || P.situation == 3
                
                timeout = 0.001;
                [responseKey, timeStamp]= getResponse(BitsiBB, timeout, true);
                
                if keyPressKey == P.leftKey || keyPressKey == P.rightKey
                    
                    time = timeStamp - keyPressStart;
                    if time>0 % prevent weird things happening if time becomes negative through clock inaccuracies
                        
                        dtLoc = 218*time^(2.13);
                        switch keyPressKey
                            case P.leftKey
                                lateralMovement = prevLoc - dtLoc;
                            case P.rightKey
                                lateralMovement = prevLoc + dtLoc;
                        end
                    end
                elseif keyPressKey == P.leftKeyOff || keyPressKey == P.rightKeyOff
                    prevLoc = lateralMovement;
                    B(iTrial,confEndTime) = timeStamp - startResponse;
                    keyPressKey = 0;
                end
                
                if responseKey ~= 0
                    keyPressKey = responseKey;
                    keyPressStart = timeStamp;
                    prevLoc = lateralMovement;
                    if firstKeyPress
                        firstKeyPress = false;
                        B(iTrial,confStartTime) = keyPressStart - startResponse;
                    end
                else
                end
            end
        end
        
        updatedX = round(P.midX+lateralMovement);
        if updatedX < (P.midX+P.lineLengthPix/2) && updatedX > (P.midX-P.lineLengthPix/2) % if confidence is still on the bar
            updatedSliderRect = [updatedX-P.sliderLengthPix/2 P.midY-P.sliderLengthPix/2 ...
                updatedX+P.sliderLengthPix/2 P.midY+P.sliderLengthPix/2];
        elseif updatedX > (P.midX+P.lineLengthPix/2) % if confidence is max
            updatedSliderRect = [(P.midX+P.lineLengthPix/2-P.sliderLengthPix/2) P.midY-P.sliderLengthPix/2 ...
                (P.midX+P.lineLengthPix/2+P.sliderLengthPix/2) P.midY+P.sliderLengthPix/2];
            lateralMovement = P.lineLengthPix/2;
        elseif updatedX < (P.midX-P.lineLengthPix/2) % if confidence is min
            updatedSliderRect = [(P.midX-P.lineLengthPix/2-P.sliderLengthPix/2) P.midY-P.sliderLengthPix/2 ...
                (P.midX-P.lineLengthPix/2+P.sliderLengthPix/2) P.midY+P.sliderLengthPix/2];
            lateralMovement = -(P.lineLengthPix/2);
        end
        
        confContrast = max(0, 1 - max(0,(nextFlip - (startResponse + P.confDim)))/((startResponse + P.confDur) - (startResponse + P.confDim)));
        Screen('DrawTexture', wPtr, confTexture, [], CenterRect(confRect,rect), [], [], confContrast);
        Screen('DrawTexture', wPtr, sliderTexture, [], updatedSliderRect, [], [], confContrast);
        Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
        DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5);
        Screen('DrawingFinished', wPtr);
        lastFlip = Screen('Flip', wPtr);
        if abs(lastFlip - nextFlip) >= 1/P.frameHz, flipmisscount = flipmisscount + 1; end
        nextFlip = lastFlip + 1/P.frameHz;
    end
    
    B(iTrial,responseConf) = round(lateralMovement);      
    
    %% BR stimulus presentation    
    
   % Present stimulus
    Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
    
    % draw the red grating   
    Screen('DrawTexture',wPtr,stimTexture,[], CenterRect(stimRect,rect), 45, [], [], P.Red*redCon)

    % draw the blue grating
    Screen('DrawTexture',wPtr,stimTexture,[], CenterRect(stimRect,rect), 135, [], [], P.Blue*blueCon)

    % fixation cross
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    
    
    currTime = Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)-slack);
    T.realtimings(iTrial,BRstimOnset) = currTime - T.startTime;
    
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)+P.BRstimDur-slack);
    
    %% Response
    % Present the response screen

    message = sprintf('Which image did you see most? \n \n Red [J], perfeclty mixed [K] or blue [L]');
    DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5); 
    currTime = Screen('Flip', wPtr,T.timings(iTrial,responseOnset)-slack);
    T.realtimings(iTrial,responseOnset) = currTime - T.startTime;
    
    % Send trigger
    triggerCount = triggerCount + 1;
    triggerCode = P.triggerResponseOnset;
    triggers(triggerCount,:) = [triggerCode, T.realtimings(iTrial,responseOnset)];
    if P.situation == 2 % MEG
        BitsiBB.sendTrigger(triggerCode);
    end     
    
    % clear key presses 
    if P.situation == 0 || P.situation == 1
        keyPressed = 0; % If previously key was pressed
    elseif P.situation == 2 || P.situation == 3
        BitsiBB.clearResponses(); % Clear Button Box responses
    end
    
    % wait for the response
    while GetSecs < (T.timings(iTrial,responseOnset)+ P.responseDur - slack) && ~keyPressed
        
        if P.situation == 0 || P.situation == 1
            
            [~, keyTime, keyCode] = KbCheck(-3);
            key = KbName(keyCode);
            
            if ~iscell(key) % only start a keypress if there is only one key being pressed
                if any(strcmp(key, P.keys))
                    
                    response = find(strcmp(key,P.keys));                    
                    
                    % fill in B
                    B(iTrial,trialResponse) = response;
                    B(iTrial,trialRT) = (keyTime-T.startTime) -T.realtimings(iTrial,responseOnset); 
                    
                    % fill in timings
                    T.timings(iTrial,responseOffset) = keyTime; 
                    
                    keyPressed = true;
                    
                    % Send trigger
                    triggerCount = triggerCount + 1;
                    triggerCode = P.triggerResponse+response;
                    triggers(triggerCount,:) = [triggerCode, keyTime-T.startTime];                    
                    
                    
                elseif strcmp(key, 'ESCAPE')
                    Screen('FillRect', wPtr, P.backgroundColour, rect);
                    DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                    Screen('Flip',wPtr);
                    WaitSecs(0.5);
                    ShowCursor;
                    if P.situation ~= 0 && ~isempty(P.calibrationFile)
                        Screen('LoadCLUT', wPtr, hardwareCLUT);
                    end
                    Screen('CloseAll');
                    disp(' ');
                    disp('Experiment aborted by user!');
                    disp(' ');
                    save(fullfile(outputPath,saveName)); % save everything
                    return
                end 
            end
            
            WaitSecs(0.001);
            
        elseif P.situation == 2 || P.situation == 3
            
            timeout = .001;
            [key, keyTime] = BitsiBB.getResponse(timeout, 'true');
            if keyPressKey == P.leftKey || keyPressKey == P.rightKey
                if key == P.leftKey
                    response = 1;
                elseif key == P.rightKey
                    response = 2;
                end
                
                B(iTrial,trialResponse) = response;
                B(iTrial,trialRT) = keyTime-T.realtimings(iTrial,probeOnset)-T.startTime; 
                
                T.timings(iTrial,probeOffset) = keyTime; 
                
                % Send trigger
                triggerCount = triggerCount + 1;
                triggerCode = P.triggerResponse+response;
                triggers(triggerCount,:) = [triggerCode, keyTime-T.startTime];
                if P.situation == 2 % MEG 
                    BitsiBB.sendTrigger(triggerCode);
                end
                    
            elseif strcmp(key, 'ESCAPE')
                Screen('FillRect', wPtr, P.backgroundColour, rect);
                DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                Screen('Flip',wPtr);
                WaitSecs(0.5);
                ShowCursor;
                if P.situation ~= 0 && ~isempty(P.calibrationFile)
                    Screen('LoadCLUT', wPtr, hardwareCLUT);
                end
                Screen('CloseAll');
                disp(' ');
                disp('Experiment aborted by user!');
                disp(' ');
                save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything
                return
            end
            WaitSecs(0.001); 
            
        end
    end
    
    if B(iTrial,trialResponse)==0 % if not in time with key press
        T.timings(iTrial,responseOffset) = T.timings(iTrial,responseOnset)+P.responseDur;
    end
    
    % show fixation again
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    currTime = Screen('Flip', wPtr, T.timings(iTrial,responseOffset));
    T.realtimings(iTrial,responseOffset) = currTime - T.startTime;
    
    
    %% Trial end
    T.trialEnd(iTrial) = currTime - T.startTime;
    
end % end Trial

Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
currTime = Screen('Flip', wPtr);
while (GetSecs - currTime < P.fix - slack)
    WaitSecs(0.001);
end

%% Save workspace
save(fullfile(outputPath,saveName)); % save everything

%% Last flip
T.endTime = Screen('Flip', wPtr);
if ~isempty(P.calibrationFile)
    Screen('LoadCLUT', wPtr, hardwareCLUT);
end
Screen('CloseAll');
ShowCursor;

disp('Experiment done');
disp(['Experiment duration: ' num2str([T.endTime]) ' seconds']);

%% Clean up
if P.situation == 2 % BEH or MEG
    close(BitsiBB);
    delete(instrfind);
elseif P.situation == 3 % MRI
    close(BitsiScanner);
    close(BitsiBB);
    delete(instrfind);
end

% clean up triggers
triggers((triggers(:,1)==0),:) = [];

%% Experiment duration
exptDuration = T.endTime - T.startTime;
exptDurMin = floor(exptDuration/60);
exptDurSec = ceil(mod(exptDuration, 60));
fprintf('Cycling lasted %d minutes, %d seconds\n', exptDurMin, exptDurSec);
fprintf(['\nBy my own estimate, Screen(''Flip'') missed the requested screen retrace ', num2str(flipmisscount), ' times\n']);



