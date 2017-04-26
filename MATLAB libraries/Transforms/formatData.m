function data = formatData(Xdata, udata)
%To format post-processed data from COMSOL to data format defined in readExportedData
% Data being formatted are: X,Y,Z coordinates and the deformed coordinates x,y,z
% or the displacements u,v,w (differentiate via context of function call)
% Note: this version includes reading values for multiple parameters during
% parameter continuation in comsol or for multiple modes in linear buckling
% Displacements in all directions are exported even if displacements only along one direction is relevant
% Input: Xdata, udata
% Xdata: columns of data X, Y, Z
% udata: columns of u, v, w or x, y, z
%Note: format of udata is different from that of exported data. All u, v
%and w are bunched together instead of u,v,w arrangement it's u,u,v,v,w,w arrangement
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


%% Creating the header values

%Dimension of data
data.dim=size(Xdata,2);

%Get number of data points
data.nodes=size(Xdata,1);

%Get number of expression = total number of columns of udata
data.exp=size(udata,2);

%Number of mode shapes or continuation parameter values
data.nshapes=data.exp/data.dim;

%% Format the read data into mesh coordinates and exported expressions
if data.dim==1
    data.X=Xdata;
    data.exportedx=[];
    for cnt=1:1:data.exp
        data.exportedx=[data.exportedx udata(:,cnt)];
    end
else if data.dim==2
          data.X=Xdata(:,1);
          data.Y=Xdata(:,2);
          data.exportedx=[];data.exportedy=[];
          for cnt=1:1:data.exp/2
              data.exportedx=[data.exportedx udata(:,cnt)];
              data.exportedy=[data.exportedy udata(:, data.nshapes+cnt)];
          end
    else if data.dim==3
            data.X=Xdata(:,1);
            data.Y=Xdata(:,2);
            data.Z=Xdata(:,3);
            data.exportedx=[];data.exportedy=[];data.exportedz=[];
          for cnt=1:1:data.exp/3
              data.exportedx=[data.exportedx udata(:,cnt)];
              data.exportedy=[data.exportedy udata(:,data.nshapes+cnt)];
              data.exportedz=[data.exportedz udata(:,2*data.nshapes+cnt)];
          end
        end
    end
end

end

