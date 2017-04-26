function coord = readCoordinates( coordinateFile, dim )
%Read a list of coordinates
% Coordinate format is [X Y Z] 
% Input: coordinateFile: file that contains the coordinates
% Input: dim: dimension of the coordinates (1,2, or 3)
% Ouput: coord: coordinates from the file
% coord.dim = dimension, coord.nodes = # of coordinates, 
% coord.coordinates = numeric coordinates of the file, coord.dataformat = 
% format of numeric data for text output 

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

%%  Opening file for reading & initializing values
fidread=fopen(coordinateFile);                    
coord.dim=dim;

%% Reading the coordinates

%Define all feasible column formats with max dim=3
all_formats_read={'%f','%f %f', '%f %f %f'};
all_formats_write={'%.16g\n','%.16g %.16g\n', '%.16g %.16g %.16g\n'};

%Read the file and converting to numeric data
formatRead=all_formats_read{coord.dim};
formatWrite=all_formats_write{coord.dim};
data_values=textscan(fidread,formatRead);
fclose(fidread);
coord.nodes=size(data_values{1},1);

%Converting to coordinates
if coord.dim==1
    coordinatesRead=[data_values{1}];
elseif coord.dim==2
    coordinatesRead=[data_values{1} data_values{2}];
elseif coord.dim==3
    coordinatesRead=[data_values{1} data_values{2} data_values{3}];
end

coord.coordinates=coordinatesRead;
coord.dataformat=formatWrite;

end

