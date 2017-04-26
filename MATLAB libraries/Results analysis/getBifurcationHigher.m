function [bifurcation_dia result B2flag exception] = getBifurcationHigher(nonlinearModel, modifiedMidPlane,  compressionOrNot, plotOrNot)
%To extract bifurcation diagram (Amplitude vs compression) for a solved nonlinear model for higher modes
% Input: (nonlinearModel, modifiedMidPlane, plotOrNot, compressionOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% compressionOrNot: 1: Pure compression, 0: with pre-stretch
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0= don't plot
% Output: [bifurcation_dia result B2flag exception]
% bifurcation_dia: [compression(um/um); Amplitude_1(um) ;Amplitude_2(um)]'
% result: [2nd bifurcation point(um/um); (A1-A2) at 2nd bifurcation point (um)]'
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

try 
    %% Get parameters
    %Get all the geometric parameters of the model
    [H unit_H]=mphglobal(nonlinearModel,'H'); H=H(1);           %Height of base layer
    [L unit_L]=mphglobal(nonlinearModel,'L'); L=L(1);           %Length
    [hf unit_hf]=mphglobal(nonlinearModel,'hf'); hf=hf(1);      %Height of top layer
    %[W unit_W]=mphglobal(nonlinearModel,'W'); W=W(1);          %Depth/width of top/bottom layers
    geom=nonlinearModel.geom('geom1');
    dim=geom.getSDim;                                           %Space dimension of model

    %% Read results
    %Get mid-plane coordinates 
    midplane=readCoordinates(modifiedMidPlane, dim);
    v=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';
    u=mphinterp(nonlinearModel, 'u', 'coord', midplane.coordinates')';

    %Extension (um/um)
    if compressionOrNot
        ep=mphglobal(nonlinearModel,'-epsilon');
    else
        ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    end
  
    %Evaluate amplitudes A1 and A2 at each ep
    Amp_1=[];Amp_2=[];
    B2flag=0;                                %Did bifurcate into 2nd mode (1:Yes, 0:No)
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
       
       %Evaluate Amp_1 and Amp_2: amplitudes
       A1=[];A2=[];
       if ~isempty(extrema)
           for j=1:size(extrema,1)-2
               this_amp=0.5*(extrema(j+1,2)-extrema(j,2));
               next_amp=0.5*(extrema(j+2,2)-extrema(j+1,2));
               max_amp=max(abs(this_amp),abs(next_amp));
               min_amp=min(abs(this_amp),abs(next_amp));
               if (sign(this_amp)==1) && (sign(next_amp)==-1)     %If peak exists between the three points
                   A1=[A1 max_amp];
                   A2=[A2 min_amp];
               end
           end
       else
           A1=0.5*(max(v(:,i))-min(v(:,i))); A2=A1;
       end
       
       A1=mean(A1); A2=mean(A2);
       Amp_1=[Amp_1; A1];
       Amp_2=[Amp_2; A2];
       
    end
    
catch exception
end

%Evaluate and format results
bifurcation_dia=[ep Amp_1 Amp_2];
ep2_index=find(diff(Amp_2)<0,1,'first');

if ~isempty(ep2_index)
    %ep2=0.5*(ep(ep2_index-1)+ep(ep2_index-1));
    ep2=ep(ep2_index);
    ep3=1.25*ep2;
    ep3_index=find(ep3<ep,1,'first');
    
    %delA=Amp_1(ep2_index)-Amp_2(ep2_index);
    delA=Amp_1(ep3_index)-Amp_2(ep3_index);
    
    result=[ep2 delA];
    B2flag=1;
else
    result=[];
end

                
%% Plot results
if plotOrNot
    figure;
    plot(ep,Amp_1,'-*');hold on; plot(ep, Amp_2,'-r*');
    xlabel('Compression (um/um)');
    ylabel('Amplitude of wrinkles (um)');
    title('Bifurcation diagram');
    legend('A_1','A_2');
end

end





