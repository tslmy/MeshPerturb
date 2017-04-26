function [epsilon_t nt nt_high nt_low exception] = getPhaseTransition(nonlinearModel, modifiedMidPlane, criterion)
%To identify the epsilon at phase transition point for a solved nonlinear model (complex hierachical patterns) 
% Input: (nonlinearModel, modifiedMidPlane, criterion)
% nonlinearModel: Solved COMSOL nonlinear comsol model (model object type)
% modifiedMidPlane: File name that contains imperfection-modified mid-plane coordinates
% criterion: Which criterion is used for identifying transition point [0: Period based, 1: Total Energy based, 2: Plate energy based]
% Output: [epsilon_t nt nt_high nt_low exception]
% epsilon_t: epsilon value at the point of phase transition from mode locked-in to hierarchy
% nt: %Step number for transition (at this step hirerachy is guaranteed, just below this mode-lockin is guaranteed)  
% nt_high: step number for Upper limit of epsilon in transition zone
% nt_low: step number for Lower limit of epsilon in transition zone
% exception: Error message
% Note: Period criterion: A2/A1> threshold, Ai is amplitude of i_th period
% Note: Total energy criterion: Curvature (of energy vs epsilon) goes negative
% Note: Plate energy criterion: Plate energy vs epsilon curvature becomes negative

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


%% Initialize
exception=[];
nt_low=0;
nt_high=0;

%% Define parameters
second_period_cutoff=0.0325;                 %Second period exists if amplitude in FFT is at least this factor times 1st period
infinity_factor=2.5;                        %Change in curvature must be higher than this factor to classify as infinity 

try 
    %% Get parameters
    %Get parameters of the model
    [L unit_L]=mphglobal(nonlinearModel,'L','SolNum','end');      %Length
    %H=mphglobal(nonlinearModel,'H','SolNum','end');              %H
    %hf=mphglobal(nonlinearModel,'hf','SolNum','end');            %hf
    [nsteps unit_n]=mphglobal(nonlinearModel,'nsteps'); nsteps=nsteps(1);      %Number of steps in epsilon ramp-up
    geom=nonlinearModel.geom('geom1');
    dim=geom.getSDim;                                           %Space dimension of model
    %Get periods
    imp_period=mphglobal(nonlinearModel,'I_period','SolNum','end');
    nat_period=mphglobal(nonlinearModel,'linear_period','SolNum','end');
    
    ratio_critical=2*3/(1+2*(imp_period/nat_period)^3);
    
    %% Read results
    %Get mid-plane coordinates 
    midplane=readCoordinates(modifiedMidPlane, dim);
    %Get deformed state
    v=mphinterp(nonlinearModel, 'v', 'coord', midplane.coordinates')';
    y=mphinterp(nonlinearModel, 'y', 'coord', midplane.coordinates')';
    %Get compression
    ep=mphglobal(nonlinearModel,'epsilonp-epsilon');
    %Get deformation energy density
    %Es=mphglobal(nonlinearModel,'avop12(solid.Ws*(H+hf))');
    Es_bottom=mphglobal(nonlinearModel,'avop1(solid.Ws*H)');
    Es_top=mphglobal(nonlinearModel,'avop2(solid.Ws*hf)');
    %Es_combined=mphglobal(nonlinearModel,'avop12(solid.Ws*(H+hf))');
    Es=Es_bottom + Es_top;
        
catch exception
end

%% Identify phase for each step
%For case (0) and case (1)
if criterion==0||criterion==1
    if criterion==0                 %Based on period analysis

        %There are two phases: 0 -> only one period, 1 -> two periods
        phase=zeros(nsteps,1);

        %Perform FFT
        x=midplane.coordinates(:,1);
        N=size(x,1);
        Fs=N/L;
        Nfft=2^nextpow2(N);
        X=0.5*Fs*linspace(0,1,Nfft/2+1);
        %y=v-ones(size(v,1),1)*mean(v);
        y=y-ones(size(y,1),1)*mean(y);
        
        for i=1:nsteps
            Y=fft(y(:,i),Nfft)/N;
            Ym=2*abs(Y(1:Nfft/2+1));
            Ym=Ym./max(Ym);
            peak_vals=findpeaks(Ym);
            peak_vals=sort(peak_vals,'descend');
            %plot(X,Ym,'-*');

            %Identify phase
            if size(peak_vals,1)>1
                if peak_vals(2)/peak_vals(1) > second_period_cutoff
                    phase(i)=1;         %Hierarchical patterns exist  (more than one period in profile)                      
                end
            end
        end

        %Transition point
        nt=find(phase,1,'first');                   %Step number for transition (at this step hirerachy is guaranteed, just below this mode-lockin is guaranteed)
    else if criterion==1                %Based on discontinuity in energy density
            curvature=diff(diff(Es));
            curvature_base=curvature(1);        %Using 1st element as baseline
            %nt=find( (abs(curvature/curvature_base)>infinity_factor),1,'first')+1;    %Curvature goes to infinity
            nt=find(curvature<0,1,'first')+1;    %Curvature goes negative
            %plot(ep, Es)
            %plot(curvature);
        end
    end

    %% Evaluate epsilon for phase transition
    if ~isempty(nt)
        if nt>2
            et_low=ep(nt-1);            %Highest epsilon for guaranteed mode-lockin
            nt_low=nt-1;
        else
            et_low=0;
            nt_low=1;
        end
        et_high=ep(nt);                 %Lowest epsilon for guaranteed hierarchy
        nt_high=nt;
        epsilon_t=0.5*(et_low + et_high);
    else
        epsilon_t=ep(end);                     %This value indicates that phase is mode-locked in even at maximum epsilon
        nt_high=nsteps;
    end
end

%For case(2)
if criterion==2                %Based on disconitnuity in slope of plate energy density
  slope=diff(Es_top);
  ratio_slope=zeros(nsteps-2,1);
  for i=1:nsteps-2
      ratio_slope(i)=slope(i)/slope(i+1);
  end
          
  nt_low=find(diff(ratio_slope)<0,1,'first')+1;
  nt_high=find(diff(ratio_slope)<0,1,'last')+1;
  nt=floor(0.5*(nt_low+nt_high));
  if ~isempty(nt)
    if nt_low<=nsteps
      et_low=ep(nt_low);
    else et_low=ep(end);
    end
    if nt_high<=nsteps
      et_high=ep(nt_high);
    else et_high=ep(end);
    end
    epsilon_t=0.5*(et_low+et_high);
  else 
    epsilon_t=ep(end);                     %This value indicates that phase is mode-locked in even at maximum epsilon
  end
end
end





