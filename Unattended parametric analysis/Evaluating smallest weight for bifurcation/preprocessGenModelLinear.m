%% Step (5) Generate models for all parameters 
% (DO NOT change this when study changes)

% Run all models for the given set of parameters

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
for i=1:model_total
   
    fprintf(1,'%s\n',strcat('Pre-processing model #...',num2str(i)));
    fprintf(logfid,'%s\n',strcat('Pre-processing model #...',num2str(i)));
    
    %Generate file names for models and coordinate files
    LinearModelFile=strrep(LinearModelFile,strcat('_',num2str(i-1),'.mph'),strcat('_',num2str(i),'.mph'));
    NonlinearModelFile=strrep(NonlinearModelFile,strcat('_',num2str(i-1),'.mph'),strcat('_',num2str(i),'.mph'));
    midPlaneCoordinates=strrep(midPlaneCoordinates,strcat('_',num2str(i-1),'.txt'),strcat('_',num2str(i),'.txt'));
    modifiedMidPlane=strrep(modifiedMidPlane,strcat('_',num2str(i-1),'.txt'),strcat('_',num2str(i),'.txt'));
    
    linearModel=seed_model;                 %Reset model to seed_model
    try
        
        %Reset parameter values in linear analysis model
        linearModel.param.set('L',strcat(num2str(parameters(i,1)),{' ['},units(1),{']'}));
        linearModel.param.set('H',strcat(num2str(parameters(i,2)),{' ['},units(2),{']'}));
        linearModel.param.set('W',strcat(num2str(parameters(i,3)),{' ['},units(3),{']'}));
        linearModel.param.set('hf',strcat(num2str(parameters(i,4)),{' ['},units(4),{']'}));
        linearModel.param.set('epsilonp',parameters(i,5));
        linearModel.param.set('epsilon0',parameters(i,6));
        linearModel.param.set('nsteps',parameters(i,7));
        linearModel.param.set('Et',strcat(num2str(parameters(i,8)),{' ['},units(8),{']'}));
        linearModel.param.set('Mub',strcat(num2str(parameters(i,9)),{' ['},units(9),{']'}));
        linearModel.param.set('epsilon',parameters(i,10));

        %Save model file
        linearModel.save(LinearModelFile);              
    
        %Solve linear model with new parameters
        if (sum(ns(1:4)))
            linearModel.geom('geom1').run;
            linearModel.mesh('mesh1').run;
        end
        linearModel.sol('sol1').runAll;
        
        %Save model file
        linearModel.save(LinearModelFile);     
       
    catch exception
        skipped_models=[skipped_models i];
        fprintf(1,'%s\n',strcat('Skipped model #...',num2str(i)));
        fprintf(logfid,'%s\n',strcat('Skipped model #...',num2str(i)));
    end
    
    clear linearModel;
end