function radframe=arraytorad(framesize,array,interpol)

% ------------------------------------------------------------------------
% 
% Creates a 2D matrix, containing a circle with diameter "framesize" and 
% profile "array"
%
%
% INPUT:
% 
% - framesize: diameter (rect) of the desired circle in pixels
% - array: 1D array with pixel values along the circle radius
% - interpol (optional): computes linear average of pixel values along
%   hypothenusae.
%
%
% SG 2014
%
% ------------------------------------------------------------------------

maxhypo=ceil(sqrt((framesize/2)^2+(framesize/2)^2));
if maxhypo>size(array,2);
    array=[array (ones(1,maxhypo-length(array))*array(end))];
end
array=[array(1) array];

% compute hypothenusae
[xvals yvals] = meshgrid(1:framesize);
hypos = sqrt((xvals-.5*framesize-.5).^2+(yvals-.5*framesize-.5).^2);

% project pixel values from array along hypothenusae
radframe=ones(size(hypos));
if nargin<3||interpol==0; 
   hypos=round(hypos);
   radframe(hypos==hypos)=array(hypos+1);
else % if linear interpolation
    hyposdec=hypos(:,:)-floor(hypos(:,:));
    radframe(ceil(hypos)==ceil(hypos))=array(floor(hypos)+1)+(array(ceil(hypos)+1)-array(floor(hypos)+1)).*(hyposdec);
end
