function [uniformity_wave uniformity_amp] = getUniformity2D(half_wavelength, amplitude, margin)
%To determine if the half-wavelengths and amplitudes are uniform 
% Input: (half_wavelength, amplitude, margin)
% half_wavelength = peak to valley distance along X axis (in deformed material coordinate system)
% amplitude = peak to valley distance along Y axis (in deformed material coordinate system)
% margin = margin for uniformity (varied from 0 to 1)
% Output: [uniformity_wave uniformity_amp]
% uniformity_wave = 1 if wavelengths are within uniformity margin, 0 otherwise
% uniformity_amp = 1 if amplitudes are within uniformity margin, 0 otherwise
% Note that each column is for a specific parameter value. Multiple columns
% exist in the outputs if multiple parameter values were used for half_wavelength and amplitude

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

%% Initializing values
Nparam=size(amplitude,2);             %Number of parameters
uniformity_wave=zeros(1,Nparam);
uniformity_amp=zeros(1,Nparam);

%% Test for uniformity

% Test: pattern uniform if min>= max*(1-margin)    
% 1=uniform patterns, 0=non-uniform patterns
    
for cnt=1:Nparam
    uniformity_wave(cnt)= min(half_wavelength(:,cnt)) >= max(half_wavelength(:,cnt))*(1-margin);
    uniformity_amp(cnt)= min(amplitude(:,cnt)) >= max(amplitude(:,cnt))*(1-margin);
end

end