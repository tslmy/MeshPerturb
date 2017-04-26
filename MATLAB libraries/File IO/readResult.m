function [result r_name bflag] = readResult(nonlinearModel, modifiedMidPlane)
% Read results via post processing of non-linear analysis model
% result format is [epsilon period amplitude epsilon_c]
% Inputs: nonlinearModel,  modifiedMidPlane
% Input: nonlinearModel: COMSOL model object
% Input: modifiedMidPlane: file name for mid-plane coordinates (with imperfection)
% Outputs: result, r_name, bflag 
% Ouput: result: model result
% Output: r_name: name of variables
% Output: bflag: did model bifurcate? (0=No, 1=Yes)

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

%% Identify space dimension of model
mp=mphmeshstats(nonlinearModel,'mesh1');                %Mesh properties
dim=mp.sdim;                                            %Space dimension

%%Perform post-processing of model
%Get thickness of top plate
h_plate=mphglobal(nonlinearModel,'hf','SolNum','end');
zero=0.06*h_plate;                              %Effective zero threshold for amplitude bifurcation(um)

%Get mid-plane coordinates 
midplane=readCoordinates(modifiedMidPlane, dim);

%Get all the strain values from the model
epsilon=mphglobal(nonlinearModel,'epsilon');       %Current prestretch strain values 

%Get critical bifurcation strain value (ec)
variable={'u','v','w'};
dh=mphinterp(nonlinearModel, variable{dim}, 'coord', midplane.coordinates')';
dh_pv=(max(dh)-min(dh))-zero;                       %Peak to valley height with reference to zero bifurcation height

%Check if bifurcation occurs
bflag=(dh_pv(end)>0);

%Bifurcation occurs when v_value turns positive from negative
eci=find(sign(dh_pv)+1,1);                        %Index of strain value at which bifurcation has occured
if eci==1
    ec=epsilon(eci);                      %Model already bifurcated at zero strain  
else
    ec=0.5*(epsilon(eci)+epsilon(eci-1));               %Critical bifurcation strain (mid point of not bifrucated and bifurcated strains)
end

%Get deformed coordinates at original mid-plane coordinates
variable={'x','y','z'};                           %Format for extracting variables
displacement=[];
for i=1:dim
    displacement=[displacement mphinterp(nonlinearModel, variable{i}, 'coord', midplane.coordinates')'];
end
%Format extracted data
data_nonlinear=formatData(midplane.coordinates, displacement);

%Obtain wavelength and amplitude
if dim==2
    [peaks valleys]=getPeaksValleys2D(data_nonlinear);
    [half_wavelength amplitude] = getWaveAmp2D(peaks, valleys);
else 
    [peaks valleys]=getPeaksValleys3D(data_nonlinear);
    [half_wavelength amplitude] = getWaveAmp3D(peaks, valleys);
end

%Evaluate average period and amplitude
period=2*mean(half_wavelength)';
amp=mean(amplitude)';

%% Format result
result=[epsilon period amp ec*ones(size(epsilon))];
r_name={'epsilon', 'period', 'amplitude', 'epsilon_critical'};

end

