%% To set-up family of nonlinear COMSOL studies 
% Steps are: 
%           (1) Set all file names and directory names
%           (2) Set-up the range of parameters & generate the space of all
%               parameter multipliers
%           (3) Get nominal parameter values from seed model
%           (4) Generate set of all parameters by multiplying nominal
%               parameter values to the set of parameter multipliers
%           (5) Generate 1 set of linear and nonlinear model for each
%               parameter set. Each iteration generates (a) linear mph
%               model, (b) nonlinear mph model, (c) undeformed midplane
%               coordinates txt file, and (d) mid plane coordinates with
%               mesh imperfection (but before nonlinear analysis). All
%               other intermediate files are erased/over-written.

%   Note: nonlinear model is not solved in this script. This script only defines the models. Run processAll.m to
%   solve all of the nonlinear models that are generated by this script

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
rootdir='.\Test';            %Root directory for study (Change this when study changes)
mkdir(rootdir);

%Set file names: DO NOT change these even when the study changes
log_file='.\log.txt';
seed_linear=strcat(pwd,'.\linear_analysis_seed.mph');
seed_nonlinear='.\nonlinear_analysis_seed.mph';
set_filenames;                     %Rest of the file names defined in this .m file
log_file=strcat(rootdir,log_file); logfid=fopen(log_file,'w');

%Write status of operation to file
fprintf(1,'%s%s\n','Pre-processing of .mph files started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Pre-processing of .mph files started at: ',datestr(now));

%Set system parameters
Nmp=1000;                           %Number of mid-plane coordinates along length (used in step 5)
WVsL=1;                             %Ratio of number of points along width to length (used in step 5)
weight_factor=0.01;                 %Weighting factor for imperfection (used in step7)

%% Step (2a)  Set-up the range of parameters (TO BE CHANGED WHEN STUDY CHANGES)
%Columns correspond to columns in parameter format 
%Format of parameters: [L H W hf epsilonp epsilon0 nsteps Et Mub epsilon] 

%Set steps to 1 if parameter is not being varied
steps=[0 0 0 0 0 0 0 0 1 0];         %Total number of steps (odd number)
f_ub=[4 10 1 2 5 1 1 5 2 1];          %Upper bound =f_ub X nominal value  
f_lb=[0.1 0.1 1 0.5 0.2 1 1 0.2 0.5 1];    %Lower bound =f_lb X nominal value

%Identifying which parameters are being varied & writing to file
ns=0.5*(steps-1);                    %Number of steps above and below nominal value
p_names_nounits={'L', 'H', 'W', 'hf' ,'epsilonp', 'epsilon0', 'nsteps', 'Et', 'Mub', 'epsilon'}; %Name of parameters
param_varied=[];varied_levels=[]; upper_levels=[];lower_levels=[];
for i=1:size(ns,2)
    if ns(i)
        param_varied=strcat(param_varied,{' '},p_names_nounits(i));
        varied_levels=strcat(varied_levels,{' '},num2str(steps(i)));
        upper_levels=strcat(upper_levels,{' '},num2str(f_ub(i)));
        lower_levels=strcat(lower_levels,{' '},num2str(f_lb(i)));
    end
end
%Writing to file
fprintf(1,'%s%s%s%s%s\n','Parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
fprintf(logfid,'%s%s%s%s%s\n','Parameters: ',param_varied{1},' are being varied over: ',varied_levels{1},' levels.');
fprintf(1,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');
fprintf(logfid,'%s%s%s%s%s\n','Upper bound is: ',upper_levels{1},' times nominal value and lower bound is: ',lower_levels{1},' times nominal value.');

%% Step 2(b) Generate the space of all parameter multipliers 
% (DO NOT change this when study changes)
fprintf(1,'%s\n','Generating the space of all parameter multipliers...');
fprintf(logfid,'%s\n','Generating the space of all parameter multipliers...');
%preprocessGenParam;                 %Set parameter values in this .m file
preprocessGenParam_add;                 %One parameter at a time

%% Step (3) Read seed file to obtain nominal parameter values 
% (DO NO change this when study changes)
fprintf(1,'%s\n','Loading and running seed model...');
fprintf(logfid,'%s\n','Loading and running seed model...');
seed_model=mphload(seed_linear);   
seed_model.sol('sol1').runAll;

%Format of parameters: [L H W hf epsilonp epsilon0 nsteps Et Mub epsilon]  
fprintf(1,'%s\n','Reading parameters from seed model...');
fprintf(logfid,'%s\n','Reading parameters from seed model...');
[nominal_p units p_with_units_values]=readParameters(seed_model);                   %Nominal parameter values

%Modify nominal ep for ep variation study (Comment out if ep is not being varied)
%nominal_p(5)=0.05;

%Write nominal parameter values
fprintf(1,'%s%s\n','Nominal parameter values are: ',p_with_units_values{1});
fprintf(logfid,'%s%s\n','Nominal parameter values are: ',p_with_units_values{1});

%% Step (4) Generate all feasible combinations of parameters
% (DO NO change this when study changes)
parameters=bsxfun(@times,parameter_multiplier,nominal_p);         %List of all parameters at which the models have to be solved

%% Step (5) Generate models for all parameters 
% (DO NOT change this when study changes)
model_total=size(parameters,1);     %Total number of models
model_count=0;                       
skipped_models=[];
fprintf(1,'%s\t%i\t%s\t%s\n','Total',model_total,'models to be generated in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n','Total',model_total,'models to be generated in directory',rootdir);

% Run the linear buckling seed model
%This seed model is the .m file (Change this if the .m file name changes 
%Should not be changed if seed remains same but only study changes
%fprintf(1,'%s\n','Loading seed model .m file...');
%fprintf(logfid,'%s\n','Loading seed model .m file...');
%linearModel=linear_analysis_seed();             
linearModel=seed_model;
import com.comsol.model.util.*;
ModelUtil.showProgress(true);

%Run through all parameter values 
preprocessGenModel;                 %Generate all models
%preprocessGenModelLinear;                 %Generate all linear models only

%Finished generating all models
fprintf(1,'%s\t%i\t%s\n%s\t%i\t%s\n','Saved all',model_total,'models','Skipped',size(skipped_models,2),'models');
fprintf(logfid,'%s\t%i\t%s\n%s\t%i\t%s\n','Saved all',model_total,'models','Skipped',size(skipped_models,2),'models');
if ~isempty(skipped_models)
    fprintf(1,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
    fprintf(logfid,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
end
fprintf(1,'%s%s\n','End of pre-processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of pre-processing at: ',datestr(now));

fclose(logfid);








