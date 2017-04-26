function [Ycross_section]=getYSection(data, yval)
%To extract y-cross-section from 3-D data
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

%% Copy header info
Ycross_section.dim=data.dim;
Ycross_section.nodes=data.nodes;
Ycross_section.exp=data.exp;
Ycross_section.nshapes=data.nshapes;

%% Get Y cross-section

cnt=size(data.X,1);

for i=1:cnt
    if data.Y(i)==yval
        Ycross_section.X(i,:)=data.X(i,:);
        Ycross_section.Y(i,:)=data.Z(i,:);
        Ycross_section.exportedx(i,:)=data.exportedx(i,:);
        Ycross_section.exportedy(i,:)=data.exportedz(i,:);
    end
    
end

end