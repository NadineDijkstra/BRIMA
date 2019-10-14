function BRima_task(P)

%   BRima_task(P)
%
%   Binocular rivalry imagery task  (after Bergmann et al. (2016). Cerebral
%   Cortex). 
%
%   P:    Struct containing various parameters
%
%   Written by ND in NOV 2017, adapted in JAN 2018

%% Start bitsi_scanner
if P.situation == 2 % MEG
    BitsiBB = bitsi_scanner('com1'); %/dev/ttyS1');
elseif P.situation == 3 % MRI
    BitsiBB = bitsi_scanner('com1'); %'/dev/ttyS1');
    BitsiScanner = bitsi_scanner('com3'); %/dev/ttyS2');
end

%% Initialize PTB
[wPtr, rect] = Screen('OpenWindow', P.screen, P.backgroundColour, P.resolution);
[xCenter, yCenter] = RectCenter(rect);

% if P.windows, P.fontSize = round(P.fontSize * 72/96); end % fix the Mac/windows font size problem
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


%% Create fixation cross
fixDiam = ceil(P.fixRadiusInDegree*P.pixPerDeg);
fixRect = [0 0 fixDiam fixDiam];
cueRect = [0 0 fixDiam*2 fixDiam*2];
fixBgd = zeros(fixDiam,fixDiam,2);
fixTexture = Screen('MakeTexture', wPtr, fixBgd);
elDiam = floor(fixDiam/3);
Screen('FillArc',fixTexture,255,CenterRect([0 0 elDiam elDiam],fixRect),255,360);
Screen('FrameArc',fixTexture,255,CenterRect([0 0 fixDiam fixDiam],fixRect),0,360,elDiam/2,elDiam/2);

%% Create cue
cueTexture = Screen('MakeTexture', wPtr, fixBgd);
Screen('FillArc',cueTexture,1,CenterRect([0 0 fixDiam*2 fixDiam*2],cueRect),0,360);

%% Create stim
% grating
stimRect    = [0 0 P.stimSizeInPix(1) P.stimSizeInPix(2)];
stim        = makeGrating(P,'Surya');

% Make the stimulus texture
stimTexture = Screen('MakeTexture',wPtr,stim);

% Make MOCK stim
mock_red=stim';
mock_blue=stim;
amp=27;
EE=smooth((smooth(amp*randn(1, P.stimSizeInPix(1)), 30))+round(P.stimSizeInPix(1)/2)); % was 100 at the end
EE=round(EE);

for loop=1:P.stimSizeInPix(1)
    
    mock_red(1:(EE(loop)), loop)=0;
    mock_blue((EE(loop)):P.stimSizeInPix(1), loop)=0;
    
end

redmockTexture = Screen('MakeTexture',wPtr,mock_red);
bluemockTexture = Screen('MakeTexture',wPtr,mock_blue);

redCon  = P.initialContrast;
blueCon = P.initialContrast;

% make into texture
%mockTexture = Screen('MakeTexture',wPtr,Pattern_Mock);

%% Create vividness rating
confRect = [0 0  P.lineLengthPix P.lineLengthPix];
lineImg = makeLine(P.lineLengthPix, P.lineLengthPix, P.lineDiamPix);%, ceil(sqrt((fixDiam)^2+(fixDiam)^2)/2)); % at this point the lineImg is still an inverse, i.e. member pixels are 1
lineImg = cat(3, ones(size(lineImg))*255, lineImg*255); % alpha layer with member pixels opaque, revealing a uniform luminance layer with brightness defined by matchContrast
confTexture = Screen('MakeTexture', wPtr, lineImg);

sliderRect = [0 0 P.sliderLengthPix P.sliderLengthPix];
lineImg = makeLine(P.sliderLengthPix, P.sliderLengthPix, P.lineDiamPix)';%, ceil(sqrt((fixDiam)^2+(fixDiam)^2)/2)); % at this point the lineImg is still an inverse, i.e. member pixels are 1
lineImg = cat(3, ones(size(lineImg))*255, lineImg*255); % alpha layer with member pixels opaque, revealing a uniform luminance layer with brightness defined by matchContrast
sliderTexture = Screen('MakeTexture', wPtr, lineImg);

%% Standby screen
if P.situation ~= 3 % debug, BEH, MEG
    % Emulate scanner
    message = 'Press left key to start';    % Trigger string
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

%% Wait for start of experiment
if P.situation == 0 || P.situation == 1 % debug or behaviour
    KbWait(-3,2);
elseif P.situation == 2 % BEH || MEG
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
elseif P.situation == 3 % MRI
    BitsiScanner.clearResponses();
    firstScan = 0;
    while firstScan == 0
        while BitsiScanner.numberOfResponses() == 0
            WaitSecs(0.001);
        end
        [resp] = BitsiScanner.getResponse(0.001, true);
        if resp == P.leftKey
            firstScan = 1;
        end
    end
end

% define start of the experiment
T.startTime = GetSecs;

%% Fixation block before start of run
if P.fix > 0
    Screen('FillRect', wPtr, P.backgroundColour, rect);
    Screen('DrawTexture', wPtr, fixTexture, fixRect, CenterRect(fixRect, rect));
    Screen('Flip', wPtr);
    WaitSecs(P.fix-2*slack);
end

%% Timing calculation
flipmisscount = 0;

T.timings = zeros(P.nTrialsPerRun,11);
T.realtimings = zeros(P.nTrialsPerRun,11);

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

B = zeros(P.nTrialsPerRun,8); % behavioural data
responseConf = 1;
confStartTime = 2;
confEndTime = 3; 
confReverse = 4; % scale reversed?
trialResponse = 5;
trialRT = 6;

C = zeros(P.nTrialsPerRun,6); % contrasts
redConC = 1:3;
blueConC = 4:6;

%% Start trials
for iTrial = 1:P.nTrialsPerRun
   
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
                                save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything
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
    
   % Present stimulus frame
    Screen('FrameRect', wPtr, 255, CenterRectOnPointd(P.baseRect, xCenter, yCenter), 3);
    
    if P.trialMatrix(iTrial,2) == 99 % Mock trial        
             
        % draw the red grating   
        Screen('DrawTexture',wPtr,redmockTexture,[], CenterRect(stimRect,rect), 135, [], [], P.Red*redCon)

        % draw the blue grating
        Screen('DrawTexture',wPtr,bluemockTexture,[], CenterRect(stimRect,rect), 135, [], [], P.Blue*blueCon)

    else
    
    % draw the red grating  
    C(iTrial,redConC) = P.Red*P.trialMatrix(iTrial,1+1);
    Screen('DrawTexture',wPtr,stimTexture,[], CenterRect(stimRect,rect), 45, [], [], C(iTrial,redConC))

    % draw the blue grating
    C(iTrial,blueConC) = P.Blue*P.trialMatrix(iTrial,2+1);
    Screen('DrawTexture',wPtr,stimTexture,[], CenterRect(stimRect,rect), 135, [], [], C(iTrial,blueConC))
    end
    
    % fixation cross
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    
    currTime = Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)-slack);
    T.realtimings(iTrial,BRstimOnset) = currTime - T.startTime;
    
    % Send trigger
    triggerCount = triggerCount + 1;
    triggerCode = str2double(sprintf('%.0f%.0f',P.trialMatrix(iTrial,2)*100,P.trialMatrix(iTrial,3)*100)); % Red contrast, blue contrast 
    triggers(triggerCount,:) = [triggerCode, T.realtimings(iTrial,BRstimOnset)];
    if P.situation == 2 % MEG
        BitsiBB.sendTrigger(triggerCode);
    end
    
    Screen('DrawTexture', wPtr, fixTexture, [], CenterRect(fixRect,rect));
    Screen('Flip', wPtr, T.timings(iTrial,BRstimOnset)+P.BRstimDur-slack);
    
    %% Response
    % Present the response screen

    message = sprintf('Which image did you see most? \n \n Red [J], perfectly mixed [K] or blue [L]');
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
                    save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything
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
                return;
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
save(fullfile(P.dataPath, [P.sessionName '.mat'])); % save everything

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



