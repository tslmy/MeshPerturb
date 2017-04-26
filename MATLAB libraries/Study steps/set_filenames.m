%% File names

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

%% Input file names
dataMesh='/modeshapes_0.txt';                 %File that contains exported COMSOL data from linear analysis for mesh coordinates
dataMidPlane='/midplaneshapes_0.txt';         %File that contains exported COMSOL data from linear analysis for mid plane coordinates only 
meshCoordinates='/meshcoordinates_0.txt';     %File that contains mesh point coordinates
midPlaneCoordinates='/oldmidplane_0.txt';     %File that contains mid-plane coordinates of the top plate 
originalMesh='/oldmesh_0.mphtxt';             %Mesh is read from this file
modifiedMesh='/newmesh_0.mphtxt';             %New mesh is written to this file  
modifiedMidPlane='/newmidplane_0.txt';        %File that contains mid-plane coordinates with imperfection but before non-linear analysis
LinearModelFile='/linear_analysis_0.mph';        %New comsol format linear analysis model file
NonlinearModelFile='/nonlinear_analysis_0.mph';        %New comsol format non-linear analysis model file
deformedMidPlane='/deformedmidplane_0.txt';             %File to which the mid-plane coordinates are exported after non-linear analysis

%% Set proper directory
root=strcat(pwd,rootdir);                     
dataMesh=strcat(root,dataMesh);
dataMidPlane=strcat(root,dataMidPlane);
meshCoordinates=strcat(root,meshCoordinates);
midPlaneCoordinates=strcat(root,midPlaneCoordinates);
originalMesh=strcat(root,originalMesh);
modifiedMesh=strcat(root,modifiedMesh);
modifiedMidPlane=strcat(root,modifiedMidPlane);
deformedMidPlane=strcat(root,deformedMidPlane);
LinearModelFile=strcat(root,LinearModelFile);
NonlinearModelFile=strcat(root,NonlinearModelFile);