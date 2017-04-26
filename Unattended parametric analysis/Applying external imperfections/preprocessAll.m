%% To set-up family of nonlinear COMSOL studies 
% Steps are: 
%           (1) Set all file names and directory names
%           (2) Set-up the range of parameters & generate the space of all
%               parameter multipliers
%           (3) Get nominal parameter values from seed model
%           (4) Generate set of all parameters by multiplying nominal
%               parameter values to the set of parameter multipliers
%           (5) Generate linear model for each parameter set
%           (6) Generate nonlinear models and imperfection modified midplane coordinate files for each linear model    
%
%   Note: nonlinear model is not solved in this script. This script only defines the models. Run processAll.m to
%   solve all of the nonlinear models 

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

%% Steps (1) Set directory and file names
%Directory for studies
clear all;clc;
setStudyNames;                    %File names for studies set in this file  
mkdir(rootdir);
log_file=strcat(rootdir,log_file); logfid=fopen(log_file,'a');

%Set file names: DO NOT change these even when the study changes
set_filenames;                     %Rest of the file names defined in this .m file

%Write status of operation to file
fprintf(1,'%s%s\n','Pre-processing of .mph files started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Pre-processing of .mph files started at: ',datestr(now));


%% Step (2a)  Set-up the range of parameters (TO BE CHANGED WHEN STUDY CHANGES)
%Columns correspond to columns in parameter format 
%Format of parameters: [L H W hf epsilonp epsilon0 nsteps Et Mub epsilon] 

%Set steps to 0 if parameter is not being varied
steps=[0 0 0 1 0 0 0 0 0 0];         %Total number of steps (odd number)
f_ub=[1 1 1 2 1 1 1 2 2 1];          %Upper bound =f_ub X nominal value  
f_lb=[1 1 1 0.5 1 1 1 0.5 0.5 1];    %Lower bound =f_lb X nominal value

%Define parameter space for nonlinear studies around nominal linear parameters
%Note:2 columns, 1st column is for amplitude of imperfection, 2nd
%for period of imperfection
steps_nl=[7 7];         %Total number of steps (odd number)
f_ub_nl=[10 10];          %Upper bound =f_ub X nominal value  
f_lb_nl=[0.001 0.1];    %Lower bound =f_lb X nominal value

%Nominal weight for intial imperfection
An=209.2e-3;                  %Natural amplitude 
hn=25e-3;                   %Natural thickness of top layer
nominal_weight=An/hn;
nominal_imp_period=1;         %imp_period/natural period
Nmp=1000;                       %Number of data points
WvsL=1;                         %Width versus length

%Identifying which parameters are being varied & writing to file
%Linear analysis
ns=0.5*(steps-1);                             %Number of steps above and below nominal value
p_names_nounits={'L', 'H', 'W', 'hf' ,'epsilonp', 'epsilon0', 'nsteps', 'Et', 'Mub', 'epsilon', 'weight factor', 'Imperfection period'}; %Name of parameters
param_varied=[];varied_levels=[]; upper_levels=[];lower_levels=[];
for i=1:size(ns,2)
    if ns(i)>0
        param_varied=strcat(param_varied,{' '},p_names_nounits(i));
        varied_levels=strcat(varied_levels,{' '},num2str(steps(i)));
        upper_levels=strcat(upper_levels,{' '},num2str(f_ub(i)));
        lower_levels=strcat(lower_levels,{' '},num2str(f_lb(i)));
    end
end

%Writing to file
if ~isempty(param_varied)
    fprintf(1,'\n%s%s%s%s%s\n','Linear analysis parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
    fprintf(logfid,'\n%s%s%s%s%s\n','Linear analysis parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
    fprintf(1,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');
    fprintf(logfid,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');
else
    fprintf(1,'\n%s\n','No linear analysis parameters being varied.');
    fprintf(logfid,'\n%s\n','No linear analysis parameters being varied.');
end

%Non-linear analysis
ns_nl=0.5*(steps_nl-1);                    %Number of steps above and below nominal value
param_varied=[];varied_levels=[]; upper_levels=[];lower_levels=[];
p_names_nounits={'Weight factor','Imperfection period'};
for i=1:size(ns_nl,2)
    if ns_nl(i)>0
        param_varied=strcat(param_varied,{' '},p_names_nounits(i));
        varied_levels=strcat(varied_levels,{' '},num2str(steps_nl(i)));
        upper_levels=strcat(upper_levels,{' '},num2str(f_ub_nl(i)));
        lower_levels=strcat(lower_levels,{' '},num2str(f_lb_nl(i)));
    end
end
%Writing to file
fprintf(1,'\n%s%s%s%s%s\n','Nonlinear analysis parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
fprintf(logfid,'\n%s%s%s%s%s\n','Nonlinear analysis parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
fprintf(1,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');
fprintf(logfid,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');


%% Step 2(b) Generate the space of all parameter multipliers 
% (DO NOT change this when study changes)
fprintf(1,'\n%s\n','Generating the space of all parameter multipliers...');
fprintf(logfid,'\n%s\n','Generating the space of all parameter multipliers...');
preprocessGenParam_log;                 %Set parameter values in this .m file

%% Step (3) Read seed file to obtain nominal parameter values 
% (DO NOT change this when study changes)
fprintf(1,'%s\n','Loading and running linear seed model...');
fprintf(logfid,'%s\n','Loading and running linear seed model...');
seed_model=mphload(seed_linear); 
seed_model.sol('sol1').runAll;

%Format of parameters: [L H W hf epsilonp epsilon0 nsteps Et Mub epsilon]  
fprintf(1,'%s\n','Reading parameters from seed model...');
fprintf(logfid,'%s\n','Reading parameters from seed model...');
[nominal_p units p_with_units_values]=readParameters(seed_model);                   %Nominal parameter values

%Write nominal parameter values
fprintf(1,'%s%s\n','Nominal parameter values are: ',p_with_units_values{1});
fprintf(logfid,'%s%s\n','Nominal parameter values are: ',p_with_units_values{1});

%% Step (4) Generate all feasible combinations of parameters
% (DO NO change this when study changes)
parameters=bsxfun(@times,parameter_multiplier,nominal_p);         %List of all parameters at which the linear models have to be solved

%Modify imperfection period
parameter_multiplier_nl(:,2)=nominal_imp_period*parameter_multiplier_nl(:,2);

%% Step (5) Generate models for all parameters 
% (DO NOT change this when study changes)
model_total=size(parameters,1);     %Total number of linear models
model_count=0;                       
skipped_models=[];

fprintf(1,'\n%s\t%i\t%s\t%s\n','Total',model_total,'linear models to be generated in directory',rootdir);
fprintf(logfid,'\n%s\t%i\t%s\t%s\n','Total',model_total,'linear models to be generated in directory',rootdir);

fprintf(1,'%i\t%s\n',nl_perlinear,'nonlinear models to be generated for each linear model');
fprintf(logfid,'%i\t%s\n',nl_perlinear,'nonlinear models to be generated for each linear model');

linearModel=seed_model;
import com.comsol.model.util.*
ModelUtil.showProgress(true);

%Run through all parameter values 
preprocessGenModel;                 %Generate all models

%Finished generating all models
fprintf(1,'%s\t%i\t%s\n%s\t%i\t%s\n','Saved all',model_total,'linear models','Skipped',size(skipped_models,2),'models');
fprintf(logfid,'%s\t%i\t%s\n%s\t%i\t%s\n','Saved all',model_total,'linear models','Skipped',size(skipped_models,2),'models');

if ~isempty(skipped_models)
    fprintf(1,'%s\t%s\n','Skipped linear model numbers: ',num2str(skipped_models));
    fprintf(logfid,'%s\t%s\n','Skipped linear model numbers: ',num2str(skipped_models));
end

fprintf(1,'%s%s\n','End of pre-processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of pre-processing at: ',datestr(now));

fclose('all');








