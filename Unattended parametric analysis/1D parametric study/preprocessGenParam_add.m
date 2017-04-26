%% Step 2(b) Generate the space of all parameter multipliers 
%(DO NOT change this when study changes) 
%One factor at a time: When a parameter is varied all others are held constant at level 1 

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
linear_multiplier= @(i) [(1-f_lb(i))/ns(i)*(0:ns(i))+f_lb(i) (f_ub(i)-1)/ns(i)*(1:ns(i))+1];

N_p=0;                         %Cases processed
N_total=sum(steps);                       %Total number of cases 
parameter_multiplier=ones(N_total,10);    %List of parameters; Each row is a set of parameter multiplier    

for i=1:10                      %Running through parameters
    if ns(i)>0                   %If more than one step exists for this parameter
        param_choices=linear_multiplier(i);
        parameter_multiplier(N_p+1:N_p+steps(i),i)=param_choices;
        N_p = N_p + steps(i);
    end
end
    
