function [parameters, units, p_with_units_values p_with_units] = readParametersDefects(model)
%Read process parameters from a given comsol model
% parameter format is [L H W hf epsilonp epsilon0 nsteps Et Mub epsilon]  
% Inputs: model
% Input: model: COMSOL model object
% Outputs: parameters, units, p_with_units_values, p_with_units
% Ouput: parameters: model parameters
% Output: units: units for the model parameters
% Output: p_with_units_values: parameter names and values with units
% Output: p_with_units: parameter names with units

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

%% Read process parameters
p_names_nounits={'L', 'H', 'W', 'hf' ,'epsilonp', 'epsilon0', 'nsteps', 'Et', 'Mub', 'epsilon', 'dia', 'depth'};
[ L H W hf ep e0 nsteps Et Mub e dia depth units]=mphglobal(model,p_names_nounits,'SolNum', 'end');

parameters=[L H W hf ep e0 nsteps Et Mub e dia depth];

%Generating parameter names with units 
p_with_units_values=[];
p_with_units=repmat({''},size(parameters));
for i=1:size(parameters,2)
    p_with_units_values=strcat(p_with_units_values, {' '},p_names_nounits(i),{'='},num2str(parameters(i)),{' ('},units(i),{')'});
    p_with_units(i)=strcat(p_names_nounits(i),{' ('},units(i),{')'});
end

end

