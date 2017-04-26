%% Step (5) Generate models for all parameters 
% (DO NOT change this when study changes)

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

%% File name operations
modifiedMidPlane_base=modifiedMidPlane;
NonlinearModelFile_base=NonlinearModelFile;
LinearModelFile_base=LinearModelFile;

% Run all models for the given set of parameters

for i=1:model_total
   
    fprintf(1,'\n%s\n',strcat('Generating linear model #...',num2str(i)));
    fprintf(logfid,'\n%s\n',strcat('Generating linear model #...',num2str(i)));
    
    %Generate file names for models and coordinate files
    LinearModelFile=strrep(LinearModelFile_base,'_0.mph',strcat('_',num2str(i),'.mph'));
    
    clear linearModel;
    linearModel=seed_model;                 %Reset linear model to seed_model
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
        if (sum(steps(1:4)))
            linearModel.geom('geom1').run;
            linearModel.mesh('mesh1').run;
        end
        linearModel.sol('sol1').runAll;
        
        %Save model file
        linearModel.save(LinearModelFile);     
            
        % Step 5: Export mesh and mid-plane coordinates
        step5;                                          %Step 5 in this file

        % Step (6): Export u,v,w at mesh point and mid-plane coordinates from linear buckling
        step6;                                          %Step 6 in this file
        
        %Evaluate nominal period from linear analysis
        step7a;
        
        %Generate all nonlinear models for a specific linear model: vary imperfection weight and period 
        for j=1:nl_perlinear
            
            fprintf(1,'%s\n',strcat('Generating nonlinear model #...',num2str(j)));
            fprintf(logfid,'%s\n',strcat('Generating nonlinear model #...',num2str(j)));
            
            %Generate file names
            modifiedMidPlane=strrep(modifiedMidPlane_base,'_0.txt',strcat('_',num2str(i),'_',num2str(j),'.txt'));
            NonlinearModelFile=strrep(NonlinearModelFile_base,'_0.mph',strcat('_',num2str(i),'_',num2str(j),'.mph'));
            
            %Evaluate weight_factor and period for initial imperfection
            weight_factor=nominal_weight*parameter_multiplier_nl(j,1);
            imp_period=nominal_period*parameter_multiplier_nl(j,2);
            
            % Step (7) Evaluate the initial imperfection
            step7_ext_imp;                                           %Step 7 in this file

            % Step (8) Generate new modified mesh file & file containing mid-plane coordinates with imperfection 
            step8;                                           %Step 8 in this file
            
            % Step (9) Run the non-linear analysis model or load model from file
            %This seed model is the .m file (Change this if the .m file name changes)
            nonlinearModel=nonlinear_analysis_seed(modifiedMesh,weight_factor,imp_period,nominal_period);  
            
            %Copy parameters from linear model to nonlinear model
            match_param(linearModel, nonlinearModel);
            
            %Save model to file
            nonlinearModel.save(NonlinearModelFile);           
           
            %Clear model from memory
            clear nonlinearModel;
        end
       
    catch exception
        skipped_models=[skipped_models i];
        fprintf(1,'%s\n',strcat('Skipped model #...',num2str(i)));
        fprintf(logfid,'%s\n',strcat('Skipped model #...',num2str(i)));
    end
        
end