%% To process (run) all Non-linear studies in a given folder
% The steps are: (1) Load unsolved model
%                (2) Run steps/solve model
%                (3) Save model (with same file name) if no error in
%                step(2), else skip saving this model

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
rootdir='.\Vary ep V2';      %Directory containing files to be post-processed            
cd(rootdir);
log_file='.\log.txt';     %Log file (same as pre-processing log file)  

%% Write status of operation to file
logfid=fopen(log_file,'a');
fprintf(1,'%s%s\n','Processing (solving) of nonlinear analysis .mph files started at: ',datestr(now));
fprintf(logfid,'%s%s\n','Processing (solving) of nonlinear analysis .mph files started at: ',datestr(now));

%% Parameters for nonlinear studies
nl_no=11;                       %Number of nonlinear models to be generated  
ep_values=[0.001:0.0025:0.026];

%% Process/solve models
fprintf(1,'%s\t%i\t%s\t%s\n','Total',nl_no,'Nonlinear models to be solved in directory',rootdir);
fprintf(logfid,'%s\t%i\t%s\t%s\n','Total',nl_no,'Nonlinear models to be solved in directory',rootdir);

skipped_models=[];              %Number of models skipped during processing
import com.comsol.model.util.*;
ModelUtil.showProgress(true); 

for i=1:nl_no
    
    filename=strcat('nonlinear_analysis_',num2str(i),'.mph');
    message=strcat('Solving model #...',num2str(i));
    fprintf(1,'%s\n',message);
    fprintf(logfid,'%s\n',message);
    try                                     %Skip model if any exception occurs
        %Load model
        model=mphload('nonlinear_analysis_0.mph');
        
        %Modify model parameter ep
        model.param.set('epsilonp',ep_values(i));
        model.param.set('nsteps','15');
        
        %Save model
        model.save(strcat(pwd,{'\'},filename));
        
        %Run/solve model
        model.sol('sol1').runAll;
        
        %Save model after solving
        model.save(strcat(pwd,{'\'},filename));
        
        %Remove from memory
        clear model;

    catch exception
        skipped_models=[skipped_models i];
        message=strcat('Skipped model #...',num2str(i));
        fprintf(1,'%s\n',message);
        fprintf(logfid,'%s\n',message);
    end
    
end

%% Display end-of-processing message
fprintf(1,'%s\t%i\t%s\n%s\t%i\t%s\n','Processed all',nl_no,'models','Skipped',num2str(size(skipped_models,2)),'models.');
fprintf(logfid,'%s\t%i\t%s\n%s\t%i\t%s\n','Processed all',nl_no,'models','Skipped',num2str(size(skipped_models,2)),'models.');
fprintf(1,'%s%s\n','End of processing at: ',datestr(now));
fprintf(logfid,'%s%s\n\n','End of processing at: ',datestr(now));

fclose(logfid);
cd ..;


