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
nonlinear_multiplier= @(i) [(1-f_lb_nl(i))/ns_nl(i)*(0:ns_nl(i))+f_lb_nl(i) (f_ub_nl(i)-1)/ns_nl(i)*(1:ns_nl(i))+1];

N_p=0;                         %Cases processed for linear analysis
N_nl_p=1;                      %Product of cases processed for nonlinear analysis 
N_total=max(sum(steps),1);              %Total number of linear cases 
nl_perlinear=(prod(steps_nl));      %Total number of nonlinear models per linear model
parameter_multiplier=ones(N_total,10);    %List of parameters; Each row is a set of parameter multiplier
parameter_multiplier_nl=ones(nl_perlinear,2);

%Varying one-parameter-at-a-time for linear analysis
for i=1:10                       %Running through parameters
    if ns(i)>0                   %If more than one step exists for this parameter
        param_choices=linear_multiplier(i);
        parameter_multiplier(N_p+1:N_p+steps(i),i)=param_choices;
        N_p = N_p + steps(i);
    end
end


%Varying all parameters simulatneously for nonlinear analysis 
for i=1:2                      %Running through parameters
    if ns_nl(i)                   %If more than one step exists for this parameter
        param_choices=nonlinear_multiplier(i);
        this_param=repmat(param_choices, [N_nl_p 1]);this_param=this_param(:);
        this_param=repmat(this_param, [nl_perlinear/(size(param_choices,2)*N_nl_p) 1]);
        this_param=this_param(:);
        parameter_multiplier_nl(:,i)=this_param;
    end
    N_nl_p=N_nl_p*steps_nl(i);
end
    