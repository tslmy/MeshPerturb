%% Step (7) Evaluate the nominal period from linear buckling analysis

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


%% Step definitions
%Read mode shape displacements from exported COMSOL file
data_for_Mesh=readExportedData(dataMesh);
data_for_MidPlane=readExportedData(dataMidPlane);

%Identify the first postive mode shape
eigen=mphglobal(linearModel,'lambda');
weighted_mode=find(eigen>0,1,'first');

%% Get period from linear analysis
coord=readCoordinates(midPlaneCoordinates,mesh.dim);

%Get deformed coordinates at original mid-plane coordinates
variable={'x','y','z'};                           %Format for extracting variables
displacement=[];
for j=1:mesh.dim
            displacement=[displacement mphinterp(linearModel, variable{j}, 'coord', coord.coordinates', 'solnum', weighted_mode)'];
end

%Format extracted data
data_linear=formatData(coord.coordinates, displacement);
if mesh.dim==3
    data_linear=getYSection(data_linear,((0.5*Nmp)-1)/(Nmp-1)*W(1));
end

%Evaluate average period and amplitude
[peaks valleys]=getPeaksValleys2D(data_linear);
[half_wavelength amplitude] = getWaveAmp2D(peaks, valleys);

%Evaluate average period
nominal_period=2*mean(half_wavelength);

%Get plate thickness and base height
h_plate=hf(1);
base_height=H(1);
        