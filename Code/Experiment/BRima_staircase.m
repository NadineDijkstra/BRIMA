function BRima_staircase()

%   BRima_staircase(subjectID)
%
%   Binocular rivalry staircase to control for eye dominance (after 
%   Bergmann et al. (2016). Cerebral Cortex). 
%
%   Written by ND in NOV 2017

stepSize = 0.02; % how much the luminance goes up or down to adjust

%% Paths
addpath('functions')
currpath = pwd;
output = fullfile(currpath,'stairCase');
if ~exist(output,'dir'); mkdir(output); end

if nargin == 0
    subjectID = 'S00';
end

saveName = ['output_' subjectID];

%% Some parameters
P = struct;
P.datapath = '/debugData';
P.sessionName = 'test01';
P.situation   = 0;

% Trial numbers
P.nTrials = 20;

% Screen parameters
[frameHz,pixPerDeg,calibrationFile] = get_monitor_info('debug');

P.situation = 0; % 0 = Desktop, 1 = Behavioural, 2 = Trio, 3 = Random computer
P.frameHz          = frameHz;

P.pixPerDeg        = pixPerDeg;
P.calibrationFile  = calibrationFile;
P.screen           = 0; % main screen
P.resolution       = [750 50 1250 550]; % Screen('Rect', P.screen); %
P.midX             = (P.resolution(3)-P.resolution(1))/2+P.resolution(1);
P.midY             = (P.resolution(4)-P.resolution(2))/2+P.resolution(2);
P.yOffset          = 120;
P.backgroundColour = 0;
P.fontName         = 'Arial';
P.fontSize         = 26;

% Response parameters
P.leftKey   = 'j'; 
P.midKey    = 'k';
P.rightKey  = 'l';

% Luminance parameters
P.meanLum = 0.5;
P.contrast = 1;
P.stimContrast = 0.2;
P.amp = P.meanLum * P.contrast;

P.meanColourIdx = ceil((255)/2) -1; % mean colour number (0-255) of stimulus (used to index rows 1:256 in mpcmaplist)
P.ampColourIdx  = floor(P.stimContrast*(255-1)); % amplitude of colour variation for stimulus

% Stimulus parameters
P.stimSizeInDegree = 5;
P.distFromFixInDeg = 1;
P.distFromFixInPix = round(P.pixPerDeg * P.distFromFixInDeg);
P.stimSizeInPix = round([P.stimSizeInDegree*P.pixPerDeg P.stimSizeInDegree*P.pixPerDeg]);	% Width, height of stimulus
P.baseRect = [0 0 160 160]; % stimulus frame
P.fixRadiusInDegree = .6;

% Gabor grating
P.gaborSize  = round(P.stimSizeInPix/2);
P.backgroundOffset = [0 0 0 0.0];
P.initialContrast = 0.8;
P.Phase = 110;
P.Freq = 0.1;
P.preContrastMultiplier = 1;%0.5;

% Mask parameters
P.maskCentreInDegree = 0;
P.maskCentreInPixels = round(P.maskCentreInDegree*P.pixPerDeg);    % Middle of Gaussian envelope
P.startLinearDecayInDegree = .5;    % Linear decay starts .5 degree away from edge
P.startLinearDecayInPix = round(P.startLinearDecayInDegree*P.pixPerDeg);
P.maskThresh = 0; %round(P.stimSizeInPixels(2)/2);
P.mask = makeLinearMaskCircleAnn(P.stimSizeInPix(2),P.stimSizeInPix(1), P.startLinearDecayInPix, P.maskThresh); % Creates mask

% Time Parameters          	
P.startDur          = 0.4;
P.postStartDur      = 0.3;
P.stimDur           = 4; % 4 seconds intervening stimulus
P.BRstimDur         = 0.75;
P.responseDur       = 2; % so slow, then continue
P.ISIrange          = [0.4, 0.6];

%% Initialize PTB
[wPtr, rect] = Screen('OpenWindow', P.screen, P.backgroundColour, P.resolution);
[xCenter, yCenter] = RectCenter(rect);

Screen('TextStyle', wPtr, 1)
Screen('Preference', 'DefaultFontSize', P.fontSize);
Screen('Preference', 'DefaultFontName', P.fontName);
Screen('TextSize', wPtr, P.fontSize);
Screen('TextFont', wPtr, P.fontName);

enabledKeys = [KbName('ESCAPE'), KbName(P.leftKey), KbName(P.rightKey), KbName(P.midKey), KbName('5%')]; % escape key for interrruption, 5 for scanner trigger
RestrictKeysForKbCheck(enabledKeys); % this speeds up KbCheck

if P.situation ~= 0 && ~isempty(P.calibrationFile)
    hardwareCLUT = Screen('LoadCLUT', wPtr);
    Screen('LoadCLUT', wPtr, P.CLUT); % Loads gamma-corrected CLUT
end

Screen('BlendFunction', wPtr, GL_SRC_ALPHA, GL_DST_ALPHA)%GL_ONE_MINUS_SRC_ALPHA);
HideCursor;
refreshDur = Screen('GetFlipInterval',wPtr);
slack = refreshDur / 2;

%% Create Stimuli
%fixation cross
fixDiam = ceil(P.fixRadiusInDegree*P.pixPerDeg);
fixRect = [0 0 fixDiam fixDiam];
cueRect = [0 0 fixDiam*2 fixDiam*2];
fixBgd = zeros(fixDiam,fixDiam,2);
fixTexture = Screen('MakeTexture', wPtr, fixBgd);
elDiam = floor(fixDiam/3);
Screen('FillArc',fixTexture,255,CenterRect([0 0 elDiam elDiam],fixRect),255,360);
Screen('FrameArc',fixTexture,255,CenterRect([0 0 fixDiam fixDiam],fixRect),0,360,elDiam/2,elDiam/2);

% grating
stimRect = [0 0 P.stimSizeInPix(1) P.stimSizeInPix(2)];
gabortex = CreateProceduralGabor(wPtr, P.gaborSize(1),P.gaborSize(2), [],...
    P.backgroundOffset, 1, P.preContrastMultiplier);

% Create cue
cueTexture = Screen('MakeTexture', wPtr, fixBgd);
Screen('FillArc',cueTexture,1,CenterRect([0 0 fixDiam*2 fixDiam*2],cueRect),0,360);

%% Standby screen until start
if P.situation ~= 3 % debug, BEH, MEG
    % Emulate scanner
    message = 'Press left key to start';    % Trigger string
else % MRI
    message = 'Stand by for scan';    % Trigger string
end
Screen('FillRect', wPtr, P.backgroundColour, rect);
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

%% Pre allocate some variables
C = zeros(P.nTrials,2); % contrast values per trial
redContrast   = 1;
greenContrast = 2;

C(1,redContrast) = P.initialContrast; C(1,greenContrast) = P.initialContrast;

B = zeros(P.nTrials,2); % responses
trialResponse = 1;
trialRT       = 2;

S = zeros(P.nTrials,1); % which stimulus to show

%% Timing calculation
T.timings = zeros(P.nTrials,5);
T.realtimings = zeros(P.nTrials,5);

trialOnset     = 1;
BRstimOnset    = 2;
responseOnset  = 3;
responseOffset = 4;
stimOnset      = 5;

%% Start of the experiment
T.startTime = GetSecs;

for iTrial = 1:P.nTrials
    
    %% Determine timings
    if iTrial == 1
        T.timings(iTrial,trialOnset) = T.startTime;
    else
        T.timings(iTrial,trialOnset) = T.timings(iTrial-1,stimOnset) + P.stimDur + (P.ISIrange(1) + (P.ISIrange(2)-P.ISIrange(1)).*rand(1));
    end
       
    T.timings(iTrial,BRstimOnset) = T.timings(iTrial,trialOnset) + P.startDur + P.postStartDur;
 
    T.timings(iTrial,responseOnset) = T.timings(iTrial,BRstimOnset) + P.BRstimDur;      

    %% Fixation point
    Screen('DrawTexture', wPtr, cueTexture, [], CenterRect(fixRect,rect));
    currTime = Screen('Flip', wPtr, T.timings(iTrial,trialOnset)-slack);
    T.realtimings(iTrial,trialOnset) = currTime - T.startTime;
        
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,trialOnset)+P.startDur-slack);
    
    %% BR stimulus presentation    
    
    % Present stimulus
    Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
    
    % draw the red grating
    Screen('DrawTextures', wPtr, gabortex, [], CenterRect(stimRect,rect), 90, [], 0,[255,0,0], [],...
       kPsychDontDoRotation, [P.Phase, P.Freq, P.stimSizeInPix(1)/7, C(iTrial,redContrast), 1 0, 0, 0]');
    
    % draw the green grating
    Screen('DrawTextures', wPtr, gabortex, [], CenterRect(stimRect,rect), 0, [], 0,[0,255,0], [],...
       kPsychDontDoRotation, [P.Phase, P.Freq, P.stimSizeInPix(1)/7, C(iTrial,greenContrast), 1 0, 0, 0]');
    
    % fixation cross
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    
    currTime = Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)-slack);
    T.realtimings(iTrial,BRstimOnset) = currTime - T.startTime;
    
    %% Response
    % Present the response screen
     
    if iTrial > 1
    message = sprintf('Which grating did you see? \n Red [J], mixed [K] or green [L]');
    else
    message = sprintf('Which grating did you see? \n Red [J] or green [L]');        
    end
    
    DrawFormattedText(wPtr, message, 'center', P.midY-P.yOffset, [255 255 255], [], [], [], 1.5); 
    currTime = Screen('Flip', wPtr,T.timings(iTrial,responseOnset)-slack);
    T.realtimings(iTrial,responseOnset) = currTime - T.startTime;

    % clear key presses 
    if P.situation == 0
        keyPressed = 0; % If previously key was pressed
    elseif P.situation ~= 0
        BitsiBB.clearResponses(); % Clear Button Box responses
    end
    
    % wait for the response
    while ~keyPressed % just wait until the button press, otherwise we can't continue
        
            
            [~, keyTime, keyCode] = KbCheck(-3);
            key = KbName(keyCode);
            
            if ~iscell(key) % only start a keypress if there is only one key being pressed
                if any(strcmp(key, {P.leftKey,P.midKey,P.rightKey}))
                    
                    response = find(strcmp(key,{P.leftKey,P.midKey,P.rightKey}));                    
                    
                    % fill in B
                    B(iTrial,trialResponse) = response;
                    B(iTrial,trialRT) = (keyTime-T.startTime) -T.realtimings(iTrial,responseOnset); 
                    
                    % fill in timings
                    T.timings(iTrial,responseOffset) = keyTime; 
                    
                    keyPressed = true;
                                        
                elseif strcmp(key, 'ESCAPE')
                    Screen('FillRect', wPtr, P.backgroundColour, rect);
                    DrawFormattedText(wPtr, 'Experiment was aborted!', 'center', 'center', [255 255 255]);
                    Screen('Flip',wPtr);
                    WaitSecs(0.5);
                    ShowCursor;
                    if P.situation ~= 0 && ~isempty(P.calibrationFile)
                        Screen('LoadCLUT', wPtr, hardwareCLUT);
                    end
                    disp(' ');
                    disp('Experiment aborted by user!');
                    disp(' ');                    
                    Screen('CloseAll');
                    save(fullfile(output,saveName)); % save everything
                    return;
                    
                    
                end 
            end
            
            WaitSecs(0.001);
    end
    
    % fill in the timings
    T.timings(iTrial,stimOnset) = T.timings(iTrial,responseOffset) + (P.ISIrange(1) + (P.ISIrange(2)-P.ISIrange(1)).*rand(1));
    
    % determine which stimulus to show at full contrast
    if B(iTrial,trialResponse) == 1
        S(iTrial,1) = 1;
    elseif B(iTrial,trialResponse) == 3
        S(iTrial,1) = 2;
    elseif B(iTrial,trialResponse) == 2 
        S(iTrial,1) = S(iTrial-1,1); % if mixed, same as before
    end  
    
    % determine contrast next trial 
    if iTrial > 1
        if B(iTrial,trialResponse) == B(iTrial-1,trialResponse) || B(iTrial,trialResponse) == 2% if the same stimulus as before is dominant or if mixed
            C(iTrial+1,S(iTrial,1)) = C(iTrial,S(iTrial,1))-stepSize; % reduce contrast perceived stimulus with stepsize
            C(iTrial+1,3-S(iTrial,1)) = C(iTrial,3-S(iTrial,1))+stepSize; % enhance unperceived contrast
        else
            C(iTrial+1,:) = C(iTrial,:); % otherwise the contrast is fine
        end
    else
        C(iTrial+1,:) = C(iTrial,:);
    end
    
    % show fixation again
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    currTime = Screen('Flip', wPtr, T.timings(iTrial,responseOffset));
    T.realtimings(iTrial,responseOffset) = currTime - T.startTime;

    %% Show stimulus at full contrast
    
    % Present stimulus
    Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
    
    % draw the grating  
    
    if S(iTrial,1) == 1
    Screen('DrawTextures', wPtr, gabortex, [], CenterRect(stimRect,rect), 90, [], 0,[255,0,0], [],...
       kPsychDontDoRotation, [P.Phase, P.Freq, P.stimSizeInPix(1)/7, 1, 1 0, 0, 0]');
    elseif S(iTrial,1) == 2
    Screen('DrawTextures', wPtr, gabortex, [], CenterRect(stimRect,rect), 0, [], 0,[0,255,0], [],...
       kPsychDontDoRotation, [P.Phase, P.Freq, P.stimSizeInPix(1)/7, 1, 1 0, 0, 0]');
    end
    
    % fixation cross
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    
    currTime = Screen('Flip', wPtr, T.timings(iTrial,stimOnset)-slack);
    T.realtimings(iTrial,stimOnset) = currTime - T.startTime;
    
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,stimOnset)+P.stimDur-slack);
    
    % show fixation again
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,stimOnset)+P.stimDur-slack);
            
end