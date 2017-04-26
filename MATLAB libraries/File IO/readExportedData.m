function data = readExportedData(datafile)
%To read an exported data file from COMSOL
% Data being read are: X,Y,Z coordinates and the deformed coordinates x,y,z
% or the displacements u,v,w (differentiate via context of function call)
% Note: this version includes reading values for multiple parameters during
% parameter continuation in comsol or for multiple modes in linear buckling
% Displacements in all directions are exported even if displacements only along one direction is relevant
% Input: datafile: filename for the file that contains the exported data
% Ouput: data: X,Y,Z coordinates and x,y,z or u,v,w
% data.dim = dimension, data.nodes = # of nodes, data.exp = number of expressions exported 
% data.X, data.Y, data.Z = coordinates, data.exportedx, data.exportedy, 
% data.exportedz = exported x,y,z values or u,v,w values, data.nshapes = number of mode shapes or parameter values
% Note: each column in data.X, data.Y... represents a parameter value

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

%% Reading the header

% File open for read
fid=fopen(datafile);

%The header has 8 lines of text
%Each row has 3 columns
header=textscan(fid,'%s %s %s %*[^\n]',8);

%Get the dimension of the mesh = number of columns of mesh coordinates 
data.dim=str2double(header{3}(4));

%Get number of nodes in the mesh
data.nodes=str2double(header{3}(5));

%Get number of expression = number of columns of data for each parameter value
data.exp=str2double(header{3}(6));

%Number of mode shapes or continuation parameter values
data.nshapes=data.exp/data.dim;

%% Define the format of the rows
if data.dim==1
    formatval='%f';
    for cnt=1:1:data.exp
        formatval=strcat(formatval,' %f');
    end
else if data.dim==2
          formatval='%f %f';
          for cnt=1:1:data.exp/2
              formatval=strcat(formatval,' %f %f');
          end
    else if data.dim==3
            formatval='%f %f %f';
          for cnt=1:1:data.exp/3
              formatval=strcat(formatval,' %f %f %f');
          end
        end
    end
end

%% Read the numeric data
data_values=textscan(fid,formatval,data.nodes);
fclose(fid);

%% Format the read data into mesh coordinates and exported expressions
if data.dim==1
    data.X=data_values{1};
    data.exportedx=[];
    for cnt=1:1:data.exp
        data.exportedx=[data.exportedx data_values{cnt+1}];
    end
else if data.dim==2
          data.X=data_values{1};
          data.Y=data_values{2};
          data.exportedx=[];data.exportedy=[];
          for cnt=1:1:data.exp/2
              data.exportedx=[data.exportedx data_values{(cnt)*2 + 1}];
              data.exportedy=[data.exportedy data_values{(cnt)*2 + 2}];
          end
    else if data.dim==3
            data.X=data_values{1};
            data.Y=data_values{2};
            data.Z=data_values{3};
            data.exportedx=[];data.exportedy=[];data.exportedz=[];
          for cnt=1:1:data.exp/3
              data.exportedx=[data.exportedx data_values{(cnt)*3 + 1}];
              data.exportedy=[data.exportedy data_values{(cnt)*3 + 2}];
              data.exportedz=[data.exportedz data_values{(cnt)*3 + 3}];
          end
        end
    end
end

end

