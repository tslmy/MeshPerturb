%% Step (6): Export u,v,w at mesh point and mid-plane coordinates from linear buckling

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
%Mesh point coordinates: Set-up file names for export steps 
linearModel.result.export('data1').set('filename', dataMesh);
linearModel.result.export('data1').set('coordfilename', meshCoordinates);
%Export u,v,w
linearModel.result.export('data1').run;

%Mid-plane coordinates: Set-up file names for export steps 
linearModel.result.export('data1').set('filename', dataMidPlane);
linearModel.result.export('data1').set('coordfilename', midPlaneCoordinates);
%Export u,v,w
linearModel.result.export('data1').run;


