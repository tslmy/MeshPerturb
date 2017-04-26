function [phase exception] = getPhase(nonlinearModel, modifiedMidPlane, plotOrNot)
%To identify the phase for a solved nonlinear model (complex hierachical patterns) 
% Input: (nonlinearModel, modifiedMidPlane)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% plotOrNot: 1: plot fft, 0: Don't plot FFT
% Output: [phase exception]
% phase: [period_p/period_n period_m/period_n A_p/A_n curvature phase_val] 
% phase_val:'1' for hierarchical, '-1' for mode locked-in, '0' for natural mode 
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
phase=[];
exception=[];

%% Define parameters
second_period_cutoff=0.15;                 %Second period exists if amplitude in FFT is at least this factor times 1st period
period_tolerance=0.05;                     %Tolerance for period to match  

try 
    %% Get parameters
    %Get all the geometric parameters of the model
    [H unit_H]=mphglobal(nonlinearModel,'H'); H=H(1);           %Height of base layer
    [L unit_L]=mphglobal(nonlinearModel,'L'); L=L(1);           %Length
    [hf unit_hf]=mphglobal(nonlinearModel,'hf'); hf=hf(1);      %Height of top layer
    [period_n unit_pn]=mphglobal(nonlinearModel,'linear_period'); period_n=period_n(1);      %Natural period (um)
    [period_p unit_pp]=mphglobal(nonlinearModel,'I_period'); period_p=period_p(1);      %Primary (imperfection) period (um)
    [weight unit_w]=mphglobal(nonlinearModel,'weight'); weight=weight(1);      %Natural period (um)
    geom=nonlinearModel.geom('geom1');
    dim=geom.getSDim;                                           %Space dimension of model

    %% Read results
    %Get mid-plane coordinates 
    midplane=readCoordinates(modifiedMidPlane, dim);
    %Get deformed state
    v=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates', 'SolNum', 'end')';
    %Get compression
    ep=mphglobal(nonlinearModel,'epsilonp-epsilon','SolNum', 'end');
        
catch exception
end

%% Perform FFT 
x=midplane.coordinates(:,1);
y=v;

N=size(x,1);
Fs=N/L;
Nfft=2^nextpow2(N);

X=0.5*Fs*linspace(0,1,Nfft/2+1);
Y=fft(y,Nfft)/N;
Ym=2*abs(Y(1:Nfft/2+1));
Ym=Ym./max(Ym);

%% Identify phase
% Get input parameter values
period_ratio=period_p/period_n;
A_p=weight*hf;
A_n=period_n/pi*sqrt(ep);               %Estimate (assuming ec=0)
amplitude_ratio=A_p/A_n;

%Evaluate maximum curvature
kappa=4*pi^2*A_p/period_p^2;

%Measure actual period from peaks/valleys
[peak_height peak_loc]=findpeaks(y);
[valley_depth valley_loc]=findpeaks(-y);
        
%Convert location to length dimension
peak_loc=(peak_loc-1)*L/N;
valley_loc=(valley_loc-1)*L/N;
Peak=[peak_loc, peak_height];
valleys=[valley_loc, valley_depth];

%Measure period
extrema=[Peak; valleys]; 
Namp=size(extrema,1)-1;                 %Number of peak-to-valley distances

%% Evaluating wavelength and amplitude
%Note: amplitude is -ve if extrema starts with a peak instead of a valley
half_wavelength=zeros(Namp,1);
peaksValleys=sortrows(extrema,1);
for cnt=1:Namp
    half_wavelength(cnt)=peaksValleys(cnt+1,1) - peaksValleys(cnt,1);
    amplitude(cnt)=abs(0.5*(peaksValleys(cnt+1,2) - peaksValleys(cnt,2)));
end 
period_measured=2*mean(half_wavelength);
amp_measured=mean(amplitude);

%Get phase
[peak_vals peak_locs]=findpeaks(Ym);
%X(peak_locs)
peak_vals=sort(peak_vals,'descend');
phase_val=0;

if peak_vals(2) > second_period_cutoff
    phase_val=1;                            %Hierarchical patterns exist  (more than one period in profile)                      
else 
    if abs((period_measured-period_p)/period_p) < period_tolerance
        phase_val=-1;                   %Mode lock-in
    end
    if abs(period_ratio-1)<1e-3
        phase_val=0;                    %Natural mode when imperfection period=natural period
    end
end

phase=[period_ratio period_measured/period_n amplitude_ratio kappa phase_val];
                
%% Plot results
if plotOrNot
    figure;
    plot(X, Ym,'-*');
    xlabel('Spatial frequency (1/um)');
    ylabel('Amplitude');
    title('FFT of wrinkle profile');
end

end





