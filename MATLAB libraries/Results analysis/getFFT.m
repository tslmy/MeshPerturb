function [FFT_spectrum ep exception] = getFFT(nonlinearModel, modifiedMidPlane,  compressionOrNot, plotOrNot)
%To extract FFT spectrum for a solved nonlinear model
% Input: (nonlinearModel, modifiedMidPlane, plotOrNot, compressionOrNot)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% compressionOrNot: 1: Pure compression, 0: with pre-stretch
% plotOrNot: Switch to determine if results plotted or not; 1=plot, 0=don't plot (plot's FFT spectrum for last ep
% Output: [FFT_spectrum exception]
% FFT_spectrum: [Ym_1 Xm_1 Ym_2 Xm_2...]  (Ym:Y and Xm=X in frequency domain; subscripts are ep step number)
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
FFT_spectrum=[];
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
    x=mphinterp(nonlinearModel, 'x', 'coord', midplane.coordinates')';
    y=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';

    %Extension (um/um)
    if compressionOrNot
        ep=mphglobal(nonlinearModel,'-epsilon');
    else
        ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    end
    
  
    %% Perform FFT
    x=midplane.coordinates(:,1);
    N=size(x,1);
    Fs=N/L;
    Nfft=2^nextpow2(N);
    X=0.5*Fs*linspace(0,1,Nfft/2+1);
    %y=y-ones(size(y,1),1)*0.5*(max(y)+min(y)); 
    y=y-ones(size(y,1),1)*mean(y);
    
    FFT_spectrum=zeros(size(X,2),2*size(ep,1));
    for i=2:size(ep,1)
       Y=fft(y(:,i),Nfft)/N;
       Ym=2*abs(Y(1:Nfft/2+1));
       FFT_spectrum(:,(i-1)*2+1)=X';
       FFT_spectrum(:,(i-1)*2+2)=Ym';
    end
    
catch exception
end

%% Plot results
if plotOrNot
    figure;
    plot(FFT_spectrum(:,end-1),FFT_spectrum(:,end),'-*');
    xlabel('Spatial frequency (1/um)');
    ylabel('Amplitude (um)');
    title('Frequency spectrum');
    axis([0, 5, 0, 1]);
end

end





