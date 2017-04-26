function [half_wavelength_x amplitude_x half_wavelength_y amplitude_y] = getWaveAmp3D(peaks, valleys)
%To extract half-wavelength and amplitude from 3-D COMSOL non-linear analysis results
% Input: (peaks, valleys)
% peaks = [peak_loc_para1(x value) peak_height_para1(y value) peak_loc_para2(x value) peak_height_para2(y value)... ]
% valleys = [valley_loc_para1(x value) valley_depth_para1(y value) valley_loc_para2(x value) valley_depth_para2(y value)... ]
% Output: [half_wavelength_x amplitude_x half_wavelengt_y amplitude_y]
% half_wavelength_x = peak to valley distance along X axis (in deformed material coordinate system)
% amplitude_x = peak to valley distance along Z axis (in deformed material coordinate system)
% Note that each column is for a specific parameter value. Multiple columns
% exist in the outputs if multiple parameter values were used for peak/valleys

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

%% Separating X and Y data 
peakX=[peaks(:,1) peaks(:,3)];
valleyX=[valleys(:,1) valleys(:,3)];

peakY=[peaks(:,2) peaks(:,3)];
valleyY=[valleys(:,2) valleys(:,3)];


%% Evaluating along X
[half_wavelength_x amplitude_x]=getWaveAmp2D(peakX,valleyX);

%% Evaluating along Y
[half_wavelength_y amplitude_y]=getWaveAmp2D(peakY,valleyY);


end 