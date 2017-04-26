function [bifurcation_dia exception] = getBifurcation(nonlinearModel, modifiedMidPlane, plotOrNot)
%To extract bifurcation diagram (Amplitude vs compression) for a solved nonlinear model 
% Input: (nonlinearModel, modifiedMidPlane, plotOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0= don't plot
% Output: [bifurcation_dia exception]
% bifurcation_dia: [compression(um/um) Amplitude(um)]
% exception: Error message

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

%% Function
bifurcation_dia=[];
exception=[];

try 
    %% Get parameters
    %Get all the geometric parameters of the model
    [H unit_H]=mphglobal(nonlinearModel,'H'); H=H(1);           %Height of base layer
    [L unit_L]=mphglobal(nonlinearModel,'L'); L=L(1);           %Length
    [hf unit_hf]=mphglobal(nonlinearModel,'hf'); hf=hf(1);      %Height of top layer
    %[W unit_W]=mphglobal(nonlinearModel,'W'); W=W(1);           %Depth/width of top/bottom layers
    geom=nonlinearModel.geom('geom1');
    dim=geom.getSDim;                                           %Space dimension of model

    %% Read results
    %Get mid-plane coordinates 
    midplane=readCoordinates(modifiedMidPlane, dim);
    %size(midplane.coordinates)
    v=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';
    %size(v)

    %Peak to valley height 
    v_value=0.5*(max(v)-min(v));v_value=v_value';
    ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    
catch exception
end

%Format results
bifurcation_dia=[ep v_value];
                
%% Plot results
if plotOrNot
    figure;
    plot(ep,v_value,'-*');
    xlabel('Compression (um/um)');
    ylabel('Amplitude of wrinkles (um)');
    title('Bifurcation diagram');
end

end





