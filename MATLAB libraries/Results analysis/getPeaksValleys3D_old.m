function [peaks valleys] = getPeaksValleys3D_old(PlateCoordinateFile)
%To extract peaks and valleys from 3-D COMSOL non-linear analysis results
% Input: (PlateCoordinateFile)
% PlateCoordinateFile: File exported from COMSOL analysis that contains plate coordinates of the plate midplane
% Output: [peaks valleys]
% peaks = [peak_loc_para1(x value) peak_loc_para1(y value) peak_height_para1(z value)...]
% valleys = [valley_loc_para1(x value) valley_loc_para1(y value) valley_depth_para1(z value)... ]

% Data being read from file are: X,Y,Z coordinates and the deformed coordinates x,y,z
% Peask and vallyes are read for all parameters during parameter continuation in COMSOL
% Heights and depths are relative to undeformed mid-plane position
% Z is the mid-plane position at undeformed position (X,Y) (may include the initial imperfection)
% Displacements in all directions are exported even if displacements only along one/two directions are relevant


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
%%%% IMPORTANT: First and last parameter values are not exported in this version
 
%% File open for read
fid=fopen(PlateCoordinateFile);

%% Reading the header
%The header has 8 lines of text
%Each row has 3 columns
header=textscan(fid,'%s %s %s %*[^\n]',8);

%Get the dimension of the mesh = number of columns of mesh coordinates 
dim=str2double(header{3}(4))

%Get number of nodes in the mesh
nodes=str2double(header{3}(5));

%Get number of expression = number of columns of data
exp=str2double(header{3}(6));

%Define the format of the rows
if dim==1
    formatval='%f';
    for cnt=1:1:exp
        formatval=strcat(formatval,' %f');
    end
else if dim==2
          formatval='%f %f';
          for cnt=1:1:exp/2
              formatval=strcat(formatval,' %f %f');
          end
    else if dim==3
            formatval='%f %f %f';
          for cnt=1:1:exp/3
              formatval=strcat(formatval,' %f %f %f');
          end
        end
    end
end

%Read the numeric data
data_values=textscan(fid,formatval,nodes);
fclose(fid);

% Format the read data into mesh coordinates and displacements
if dim==1
    X=data_values{1};
    x=[];
    for cnt=1:1:exp
        x=[x data_values{cnt+1}];
    end
else if dim==2
          X=data_values{1};
          Y=data_values{2};
          x=[];y=[];
          for cnt=1:1:exp/2
              x=[x data_values{(cnt)*2 + 1}];
              y=[y data_values{(cnt)*2 + 2}];
          end
    else if dim==3
            X=data_values{1};
            Y=data_values{2};
            Z=data_values{3};
            x=[];y=[];z=[];
          for cnt=1:1:exp/3
              x=[x data_values{(cnt)*3 + 1}];
              y=[y data_values{(cnt)*3 + 2}];
              z=[z data_values{(cnt)*3 + 3}];
          end
        end
    end
end

%% Identify peaks and valleys 

peaks=[]; valleys=[];
midplane_height=Z(1);           %Height of the mid-plane of the plate

for cnt=2:1:exp/dim-1           %First and last parameter values (during parametric sweep) not evaluated                 
    
    %Get all peaks and valleys
    %Note: peaks and valleys at the boundary are not identified
    [peak_height peak_loc_x]=findpeaks(z(:,cnt));
    peak_height=peak_height - midplane_height; 
    
    [valley_depth valley_loc_x]=findpeaks(-z(:,cnt));
    valley_depth=-valley_depth - midplane_height;
    
    %Convert location to length dimension
    peak_loc_x=(peak_loc_x-1)*max(x(:,cnt))/size(x,1);
    peak_loc_y=(peak_loc_y-1)*max(y(:,cnt))/size(y,1);
    valley_loc_x=(valley_loc_x-1)*max(x(:,cnt))/size(x,1);
    valley_loc_y=(valley_loc_y-1)*max(y(:,cnt))/size(y,1);
    
    %Store values in peaks and valleys
    peaks=[peaks, peak_loc_x, peak_loc_y, peak_height];
    valleys=[valleys, valley_loc_x, valley_loc_y, valley_depth];
    
end
end