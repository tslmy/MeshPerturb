%% To post-process all Non-linear studies in a given folder

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


%% Directory operations & excel file name
clear all;clc;
setStudyNames;
cd(rootdir);

%% Write status of operation to file
logfid=fopen(log_file,'a');
fprintf(1,'%s%s\n','Post processing of nonlinear analysis .mph files started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Post processing of nonlinear analysis .mph files started at: ',datestr(now));

%% Read all comsol study files in the directory
l_files=dir('linear_analysis_*.mph');         %List of comsol linear analysis files
nl_files=dir('nonlinear_analysis_*.mph');     %List of comsol non-linear analysis files
mpl_files=dir('oldmidplane_*.txt');           %List of mid-plane coordinate files (original)
mpn_files=dir('newmidplane_*.txt');           %List of mid-plane coordiante files (after imperfection)

%% Match studies and coordinate files
l_no=size(l_files,1);                         %Number of linear models
nl_no=size(nl_files,1);                       %Number of nonlinear models  
linear=repmat({''},l_no,1);                  %List of [linear models]  
nonlinear=repmat({''},[l_no,nl_no]);        %List of nonlinear models, each row corresponds to a specific linear model, each column is weight   
coordinate_files=repmat({''},l_no,nl_no); %List of coordinate files arranged by row:linear model #, col: weight # 

%Match linear analysis model
for i=1:l_no
    %Linear analysis model
    filename=l_files(i).name;
    l_i=strrep(filename,'.mph','');l_i=strrep(l_i,'linear_analysis_','');
    l_i=str2double(l_i);            %File number
    if ~isnan(l_i)
        linear(l_i)={filename};
    end
end

%Arrange coordinate files by linear model number and nonlinear number
nl_perlinear=0;                    %Total number of nonlinear models per linear model
for i=1:size(mpn_files,1)
    filename=mpn_files(i).name;
    mpn_i=strrep(filename,'.txt','');mpn_i=strrep(mpn_i,'newmidplane_','');
    
    %Identifying linear study number and weight number
    %mpn_linear: linear study number; mpn_weight: weight number
    [mpn_linear mpn_nl]=strtok(mpn_i,'_');            
    mpn_nl=strtok(mpn_nl,'_');
    mpn_nl=str2double(mpn_nl);
    mpn_linear=str2double(mpn_linear);
    if mpn_nl>nl_perlinear
        nl_perlinear=mpn_nl;
    end
    
    if ~isnan(mpn_linear) && ~isnan(mpn_nl) 
        coordinate_files(mpn_linear,mpn_nl)={filename};
    end
end

%Match nonlinear analysis model and coordinate file name
for i=1:nl_no
        
    filename=nl_files(i).name;
    nl_i=strrep(filename,'.mph','');nl_i=strrep(nl_i,'nonlinear_analysis_','');
    [nl_linear nl_nonlinear]=strtok(nl_i,'_');
    nl_nonlinear=strtok(nl_nonlinear,'_'); 
    nl_linear=str2double(nl_linear);nl_nonlinear=str2double(nl_nonlinear);
    
    if ~isnan(nl_nonlinear) && ~isnan(nl_linear) 
        nonlinear(nl_linear,nl_nonlinear)={filename};
    end
  
end
    
%% Post-process files

fprintf(1,'%s\t%i\t%s\t%s\n\n','Total',nl_no,'Nonlinear models in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n\n','Total',nl_no,'Nonlinear models in directory',rootdir);

%Non-linear analysis

p_names=repmat({''},[1 10]);        %Parameter names
r_names=repmat({''},[1 4]);         %Variable names
study_name_base=study_name;

skipped_models=[];
import com.comsol.model.util.*;
cnt_nl=0;
for i=1:l_no                        %Each linear model
    
    table_sheet1=[]; table_sheet2=[]; table_sheet3=[];     %Table of parameters and results from all studies
    
    %Excel file name for this run 
    study_name=strrep(study_name_base,'_0.xlsx',strcat('_',num2str(i),'.xlsx'));
    
    for j=1:nl_no               %Each nonlinear model
              

            message=strcat('Post-processing model #...',num2str(j));
            fprintf(1,'%s\n',message);
            fprintf(logfid,'%s\n',message);

            try                                     %Skip model if any exception occurs
                %Create model
                model_tag=strcat('Model',num2str((i-1)*nl_no+j));

                %Load model
                model=mphload(nonlinear{i,j},model_tag);

                %Read process parameters
                [parameters units p_u_v p_names]=readParameters(model);
                weight=mphglobal(model,'weight','SolNum', 'end');
                imp_period=mphglobal(model,'I_period','SolNum', 'end');
                linear_period=mphglobal(model,'linear_period','SolNum', 'end');
                soltime=round(str2double(char(model.param.get('soltime'))));
                
                %Read result of model
                [result excpt]=getPhase(model,coordinate_files{i,j},0);
                
                %Tabulate result for excel file
                table_sheet1=[table_sheet1; j parameters(1:end-1) result(1:end)];
                
                
               %Write header information
                header=[{'Model #'} p_names(1:end-1) ' ' {'Period ratio (p_p/p_n)'} {'Period ratio (p_m/p_n)'} {'Amplitude ratio (A_p/A_n)'} {'Curvature (1/um)'} {'Phase (1:H, 0:N, -1:L)'}];
                xlswrite(study_name,header,1);

                %Write post-processed results
                if ~isempty(table_sheet1)
                    xlswrite(study_name,table_sheet1(:,1:10),1,'A2');
                    xlswrite(study_name,table_sheet1(:,11:end),1,'L2');
                end

            catch exception

                skipped_models=[skipped_models ((i-1)*nl_no +j)];
                message=strcat('Skipped model #...',num2str((i-1)*nl_no+j));
                fprintf(1,'%s\n',message);
                fprintf(logfid,'%s\n',message);
            end

            %Clear/remove model
            ModelUtil.remove(model_tag);
            clear model;
    end
end

%Display end of post-processing message
fprintf(1,'\n%s\t%i\t%s\n%s\t%i\t%s\n','Post-processed all',i,'models','Skipped',size(skipped_models,2),'models');
fprintf(logfid,'\n%s\t%i\t%s\n%s\t%i\t%s\n','Post-processed all',i,'models','Skipped',size(skipped_models,2),'models');
if ~isempty(skipped_models)
    fprintf(1,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
    fprintf(logfid,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
end


%% End of processing
fprintf(1,'%s%s\n','End of post-processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of post-processing at: ',datestr(now));

fclose('all');
cd ..;