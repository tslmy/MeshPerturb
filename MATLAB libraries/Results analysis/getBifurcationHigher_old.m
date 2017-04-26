function [bifurcation_dia B2flag exception] = getBifurcationHigher_old(nonlinearModel, modifiedMidPlane,  compressionOrNot, plotOrNot)
%To extract bifurcation diagram (Amplitude vs compression) for a solved nonlinear model for higher modes
% Input: (nonlinearModel, modifiedMidPlane, plotOrNot, compressionOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% compressionOrNot: 1: Pure compression, 0: with pre-stretch
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0= don't plot
% Output: [bifurcation_dia B2flag exception]
% bifurcation_dia: [Amplitude(um) compression(um/um)]
% B2flag: Did bifurcate into 2nd mode (1:Yes, 0: No)
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
margin=0.001;            %Allowed margin of variation in adjacent amplitudes below which are considered same

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
    v=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';
    u=mphinterp(nonlinearModel, 'u', 'coord', midplane.coordinates')';
  
    %Peak to valley height 
    %v_value=0.5*(max(v)-min(v));v_value=v_value';
    
    %Extension (um/um)
    if compressionOrNot
        ep=mphglobal(nonlinearModel,'epsilon');
    else
        ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    end
  
    %Evaluate amplitudes A1 and A2 at each ep
    Amp_1=[];Amp_2=[];
    B2flag=0;                                %Did bifurcate into 2nd mode (1:Yes, 0: No)
    for i=1:size(ep,1)
       %Identify peaks and valleys
       [peak_height peak_loc]=findpeaks(v(:,i));
       [valley_depth valley_loc]=findpeaks(-v(:,i));
       valley_depth=-valley_depth;
       peak_x=midplane.coordinates(peak_loc,1)+u(peak_loc,i);                  %x location of peak
       valley_x=midplane.coordinates(valley_loc,1)+u(valley_loc,i);              %x position of valley 
       peaks=[peak_x peak_height];
       valleys=[valley_x valley_depth];
       extrema=sortrows([peaks; valleys],1);                    %Merge peaks and valleys and sort by X coordinate
       
       %Evaluate Amp_1 and Amp_2: apmlitudes
       A1=[];A2=[];
       B2flag=0; 
       if ~isempty(extrema)
           for j=1:size(extrema,1)-2
               this_amp=0.5*abs(extrema(j,2)-extrema(j+1,2));
               next_amp=0.5*abs(extrema(j+1,2)-extrema(j+2,2));
               max_amp=max(this_amp,next_amp);
               min_amp=min(this_amp,next_amp);
               if (max_amp/min_amp) > (1+margin)
                   B2flag=1;
                   A1=[A1 max_amp];
                   A2=[A2 min_amp];
               else
                   if ~B2flag        
                       A1=[A1 mean([max_amp,min_amp])];
                       A2=[A2 mean([min_amp,max_amp])];
                   end
               end
           end
       else
           A1=0.5*(max(v(:,i))-min(v(:,i))); A2=A1;
           
       end
       %A1=mean(A1);
       %A2=mean(A2);
       A1=min(A1);
       A2=min(A2);
       Amp_1=[Amp_1; A1];
       Amp_2=[Amp_2; A2];
    end

    %figure; 
    plot(ep,Amp_1,'-*');
    hold on; plot(ep,Amp_2,'r-*');
    %size(ep)
    %size(Amp_1)
    
catch exception
end

%Format results
%bifurcation_dia=[ep v_value];
                
%% Plot results
if plotOrNot
    %figure;
    %plot(ep,v_value,'-*');
    %xlabel('Compression (um/um)');
    %ylabel('Amplitude of wrinkles (um)');
    %title('Bifurcation diagram');
end

end





