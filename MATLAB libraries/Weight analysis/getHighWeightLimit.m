function [weight_high weights bflags epsilon Amps] = getHighWeightLimit(model_num, parameters, units, mesh, data_for_Mesh, midPlaneCoordinates, data_for_MidPlane, h_plate, modes)
%To obtain the weight for largest imperfection that leads to bifurcation
% 
% Input: (model_num, parameters, units, mesh, data_for_Mesh, midPlaneCoordinates, data_for_MidPlane, h_plate, modes)
% root: Root directory for study
% mesh: Original mesh from linear buckling analysis (mesh format is defined in file readMesh.m)
% data_for_Mesh: Mode shapes from linear buckling analysis (data format is defined in file readData.m)
% midPlaneCoordinates: Coordinates of mid-plane (original i.e., undeformed)  
% data_for_MidPlane: Mode shapes from linear buckling analysis at mid plane coordinates
% h_plate: Thickness of plate
% modes: List of modes that contribute to imperfection. (Column matrix) Modes that
% contribute are indicated by 1 and that don't are indicated by 0
% logfile: Logfile
% resultFile: file that contains results of weight analysis (epsilon vs amplitude)
% Ouput: [weight_low weights bflags epsilon Amps]
% weight_high: Largest weight that leads to bifurcation
% weights: List of all weights 
% bflags: Bifurcation status at weight value (1=bifurcated, 0=not bifurcated)
% epsilon: Compressive load 
% Amps: Amplitude of mid-plane deformation (each row corresponds to one weight value)

% Criterion for bifurcation: (Amplitude of midplane)/(A due to imperfection) > 1+margin
%Note: search starts from lowest value and moves up until the weight does not change

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


%% Initialization

%Variables
minWeight=0.1;                            %Lower bound for weight search
maxWeight=0.15;                        %Upper bound for weight search
limitWeight=2;                          %Absolute limit for weight upper bound
%step=maxWeight/25;                     %Step size or resolution for search (weight is accurate within this value)
step=0.01;
weight_high=minWeight;                       %Weighting factor
modes=modes/sum(modes);                 %Normalized mode contributions(sum=1)
flag=1;                                 %Search stop condition
bflag=1;                                %Bifurcation occurs? 1 Yes, 0 No
margin=0.75;                        %Margin for bifurcation criterion

%File names
setStudyNames;
log_file=strcat(rootdir,log_file); logfid=fopen(log_file,'a');
weight_results=strcat(rootdir,weight_results);
modifiedMesh=strcat(rootdir,'.\newmesh_0.mphtxt');             %New mesh is written to this file  
modifiedMidPlane=strcat(rootdir,'.\newmidplane_0.txt');        %File that contains mid-plane coordinates with imperfection but before non-linear analysis

%File names for model run number
weight_results=strrep(weight_results,strcat('_',num2str(0),'.xlsx'),strcat('_',num2str(model_num),'.xlsx'));
modelFile=strcat(pwd, rootdir, '.\nonlinear_analysis_',num2str(model_num),'.mph');

%% Searching for the smallest weight factor
run_number=0;
skip=0;                                 %Counter for non-convergence; Don't skip analyzing (default value)

%Initialization
weights=[]; bflags=[]; Amps=[];etimes=[];
header={'epsilon'  ' '};

while flag
    run_number=run_number+1;
    weight=0.5*(maxWeight+minWeight);
    
    fprintf(1,'%s%f%s','Running non-linear analysis at weight=',weight,'...');
    fprintf(logfid,'%s%f%s','Running non-linear analysis at weight=',weight,'...');
        
    %Open files
    fidwrite_mesh=fopen(modifiedMesh,'w'); 
    fidwrite_midp=fopen(modifiedMidPlane,'w');
    
    %Evaluate imperfection for current weight value
    imperfection_Mesh=getImperfection(data_for_Mesh, weight*modes,h_plate);
    imperfection_MidPlane=getImperfection(data_for_MidPlane, weight*modes,h_plate);
    
    %Write header to new mesh
    coord=readCoordinates(midPlaneCoordinates,mesh.dim);
    fprintf(fidwrite_mesh,'%s\n',mesh.header);

    %Write data to the file
    MeshToWrite = mesh.coordinates + imperfection_Mesh;
    fprintf(fidwrite_mesh,mesh.dataformat,MeshToWrite');

    % Writing the rest of the file: no change in this part
    fprintf(fidwrite_mesh,'%s\n',mesh.rof);

    %Generating mid-plane coordinates with imperfection
    MidPlaneToWrite = coord.coordinates + imperfection_MidPlane;
    fprintf(fidwrite_midp,coord.dataformat,MidPlaneToWrite');
   
    %Generate and run the new non-linear analysis model
    model=nonlinear_analysis_seed(modifiedMesh);
    model.comments(strcat('Imperfection weight = ', num2str(weight)));
    
    %Update parameters of non-linear seed model with parameters from linear model
    model.param.set('L',strcat(num2str(parameters(1)),{' ['},units(1),{']'}));
    model.param.set('H',strcat(num2str(parameters(2)),{' ['},units(2),{']'}));
    model.param.set('W',strcat(num2str(parameters(3)),{' ['},units(3),{']'}));
    model.param.set('hf',strcat(num2str(parameters(4)),{' ['},units(4),{']'}));
    %model.param.set('epsilonp',parameters(5));
    %model.param.set('epsilon0',parameters(6));
    %model.param.set('nsteps',parameters(7));
    model.param.set('Et',strcat(num2str(parameters(8)),{' ['},units(8),{']'}));
    model.param.set('Mub',strcat(num2str(parameters(9)),{' ['},units(9),{']'}));
    %model.param.set('epsilon',parameters(10));
    %model.save(modelFile); 
    
    % Check if model converges, skip if model does NOT converge
    try
        ticID=tic;                  %Start stopwatch for timing the iteration
        model.sol('sol1').runAll;               %Solve model
        model.save(modelFile);                  %Save after running model
        
        %Verify if bifurcation occurs

        %Get mid-plane coordinates 
        midplane=readCoordinates(modifiedMidPlane, mesh.dim);

        %Get y displacements at mid-plane coordinates
        %v=mphinterp(model, 'v', 'coord', midplane.coordinates', 'solnum', 'end')';
        v=mphinterp(model, 'v', 'coord', midplane.coordinates')';
        
        %Peak to valley height based criterion
        v_value=0.5*(max(v)-min(v));
        
        %Amplitude due to imperfection
        %Aimp=weight*h_plate;
        
        %Check for bifurcation, bflag=1 =>bifurcation occurs
        %bflag =  ((v_value(end)/Aimp)>(1 + margin));        
        %Based on amplitude
        bflag =  ~isempty(find(diff(diff(v_value))<0,1,'first'));   %Change in curvature
                
        %Reset counter for non-convergence
        skip=0;
        
        %Generate results
        epsilon=mphglobal(model,'epsilonp-epsilon');    
        weights=[weights weight];
        bflags=[bflags bflag];
        Amps=[Amps; v_value];
        
        elapsedTime=toc(ticID);                  %Stop stopwatch for timing the iteration
        etimes=[etimes elapsedTime];
        
        %Write result to file
        if bflag
            fprintf(1,'%s\n','Bifurcated');
            fprintf(logfid,'%s\n','Bifurcated');
        else
            fprintf(1,'%s\n','Did not bifurcate');
            fprintf(logfid,'%s\n','Did not bifurcate');
        end   
        header=[header strcat('Weight = ',num2str(weight),' Bifurcated = ',num2str(bflag))];
        xlswrite(weight_results,header,1);
        xlswrite(weight_results,epsilon,1,'A2');
        xlswrite(weight_results,Amps',1,'C2');
        %Write status of bifurcation to sheet 2
        xlswrite(weight_results,[{'Weight'}, {' '} ,{'Did bifurcate?'}],2);
        xlswrite(weight_results,weights',2,'A2');
        xlswrite(weight_results,bflags',2,'C2');
        %Write elapsed time to sheet 3
        xlswrite(weight_results,[{'Weight'}, {' '} ,{'Elapsed time (s)'}],3);
        xlswrite(weight_results,weights',3,'A2');
        xlswrite(weight_results,etimes',3,'C2');
        
    catch exception
        skip=skip+1;                %Analysis skipped for this run => No convergence
        bflag=0;                    %No convergence => no bifurcation
        fprintf(1,'%s\n','Skipped');
        fprintf(logfid,'%s\n','Skipped');
    end
    
    %Update weight limits
    if bflag
        weight_high=weight;                  %This is a guaranteed bifurcation weight value
        minWeight=weight;
    else
        if run_number>1
            minWeight=weight;
        end 
    end
    
    %Expand search space if intial weight is too high for convergence
    if (~bflag) && (run_number==1)
        minWeight=0.5*minWeight;
    end
        
    %Criterion to stop the search
    %Based on exhausted search space
    if (maxWeight-minWeight)/step <= 1; flag=0; end;
    
    %Based on exceeding absolute upper bound of weight
    if maxWeight > limitWeight
        flag=0;
        weight_low=-1;                  %Error state indicating that there is no convergence even at weight=1;
    end
    
    %if skip>=2                              %Stop execution if 2 continuous skips 
        %flag=0;
    %end
    
    %Clear memory
    clear model;
    fclose(fidwrite_mesh);
    fclose(fidwrite_midp);
    
end

%Delete temporary files
delete(modifiedMesh,modifiedMidPlane);

end











