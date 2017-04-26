function mesh = readMesh( originalMesh )
%Read mesh data generated via COMSOL 
% Mesh format is based on COMSOL mphtxt format
% Note: not an exact copy as this does not copy blank lines
% Note: Mesh without blank lines is readable in COMSOL
% Input: originalmesh: filename for the file that contains the original mesh
% Ouput: oldmesh: mesh information from the file
% mesh.dim = dimension, mesh.nodes = # of nodes, mesh.header = header
% of the file, mesh.coordinates = numeric mesh coordinates of the file, mesh.dataformat = 
% format of numeric data for text output, mesh.rof = rest of the file 

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

%%  Opening file for reading
fidread=fopen(originalMesh);                             
mesh.header=[];

%% Reading the header

flag_coord=0;                   %Are coordinates being read? 1=yes, 0=no
while ~flag_coord
    
    header=textscan(fidread,'%s %[^\n]',1);  %Read each line of the file
    
    %Identify dimension of mesh
    if strcmp(header{2},'# sdim')
        mesh.dim=str2double(header{1});
    end
    
    %Identify number of nodes
    if strcmp(header{2},'# number of mesh points')
        mesh.nodes=str2double(header{1});
    end
    
    %Check if mesh points begin
    flag_coord=strcmp(header{2},'Mesh point coordinates');
    
    %Write the read line to file
    outtext=strcat(header{1},{' '},header{2});  %Concatenate the strings to form the line
    mesh.header=[mesh.header sprintf('%s\n',outtext{:})];
end

%% Reading the mesh point coordinates

%Define all feasible column formats with max dim=3
all_formats_read={'%f','%f %f', '%f %f %f'};
all_formats_write={'%.16g\n','%.16g %.16g\n', '%.16g %.16g %.16g\n'};

%Read the numeric data; this data is not used for modification
%Reading only to ensure continuation of file pointer
formatRead=all_formats_read{mesh.dim};
formatWrite=all_formats_write{mesh.dim};
data_values=textscan(fidread,formatRead,mesh.nodes);

%Converting to coordinates
if mesh.dim==1
    coordinatesRead=[data_values{1}];
elseif mesh.dim==2
    coordinatesRead=[data_values{1} data_values{2}];
elseif mesh.dim==3
    coordinatesRead=[data_values{1} data_values{2} data_values{3}];
end

mesh.coordinates=coordinatesRead;
mesh.dataformat=formatWrite;

%% Reading the rest of the file
restOfFile=textscan(fidread,'%[^\n]');
mesh.rof=sprintf('%s\n',restOfFile{1}{:});
fclose(fidread);

end

