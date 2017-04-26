%% Step 5: Export mesh and mid-plane coordinates

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

%% Step definitions
%Set-up file names for export steps
linearModel.result.export('mesh1').set('filename', originalMesh);


%% Step (5a) Export original mesh and coordinates from original mesh of the linear-buckling study
linearModel.result.export('mesh1').run;
mesh=readMesh(originalMesh);
fidwrite=fopen(meshCoordinates,'w');    
fprintf(fidwrite,mesh.dataformat,mesh.coordinates');
fclose(fidwrite);

%% Step (5b) Generate mid-plane coordinates
fidwrite=fopen(midPlaneCoordinates,'w'); 

L=mphglobal(linearModel,'L');
H=mphglobal(linearModel,'H');
W=mphglobal(linearModel,'W');
hf=mphglobal(linearModel,'hf');

if mesh.dim==2              %2-D geometry
    coordinates=zeros(Nmp,2);
    coordinates(:,1)=0:L(1)/(Nmp-1):L(1); coordinates(:,2)=(H(1) + 0.5*hf(1)); 
else
    if mesh.dim==3          %3-D geometry
        coordinates=zeros(Nmp*WVsL*Nmp,3);
        X_temp=0:L(1)/(Nmp-1):L(1);
        Y_temp=0:W(1)/(Nmp*WVsL-1):W(1);
        [X_temp Y_temp]=meshgrid(X_temp,Y_temp);
        coordinates(:,1)=X_temp(:); coordinates(:,2)=Y_temp(:);
        coordinates(:,3)=(H(1) + 0.5*hf(1)); 
    end
end

fprintf(fidwrite,mesh.dataformat,coordinates');
fclose(fidwrite);