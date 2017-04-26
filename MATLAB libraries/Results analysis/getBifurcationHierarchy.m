function [bifurcation_dia result B2flag exception] = getBifurcationHierarchy(nonlinearModel, modifiedMidPlane,  compressionOrNot, plotOrNot)
%To extract bifurcation diagram (Amplitude vs compression) for a solved nonlinear model for hierarchical modes
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

%% Function definition
bifurcation_dia=[];
exception=[];
second_period_cutoff=0.25;                 %Second period exists if amplitude in FFT is at least this factor times 1st period

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
    x=mphinterp(nonlinearModel, 'x', 'coord', midplane.coordinates')';
    %y=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';
    y=mphinterp(nonlinearModel, 'y', 'coord', midplane.coordinates')';

    %Extension (um/um)
    if compressionOrNot
        ep=mphglobal(nonlinearModel,'-epsilon');
    else
        ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    end
  
    %Evaluate amplitudes A1 and A2 at each ep
    Amp_1=[];Amp_2=[];
    B2flag=0;                                %Did bifurcate into 2nd mode (1:Yes, 0:No)
    %Perform FFT
    x=midplane.coordinates(:,1);
    N=size(x,1);
    Fs=N/L;
    Nfft=2^nextpow2(N);
    X=0.5*Fs*linspace(0,1,Nfft/2+1);
    y=y-ones(size(y,1),1)*0.5*(max(y)+min(y)); 
    %y=y-ones(size(y,1),1)*mean(y);
    Amp_1=zeros(size(ep));Amp_2=zeros(size(ep));
    for i=2:size(ep,1)
       Y=fft(y(:,i),Nfft)/N;
       Ym=2*abs(Y(1:Nfft/2+1));
       %Ym=Ym./max(Ym);
       peak_vals=findpeaks(Ym);
       peak_vals=sort(peak_vals,'descend');
       A1=peak_vals(1);
       A2=peak_vals(2);
       Amp_1(i)=A1;
       Amp_2(i)=A2;
    end
    
catch exception
end

%Evaluate and format results
bifurcation_dia=[ep Amp_1 Amp_2];
ep2_index=find((Amp_2./Amp_1) > second_period_cutoff,1,'first');

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
    plot(ep,Amp_1,'-*');hold on; plot(ep, Amp_2,'-r*'); grid on;
    xlabel('Compression (um/um)');
    ylabel('Amplitude of wrinkles (um)');
    title('Bifurcation diagram');
    legend('A_1','A_2');
end

end





