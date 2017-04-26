%% Step (7) Evaluate the initial imperfection

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
%Generate weighting function
%weight: weighting of displacement for imperfection calculation
weight=zeros(data_for_Mesh.nshapes,1);

%Using the first postive mode shape only
%Note: weighted mode is evaluted in step6.m
weight(weighted_mode)=weight_factor;

%Get imperfections
imperfection_Mesh=getPrepattern(data_for_Mesh, weight,imp_period, h_plate, base_height);
imperfection_MidPlane=getPrepattern(data_for_MidPlane, weight,imp_period,h_plate, base_height);