function [] = writeResult(result, filename)
% Write result of non-linear analysis to a text file
% result format is [epsilon period amplitude epsilon_c] 
% Inputs: result, filename
% Input: filename: Name of file to be written

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

%%  Opening file for writing & initializing values
fidwrite=fopen(filename,'w');       

%Define file format
dataformat='';
for i=1:size(result,2)-1
    dataformat=strcat(dataformat,{'%.16g '});
end
dataformat=strcat(dataformat,{'%.16g\n'});

%% Writing the parameters
%Write parameters to file
fprintf(fidwrite,dataformat{1},result');

%Close file
fclose(fidwrite);

end

