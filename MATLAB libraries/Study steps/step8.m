%% Step (8) Generate new modified mesh file & file containing mid-plane coordinates with imperfection 

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
%Generating modified mesh
%Verify that originalMesh and datafile have the same original coordinates
%errorMsg=0 if data set matches, error=1 if data set does not match
errorMsg=~(mesh.nodes==data_for_Mesh.nodes);           

% Opening files for writing              
fidwrite_mesh=fopen(modifiedMesh,'w'); 
fidwrite_midp=fopen(modifiedMidPlane,'w');

%Write header to new mesh
coord=readCoordinates(midPlaneCoordinates,mesh.dim);
fprintf(fidwrite_mesh,'%s\n',mesh.header);

%Write data to the file
%If data set matches write the modified mesh, else write the original mesh to the modified mesh file
MeshToWrite = mesh.coordinates + (~errorMsg)*imperfection_Mesh;
fprintf(fidwrite_mesh,mesh.dataformat,MeshToWrite');

% Writing the rest of the file: no change in this part
fprintf(fidwrite_mesh,'%s\n',mesh.rof);

%Generating mid-plane coordinates with imperfection
MidPlaneToWrite = coord.coordinates + imperfection_MidPlane;
fprintf(fidwrite_midp,coord.dataformat,MidPlaneToWrite');

% Close files
fclose(fidwrite_mesh);
fclose(fidwrite_midp);