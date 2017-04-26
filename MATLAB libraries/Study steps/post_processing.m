%% Step (10) Post processing: Analysis of exported data generated via non-linear analysis

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


%% Script
%Get all the geometric parameters of the model
[H unit_H]=mphglobal(nonlinearModel,'H'); H=H(1);           %Height of base layer
[L unit_L]=mphglobal(nonlinearModel,'L'); L=L(1);           %Length
[hf unit_hf]=mphglobal(nonlinearModel,'hf'); hf=hf(1);      %Height of top layer
%[W unit_W]=mphglobal(nonlinearModel,'W'); W=W(1);           %Depth/width of top/bottom layers

%Get all the strain values from the model
epsilon=mphglobal(nonlinearModel,'epsilon');       %Current prestretch strain values 
epsilon_p=epsilon(1);                              %Maximum prestretch of the base layer  
epsilon_c=epsilon_p-epsilon;                       %Current compression of top layer 

%Get mid-plane coordinates 
midplane=readCoordinates(modifiedMidPlane, mesh.dim);

%Get displacements at mid-plane coordinates
variable={'x','y','z'};                           %Format for extracting variables
displacement=[];
for i=1:mesh.dim
    displacement=[displacement mphinterp(nonlinearModel, variable{i}, 'coord', midplane.coordinates')'];
end
%Format extracted data
data_nonlinear=formatData(midplane.coordinates, displacement);

%Get strain energies
% Define average function over domains (1: bottom, 2: top layer)
nonlinearModel.cpl.create('avop1','Average','geom1');
nonlinearModel.cpl.create('avop2','Average','geom1');
nonlinearModel.cpl.create('avop12','Average','geom1');
nonlinearModel.cpl('avop1').selection.set(1);
nonlinearModel.cpl('avop2').selection.set(2);
nonlinearModel.cpl('avop12').selection.set([1 2]);
nonlinearModel.sol('sol1').updateSolution;
% Evaluate average strain energies over different domains
[Es_bottom unit_Es]=mphglobal(nonlinearModel,'avop1(solid.Ws*H)');
Es_top=mphglobal(nonlinearModel,'avop2(solid.Ws*hf)');
Es_combined=mphglobal(nonlinearModel,'avop12(solid.Ws*(H+hf))');


% Obtain wavelength and amplitude
[peaks valleys]=getPeaksValleys2D(data_nonlinear);
[half_wavelength amplitude] = getWaveAmp2D(peaks, valleys)


