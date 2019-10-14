function matrix = makeLinearMaskCircleAnn(size2, size1, startLinearDecay, rThresh)

% rThresh defines annulus

% use linspace
% use meshgrid

%[x,y] = meshgrid(linspace(-1,1,size2));

matrix = zeros(size1, size2);

for hor = 1:size2
    for ver = 1:size1
        if ((hor-size2/2)^2 + (ver-size1/2)^2) < ((size2/2)^2) && ((hor-size2/2)^2 + (ver-size1/2)^2) > ((rThresh/2)^2)
            matrix(hor,ver) = 1; % Fills circle of radius1 with idx1
        end
    end
end

ramp = linspace(0,1,startLinearDecay);

for ver = 1:size2
    for hor = 1:size1
        for i = 1:startLinearDecay
            if ((hor-size2/2)^2 + (ver-size1/2)^2) < ((size2/2) - (i-1))^2 && ((hor-size2/2)^2 + (ver-size1/2)^2) > ((size2/2) - (i+1))^2
                matrix(ver,hor) = ramp(i); % Fills circle of radius1 with value between 0 and 1            
            end   
        end
    end
end

% imagesc(matrix);
% colormap(gray(256));