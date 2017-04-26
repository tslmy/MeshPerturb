function [energy units exception] = getEnergy(nonlinearModel, plotOrNot)
%To extract energy for a solved nonlinear model 
% Input: (nonlinearModel, plotOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0= don't plot
% Output: [energy units exception]
% energy: [Energy density of system; Energy density of top plate; Energy density of bottom ]
% units: units of energy density(default is J/m2)
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

%% Function definition
exception=[];

try 
    %% Read results
    ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    % Evaluate average strain energies over different domains (1: bottom, 2: top layer)
    [Es_bottom unit_Es]=mphglobal(nonlinearModel,'avop1(solid.Ws*H)');
    Es_top=mphglobal(nonlinearModel,'avop2(solid.Ws*hf)');
    Es=Es_bottom + Es_top;
catch exception
end

%Format results
energy=[Es Es_top Es_bottom];
units=unit_Es;
                
%% Plot results
if plotOrNot
    figure;
    plot(ep,Es);
    xlabel('Compression (um/um)');
    ylabel(strcat({'Energy density ('},units,{')'}));
    title('Bifurcation diagram for energy');
    hold on;
    plot(ep,Es_top,'-r*');
    plot(ep,Es_bottom,'-kd');
    legend('System','Plate','Base');
end

end