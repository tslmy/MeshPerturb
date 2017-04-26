function [length exception] = getPlateLength(nonlinearModel, modifiedMidPlane, plotOrNot)
%To extract plate (top film) length for a solved nonlinear model 
% Input: (nonlinearModel, modifiedMidPlane, plotOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0= don't plot
% Output: [length exception]
% length: length of plate for each step during epsilon ramp up (um) 
% exception: Error message

L_measured=[];
exception=[];

try 
    %% Get parameters
    geom=nonlinearModel.geom('geom1');
    dim=geom.getSDim;                                           %Space dimension of model

    %% Read results
    %Get mid-plane coordinates 
    midplane=readCoordinates(modifiedMidPlane, dim);
    ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    
    %Evaluating length of plate 
    x_coord=mphinterp(nonlinearModel, 'x', 'coord', midplane.coordinates')';
    y_coord=mphinterp(nonlinearModel, 'y', 'coord', midplane.coordinates')';
    L_measured=sum(sqrt(diff(x_coord).^2 + diff(y_coord).^2))';                %Measured length of plate
    
    
catch exception
end

%Format results;
length=L_measured;
                
%% Plot results
if plotOrNot
    figure;
    plot(ep,length,'-*');
    xlabel('Compression (um/um)');
    ylabel('Length of top plate (um)');
    title('Change in length with compression');
    length_compression=length(1)*(1-ep);            %Length due to pure compression
    hold on;
    plot(ep,length_compression,'.-r');
    legend('Actual length','Length for hypothetical pure compression')
end

end