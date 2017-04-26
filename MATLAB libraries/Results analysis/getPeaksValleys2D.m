function [peaks valleys] = getPeaksValleys2D(data)
%To extract peaks and valleys from 2-D COMSOL non-linear analysis results
% Input: (data)
% data: data structure of file read (readExportedData.m) from COMSOL analysis that contains plate coordinates of the plate midplane
% Output: [peaks valleys]
% peaks = [peak_loc_para1(x value) peak_height_para1(y value) peak_loc_para2(x value) peak_height_para2(y value)... ]
% valleys = [valley_loc_para1(x value) valley_depth_para1(y value) valley_loc_para2(x value) valley_depth_para2(y value)... ]
% Data being read from file are: X,Y,Z coordinates and the deformed coordinates x,y,z
% Peaks and valleys are read for all parameters during parameter continuation in COMSOL
% Heights and depths are relative to undeformed mid-plane position
% Y is the mid-plane position at undeformed position X (may include the initial imperfection)
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

%% Identify peaks and valleys 
% x, y is the data of interest

peaks=[]; valleys=[];
midplane_height=data.Y(1);           %Height of the mid-plane of the plat

for cnt=1:1:Nparam           %First and last parameter values (during parametric sweep) may not be evaluated if bounds are not 1 and Nparam                
    
    %Get all peaks and valleys
    %Note: peaks and valleys at the boundary are not identified
    [peak_height peak_loc]=findpeaks(data.exportedy(:,cnt));
    peak_height=peak_height - midplane_height; 
    
    [valley_depth valley_loc]=findpeaks(-data.exportedy(:,cnt));
    valley_depth=-valley_depth - midplane_height;
    
    %Convert location to length dimension
    peak_loc=(peak_loc-1)*max(data.exportedx(:,cnt))/size(data.exportedx,1);
    valley_loc=(valley_loc-1)*max(data.exportedx(:,cnt))/size(data.exportedx,1);
    
    %Store values in peaks and valleys
    %size(peak_loc), size(peak_height), size(peaks)
     %size(valley_loc), size(valley_depth), size(valleys)
    %Note: dimension error is due to different number of peaks across
    %different parameters. Increase the starting parameter value
    peaks=[peaks, peak_loc, peak_height];
    valleys=[valleys, valley_loc, valley_depth];
    
end
end