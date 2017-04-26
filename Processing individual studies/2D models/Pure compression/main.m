%% To set-up the COMSOL post-buckling analysis via Matlab
%  The analysis steps are: 
%             (1) Set-up linear buckling model in COMSOL desktop
%             (2) Set-up non-linear post-buckling model in COMSOL desktop (using exported mesh from linear buckling analysis)
%             (3) Export both models as .m files 
%             (4) Run linear buckling in matlab
%             (5) Export original mesh, coordinates from original mesh, and coordinates of midplane from the linear-buckling study
%             (6) Export u,v,w at mesh point coordinates from linear buckling
%             (7) Evaluate initial geometric imperfection
%             (8) Generate new modified mesh & file containing mid-plane coordinates with imperfection 
%             (9) Run non-linear analysis with modified mesh
%             (10) Post-process results/export data 
%             (11) Display and save results 
%
% Final post-buckling analysis may be performed in Matlab/Comsol desktop environment

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
clear all;clc;

%Write status of operation to file
fprintf(1,'%s%s\n','Processing started at: ',datestr(now));

%Directory for studies
rootdir='.\Analysis files';            %Root directory for study (Change this when study changes)
mkdir(rootdir);

mph_linear='linear_analysis_seed.mph';                   %Linear analysis file in .mph format

%% Set system parameters
Nmp=1000;                           %Number of mid-plane coordinates along length (used in step 5)
WVsL=1;                             %Ratio of number of points along width to length (used in step 5)
weight_factor=0.05;                  %Weighting factor for imperfection (used in step7)

%% Set file names
set_filenames;                     %File names defined in this file

%% Steps (1), (2), and (3) are performed in COMSOL

%% Steps (4)-(10) 
% Step (4) Load/Run the linear buckling model
fprintf(1,'%s\n','Loading linear analysis model...');
linearModel=mphload(mph_linear);   

fprintf(1,'%s\n','Solving linear analysis model...');           %Comment out if model already solved
linearModel.sol('sol1').runAll;                 %Comment out if model already solved 
linearModel.save(LinearModelFile);              %Comment out if model already solved

% Step 5: Export mesh and mid-plane coordinates
fprintf(1,'%s\n','Step 5...');
step5;                                          %Step 5 in this file

% Step (6): Export u,v,w at mesh point and mid-plane coordinates from linear buckling
fprintf(1,'%s\n','Step 6...');
step6;                                          %Step 6 in this file

% Save model file
%linearModel.save(LinearModelFile); 

% Step (7) Evaluate the initial imperfection
fprintf(1,'%s\n','Step 7...');
step7;                                          %Step 7 in this file

% Step (8) Generate new modified mesh file & file containing mid-plane coordinates with imperfection 
fprintf(1,'%s\n','Step 8...');
step8;                                          %Step 8 in this file

% Step (9) Run the non-linear analysis model or load model from file
fprintf(1,'%s\n','Running non-linear analysis...');
nonlinearModel=nonlinear_analysis_seed(modifiedMesh);    
try 
    nonlinearModel.sol('sol1').runAll;          %Comment out if not solving model
catch exception
    fprintf(1,'%s\n','Nonlinear model did not converge. Possibly insufficient imperfection.');
end
%Save model to file
nonlinearModel.save(NonlinearModelFile);              %Comment out if not solving, instead reading model from file


% Step (10) Post processing: evaluate results
%post_processing;

%% Display and save results

fprintf(1,'%s%s\n','Processing ended at: ',datestr(now));



