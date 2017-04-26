%% To post-process all Linear and Non-linear studies in a given folder

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

%%
clear all;clc;

%% Directory operations & excel file name
study_name='study.xlsx';           %Excel file that contains final tabulated results
rootdir='.\Test';            %Directory containing .mph model files to be post-processed            
cd(rootdir);
result_dir='.\Results';             %Directory containing results (text files wwith parameters and results)
mkdir(result_dir);
log_file='.\log.txt';     %Log file (same as pre-processing log file)

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
linear=repmat({''},l_no,2);                   %List of [linear models  , coordinate files]  
nonlinear=repmat({''},nl_no,2);               %List of [nonlinear models  , coordinate files]  

%Match linear analysis model and coordinate files
for i=1:l_no
    %Linear analysis model
    filename=l_files(i).name;
    l_i=strrep(filename,'.mph','');l_i=strrep(l_i,'linear_analysis_','');
    l_i=str2double(l_i);            %File number
    if ~isnan(l_i)
        linear(l_i,1)={filename};
    end
    
    %Coordinate file
    filename=mpl_files(i).name;
    mpl_i=strrep(filename,'.txt','');mpl_i=strrep(mpl_i,'oldmidplane_','');
    mpl_i=str2double(mpl_i);            %File number
    if ~isnan(mpl_i)
       linear(mpl_i,2)={filename};
    end
end

%Match nonlinear analysis model and coordinate files
for i=1:nl_no
    %Linear analysis model
    filename=nl_files(i).name;
    nl_i=strrep(filename,'.mph','');nl_i=strrep(nl_i,'nonlinear_analysis_','');
    nl_i=str2double(nl_i);            %File number
    if ~isnan(nl_i)
        nonlinear(nl_i,1)={filename};
    end
    
    %Coordinate file
    filename=mpn_files(i).name;
    mpn_i=strrep(filename,'.txt','');mpn_i=strrep(mpn_i,'newmidplane_','');
    mpn_i=str2double(mpn_i);            %File number
    if ~isnan(mpn_i)
        nonlinear(mpn_i,2)={filename};
    end
end
    
%% Post-process files

fprintf(1,'%s\t%i\t%s\t%s\n','Total',nl_no,'Nonlinear models in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n','Total',nl_no,'Nonlinear models in directory',rootdir);

%Linear analysis

%Non-linear analysis
table=[];                           %Table of parameters and results from all studies
p_names=repmat({''},[1 10]);        %Parameter names
r_names=repmat({''},[1 4]);         %Variable names

skipped_models=[];
import com.comsol.model.util.*;
for i=1:nl_no
    
    message=strcat('Post-processing model #...',num2str(i));
    fprintf(1,'%s\n',message);
    fprintf(logfid,'%s\n',message);
    
    %Generate file names for parameters and results
    p_file=strcat(result_dir,'.\parameters_nl_',num2str(i),'.txt'); % File name for parameters
    r_file=strcat(result_dir,'.\result_nl_',num2str(i),'.txt'); % File name for result

    try                                     %Skip model if any exception occurs
        %Create model
        model_tag=strcat('Model',num2str(i));
        %model=ModelUtil.create(model_tag);
        
        %Load model
        model=mphload(nonlinear{i,1},model_tag);

        %Read process parameters
        [parameters units p_u_v p_names]=readParameters(model);
        %Write process parameters to file
        writeParameters(parameters,p_file);

        %Read result of model
        [result r_names bflag]=readResult(model,nonlinear{i,2});
        %Write result to file
        writeResult(result,r_file);

        %Tabulate result for excel file
        table=[table; parameters(1:end-1) result(end,4) result(end,1:3)];
        
        %Check if model does not bifurcate
        if ~bflag
            message='Model did not bifurcate. Possible reason: weight_factor too low.';
            fprintf(1,'%s\n',message);fprintf(logfid,'%s\n',message);
        end
            
    catch exception
        
        skipped_models=[skipped_models i];
        message=strcat('Skipped model #...',num2str(i));
        fprintf(1,'%s\n',message);
        fprintf(logfid,'%s\n',message);
    end
    
    %Clear/remove model
    ModelUtil.remove(model_tag);
    clear model;
end

%Display end of post-processing message
fprintf(1,'%s\t%i\t%s\n%s\t%i\t%s\n','Post-processed all',i,'models','Skipped',size(skipped_models,2),'models');
fprintf(logfid,'%s\t%i\t%s\n%s\t%i\t%s\n','Post-processed all',i,'models','Skipped',size(skipped_models,2),'models');
if ~isempty(skipped_models)
    fprintf(1,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
    fprintf(logfid,'%s\t%s\n','Skipped model numbers: ',num2str(skipped_models));
end

%% Generate excel file

fprintf(1,'%s\n','Generating excel file...');
fprintf(logfid,'%s\n','Generating excel file...');

%Write header information
header=[p_names(1:end-1)  ' ' r_names(4) r_names(1:3)];
xlswrite(study_name,header,1);

%Write post-processed results
if ~isempty(table)
    xlswrite(study_name,table(:,1:9),1,'A2');
    xlswrite(study_name,table(:,10:end),1,'K2');
end

%% End of processing
fprintf(1,'%s%s\n','End of post-processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of post-processing at: ',datestr(now));

fclose(logfid);
cd ..;