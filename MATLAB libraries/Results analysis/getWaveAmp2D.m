function [half_wavelength amplitude] = getWaveAmp2D(peaks, valleys)
%To extract half-wavelength and amplitude from 2-D COMSOL non-linear analysis results
% Input: (peaks, valleys)
% peaks = [peak_loc_para1(x value) peak_height_para1(y value) peak_loc_para2(x value) peak_height_para2(y value)... ]
% valleys = [valley_loc_para1(x value) valley_depth_para1(y value) valley_loc_para2(x value) valley_depth_para2(y value)... ]
% Output: [halfWavelength amplitude]
% half_wavelength = peak to valley distance along X axis (in deformed material coordinate system)
% amplitude = peak to valley distance along Y axis (in deformed material coordinate system)
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

%% Merging peaks and valleys
extrema=[peaks; valleys]; 
Nparam=0.5*size(extrema,2);             %Number of parameters
Namp=size(extrema,1)-1;                 %Number of peak-to-valley distances

%% Evaluating half-wavelength and amplitude
%Note: amplitude is -ve if extrema starts with a peak instead of a valley

half_wavelength=zeros(Namp,Nparam);amplitude=zeros(Namp,Nparam);
for cntparam=1:Nparam
    peaksValleys=extrema(:,2*cntparam-1:2*cntparam);
    peaksValleys=sortrows(peaksValleys,1);
    for cnt=1:Namp
        half_wavelength(cnt,cntparam)=peaksValleys(cnt+1,1) - peaksValleys(cnt,1);
        amplitude(cnt,cntparam)=abs(0.5*(peaksValleys(cnt+1,2) - peaksValleys(cnt,2)));
    end
end 