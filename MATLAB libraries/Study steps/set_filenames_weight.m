%% File names when weight parameters is being varied

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

%% File names for linear analysis
dataMesh='.\LinearAnalysis_For_Weight\modeshapes.txt';                 %File that contains exported COMSOL data from linear analysis for mesh coordinates
dataMidPlane='.\LinearAnalysis_For_Weight\midplaneshapes.txt';         %File that contains exported COMSOL data from linear analysis for mid plane coordinates only 
meshCoordinates='.\LinearAnalysis_For_Weight\meshcoordinates.txt';     %File that contains mesh point coordinates
midPlaneCoordinates='.\LinearAnalysis_For_Weight\oldmidplane.txt';     %File that contains mid-plane coordinates of the top plate 
originalMesh='.\LinearAnalysis_For_Weight\oldmesh.mphtxt';             %Mesh is read from this file
LinearModelFile='.\LinearAnalysis_For_Weight\linear_analysis_frommatlab.mph';        %New comsol format linear analysis model file

%% Set proper directory
root=strcat(pwd,root);                     
dataMesh=strcat(root,dataMesh);
dataMidPlane=strcat(root,dataMidPlane);
meshCoordinates=strcat(root,meshCoordinates);
midPlaneCoordinates=strcat(root,midPlaneCoordinates);
originalMesh=strcat(root,originalMesh);
LinearModelFile=strcat(root,LinearModelFile);

%% Directory for linear buckling analysis(DO NOT change these)
mkdir(strcat(root,'\LinearAnalysis_For_Weight'));
mkdir(strcat(root,'\NonlinearAnalysis_For_Weight'));  %Directory that stores results of non-linear analysis
