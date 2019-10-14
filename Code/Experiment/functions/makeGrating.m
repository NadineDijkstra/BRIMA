function stim = makeGrating(P,method)

    
nColours    = 255;

% shared settings
stepsize    =   pi/P.cosEdge; % make the mask
cosramp     =   cos( pi+stepsize : stepsize : 2*pi);
myramp      =   [ones(1, floor( (P.gaborSize/2) ) - P.cosEdge) fliplr( (cosramp+1)/2) 0];
cosmask 	=   arraytorad(P.gaborSize, myramp,1);
    
switch method
    
    case 'Surya'
        
        stepsize    =   (2*pi*P.nCycles)/P.gaborSize; % make the grating
        sinwav      =   sin(linspace(P.Phase,(2*pi*P.nCycles)-stepsize,P.gaborSize ));% * P.initialContrast;
        sinwav      =   (sinwav+1)/2; 
        if ~isempty(P.calibrationFile) % create more black
        sinwav = (sinwav-0.25); sinwav(sinwav < 0) = 0; sinwav = sinwav.*1.3333;
        else
            sinwav = (sinwav+0.35); sinwav(sinwav > 1) = 1; %sinwav = sinwav./1.3333;
        end
        singrat     =   repmat( sinwav, size( sinwav,2), 1);
        mytarg      =   singrat .* cosmask; % combine grating and mask
        stim        =   mytarg*nColours;
                
    case 'Pearson'
        
        %% Keogh and Pearson's way
        
        % Pattern Creation %%
        widthOfGrid = P.stimSizeInPix(1)-1;
        halfWidthOfGrid = widthOfGrid / 2;
        widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.
        [x,y] = meshgrid(widthArray, widthArray);
        
        % cardinals
        grat_angle=pi/2; 
        
        %%%%%%%%%% Masking
        gratingMatrix =(sin(P.Freq*2*pi/halfWidthOfGrid*(x.*sin(grat_angle)+y.*cos(grat_angle))-0));
        
        gratingMatrix= ((gratingMatrix*P.initialContrast)*nColours)+127;
        
        stim = gratingMatrix .* cosmask;
end