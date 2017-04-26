function [peaks valleys] = getPeaksValleys3D(data)
%To extract peaks and valleys from 3-D COMSOL non-linear analysis results
% Input: (PlateCoordinateFile)
% PlateCoordinateFile: File exported from COMSOL analysis that contains plate coordinates of the plate midplane
% Output: [peaks valleys]
% peaks = [peak_loc_para1(x value) peak_loc_para1(y value) peak_height_para1(z value)...]
% valleys = [valley_loc_para1(x value) valley_loc_para1(y value) valley_depth_para1(z value)... ]
% Data being read from file are: X,Y,Z coordinates and the deformed coordinates x,y,z
% Peask and vallyes are read for all parameters during parameter continuation in COMSOL
% Heights and depths are relative to undeformed mid-plane position
% Z is the mid-plane position at undeformed position (X,Y) (may include the initial imperfection)
% Displacements in all directions are exported even if displacements only along one/two directions are relevant

%% (C) Copyright <2013-2014> Massachusetts Institute of Technology. 

% Authors: Sourabh K. Saha and Martin L. Culpepper.

% This file is part of MeshPerturb.

% MeshPerturb is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License, Version 2 (GPL-2.0).

% MeshPerturb is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with MeshPerturb.  If not, see <http://www.opensource.org/licenses/GPL-2.0.php>.

% A separate proprietary license for MeshPerturb is available from the
% M.I.T. Technology Licensing Office, Massachusetts Institute of Technology,
% One Cambridge Center, Kendall Square, Room NE18-501, Cambridge, MA 02142-1601.
% Tel: 617-253-6966, Fax: 617-258-6790, email: tlo@mit.edu. 

 
%% Define data parameters
Nparam=data.exp/data.dim;
peaks=[]; valleys=[];
midplane_height=data.Z(1);           %Height of the mid-plane of the plate

for cnt=1:1:Nparam           %First and last parameter values (during parametric sweep) may not be evaluated if bounds are not 1 and Nparam                  
    
    %Get all peaks and valleys
    %Note: peaks and valleys at the boundary are not identified
    [peak_height peak_loc]=findpeaks(data.exportedz(:,cnt));
    peak_height=peak_height - midplane_height; 
    
    [valley_depth valley_loc]=findpeaks(-data.exportedz(:,cnt));
    valley_depth=-valley_depth - midplane_height;
    
    %Convert location to length dimension
    peak_loc_x=(peak_loc-1)*max(data.exportedx(:,cnt))/size(data.exportedx,1);
    peak_loc_y=(peak_loc-1)*max(data.exportedy(:,cnt))/size(data.exportedy,1);
    valley_loc_x=(valley_loc-1)*max(data.exportedx(:,cnt))/size(data.exportedx,1);
    valley_loc_y=(valley_loc-1)*max(data.exportedy(:,cnt))/size(data.exportedy,1);
    
    %Store values in peaks and valleys
    peaks=[peaks, peak_loc_x, peak_loc_y, peak_height];
    valleys=[valleys, valley_loc_x, valley_loc_y, valley_depth];
    
end
end