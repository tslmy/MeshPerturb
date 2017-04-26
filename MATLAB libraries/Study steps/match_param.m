function [] = match_param( linear, nonlinear )
% To copy parameters from linear model to nonlinear model (for consistency)
% Input: ( linear, nonlinear )
% linear: Linear comsol model object
% nonlinear: Nonlinear comsol model object
% Output: []
% Parameters being copied are: L, H, W, hf, Et, Mub

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


%% Read parameters from linear model
L=linear.param.get('L');
H=linear.param.get('H');
W=linear.param.get('W');
hf=linear.param.get('hf');
Et=linear.param.get('Et');
Mub=linear.param.get('Mub');

%% Write parameters to nonlinear model
nonlinear.param.set('L', L);
nonlinear.param.set('H', H);
nonlinear.param.set('W', W);
nonlinear.param.set('hf', hf);
nonlinear.param.set('Et', Et);
nonlinear.param.set('Mub', Mub);

end

