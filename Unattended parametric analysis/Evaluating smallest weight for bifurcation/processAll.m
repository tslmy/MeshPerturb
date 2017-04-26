%% To process (run) all Non-linear studies in a given folder
% The steps are: (1) Load linear model
%                (2) Generate non-linear model seed (with parameters from linear model)
%                (3) Obtain minimum weight for convergence

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

%% Directory operations
clear all;clc;
setStudyNames;                    %File names for studies set in this file         

%% Write status of operation to file
log_file=strcat(rootdir,log_file); logfid=fopen(log_file,'a');
study_name=strcat(rootdir,study_name);
fprintf(1,'%s%s\n','Evaluation of minimum weight for convergence started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Evaluation of minimum weight for convergence started at: ',datestr(now));
set_filenames;              %Rest of filenames defined in this .m file

%% Set system parameters
Nmp=1000;                           %Number of mid-plane coordinates along length (used in step 5)
WVsL=1;                             %Ratio of number of points along width to length (used in step 5)

%% Read all linear comsol study files in the root directory
cd(rootdir);
l_files=dir('linear_analysis_*.mph');     %List of comsol non-linear analysis files
l_no=size(l_files,1);                    %Number of nonlinear models  
cd ..;

%% Process/solve models
import com.comsol.model.util.*;
ModelUtil.showProgress(true);
fprintf(1,'%s\t%i\t%s\t%s\n\n','Total',l_no,'Linear models in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n\n','Total',l_no,'Linear models in directory',rootdir);

skipped_models=[];              %Number of models skipped during processing
table=[];                       %Tabulated result

for i=1:l_no
    
    message=strcat('Solving model #...',num2str(i));
    fprintf(1,'\n%s\n',message);
    fprintf(logfid,'\n%s\n',message);
    try                                     %Skip model if any exception occurs
        
        
        %Extract model number
        filename=l_files(i).name;
        l_i=strrep(filename,'.mph','');l_i=strrep(l_i,'linear_analysis_','');
        model_num=str2double(l_i);            %File number
        
        fprintf(1,'%s\n','Loading linear model...');
        fprintf(logfid,'%s\n','Loading linear model...');
        
        %Load linear model from file
        model_tag=strcat('Model',model_num);
        linearModel=mphload(strcat(pwd, rootdir,'.\',filename),model_tag);
        [parameters units p_u_v p_names]=readParameters(linearModel);
        
        %Generating non-linear model with zero weight
        fprintf(1,'%s\n','Extracting mesh & mode shapes from linear model...');
        fprintf(logfid,'%s\n','Extracting mesh & mode shapes from linear model...');
        
        % Step 5: Export mesh and mid-plane coordinates
        step5;                                          %Step 5 in this file

        % Step (6): Export u,v,w at mesh point and mid-plane coordinates from linear buckling
        step6;                                          %Step 6 in this file

        % Step (7) Evaluate the initial imperfection with zero weight
        weight_factor=0;
        step7;                                          %Step 7 in this file
        
        %% Obtain the smallest weight that ensures bifurcation
        fprintf(1,'%s\n','Evaluating minimum weight for bifurcation...');
        fprintf(logfid,'%s\n','Evaluating minimum weight for bifurcation...');
        
        modes=zeros(data_for_Mesh.nshapes,1);
        modes(weighted_mode)=1;                     %Selecting which mode to be used (Defined in step 7)
        weight=getLowWeightLimit(model_num, parameters, units, mesh, data_for_Mesh, midPlaneCoordinates, data_for_MidPlane,h_plate, modes);

        %% Generate results
        %Tabulate result for excel file
        table=[table; parameters(1:end) weight];
        header=[p_names(1:end)  ' ' 'Minimum weight'];
        xlswrite(study_name,header,1);
        xlswrite(study_name,table(:,1:10),1,'A2');
        xlswrite(study_name,table(:,11:end),1,'L2');
    
    
    catch exception
        skipped_models=[skipped_models i];
        message=strcat('Skipped model #...',num2str(i));
        fprintf(1,'%s\n',message);
        fprintf(logfid,'%s\n',message);
    end
    
end

%% Display end of post-processing message
fprintf(1,'%s\t%i\t%s\n%s\t%i\t%s\n','Solved all',i,'models','Skipped',size(skipped_models,2),'models');
fprintf(logfid,'%s\t%i\t%s\n%s\t%i\t%s\n','Solved all',i,'models','Skipped',size(skipped_models,2),'models');
if ~isempty(skipped_models)
    fprintf(1,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
    fprintf(logfid,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
end


%% End of processing
fprintf(1,'%s%s\n','End of post-processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of post-processing at: ',datestr(now));
fclose('all');
