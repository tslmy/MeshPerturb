%% To post-process all Linear studies in a given folder

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
study_name='study.xlsx';           %Excel file that contains final tabulated results
rootdir='Test';            %Directory containing .mph model files to be post-processed            
cd(rootdir);
result_dir='.\Results';             %Directory containing results (text files wwith parameters and results)
mkdir(result_dir);
log_file='.\log.txt';     %Log file (same as pre-processing log file)

%% Write status of operation to file
logfid=fopen(log_file,'a');
fprintf(1,'%s%s\n','Processing (solving) of linear analysis .mph files started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Processing (solving) of linear analysis .mph files started at: ',datestr(now));

%% Read all comsol study files in the directory
l_files=dir('linear_analysis_*.mph');         %List of comsol linear analysis files
nl_files=dir('V2_nonlinear_analysis_*.mph');     %List of comsol non-linear analysis files
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
    
end


%% Post-process files

fprintf(1,'%s\t%i\t%s\t%s\n','Total',l_no,'Linear models in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n','Total',l_no,'Linear models in directory',rootdir);

%Linear analysis
table=[];                           %Table of parameters and results from all studies
p_names=repmat({''},[1 10]);        %Parameter names
period=[];

skipped_models=[];
import com.comsol.model.util.*;

Nmp=1000;           %Number of points for interpolation along X
WVsL=1;             %Width versus length    
for i=1:l_no
    
    message=strcat('Post-processing model #...',num2str(i));
    fprintf(1,'%s\n',message);
    fprintf(logfid,'%s\n',message);
    
    try                                     %Skip model if any exception occurs
        %Create model
        model_tag=strcat('Model',num2str(i));
        %model=ModelUtil.create(model_tag);
        
        %Load model
        model=mphload(linear{i,1},model_tag);

        %Read process parameters
        [parameters units p_u_v p_names]=readParameters(model);
      
        %Read result of model
        %Only reading critical buckling strain
        eigen=mphglobal(model,'lambda');          %All eigen values
        first_mode=find(eigen>0,1,'first');     %First non-negative eigen mode number
        eigenc=eigen(first_mode);          %First non-negative eigen value
        
        %Calculate critical strain
        ec=0.1*parameters(5)*eigenc;                    %Critical buckling strain
        
        %Identify space dimension of model
        mp=mphmeshstats(model,'mesh1');                %Mesh properties
        dim=mp.sdim;                                            %Space dimension
       
        %Generate mid plane coordinates
        L=parameters(1); H=parameters(2); W=parameters(3); hf=parameters(4); 

        if dim==2              %2-D geometry
            coordinates=zeros(Nmp,2);
            coordinates(:,1)=0:L(1)/(Nmp-1):L(1); coordinates(:,2)=(H(1) + 0.5*hf(1)); 
        else
            if dim==3          %3-D geometry
                coordinates=zeros(Nmp*WVsL*Nmp,3);
                X_temp=0:L(1)/(Nmp-1):L(1);
                Y_temp=0:W(1)/(Nmp*WVsL-1):W(1);
                [X_temp Y_temp]=meshgrid(X_temp,Y_temp);
                coordinates(:,1)=X_temp(:); coordinates(:,2)=Y_temp(:);
                coordinates(:,3)=(H(1) + 0.5*hf(1)); 
            end
        end
        
        %Get deformed coordinates at original mid-plane coordinates
        variable={'x','y','z'};                           %Format for extracting variables
        displacement=[];
        for j=1:dim
            displacement=[displacement mphinterp(model, variable{j}, 'coord', coordinates', 'solnum', first_mode)'];
        end
        %Format extracted data
        data_linear=formatData(coordinates, displacement);

        %Obtain wavelength and amplitude
        if dim==2
            [peaks valleys]=getPeaksValleys2D(data_linear);
            [half_wavelength amplitude] = getWaveAmp2D(peaks, valleys);
        else 
            [peaks valleys]=getPeaksValleys3D(data_linear);
            [half_wavelength amplitude] = getWaveAmp3D(peaks, valleys);
        end

        %Evaluate average period and amplitude
        period=2*mean(half_wavelength)';
        %period_1=period(find(eigen>0,1,'first'))       %First non-negative mode period
        amp=mean(amplitude)';
        
        %Tabulate result for excel file
        table=[table; parameters(1:end-1) period amp ec];
        
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
header=[p_names(1:end-1)  ' ' 'Period (um)' 'Amplitude (um)' 'ec'];
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