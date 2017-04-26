function imperfection = getPrepattern(rawData,weight,imp_period, natural_period, plateThickness,height)
%Generates prepatterns to be added to mesh coordinates (as imperfection to mesh) 
% Input: (rawData,weight,imp_period, nominal_period, plateThickness,height)
% rawData: raw mode shape displacements exported from COMSOL
% weight: multiplier by which displacements are weighted before adding to
% coordinates (is a column matrix, number of rows=number of mode shapes)
% imp_period: Period of imperfections
% natural_period: Natural period
% plateThickness: thickness of the plate (in units as specified in calling function)
% height: height of foundation (in units as specified in calling function)
% Output: imperfection (number of rows = nodes, number of columns =dim)
% imperfection= plate thickness * (weight(i) * u(i)/max(u(i))

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


%% Set switch_mode: 
% switch_mode=0 is default imperfection based on buckling mode shapes
% switch_mode=1 is externally introduced imperfection
switch_mode=1;

%% Evaluate imperfections
factor_x_y=1;                         %ratio of max x displacement to max y displacement (dim=2 case)
factor_x_z=1;                         %ratio of max x displacement to max z displacement (dim=3 case)
factor_y_z=1;                         %ratio of max y displacement to max z displacement (dim=3 case)

    if rawData.dim==1
        imp.x=rawData.exportedx;
        imp.x = bsxfun(@rdivide,imp.x,max(imp.x));
        imp.x = plateThickness * imp.x * weight; 
        imperfection = imp.x;
    
    else if rawData.dim==2
            if ~switch_mode
                imp.x = rawData.exportedx;
                imp.y = rawData.exportedy;
            else
                weight=max(weight);
                [u v]=shape2D(rawData,plateThickness, height, imp_period,natural_period,weight);
                imp.x = u;
                imp.y = v;
            end
            
            if (max(imp.y)~=0); 
                factor_x_y=max(imp.x)/max(imp.y);
                imp.y = bsxfun(@rdivide,imp.y,max(imp.y));
            end;
            if (max(imp.x)~=0); imp.x = bsxfun(@rdivide,imp.x,max(imp.x)); end;
            imp.x = plateThickness * imp.x * factor_x_y * weight;
            imp.y = plateThickness * imp.y * weight;
            imperfection = [imp.x imp.y];
       
        else if rawData.dim==3
                if ~switch_mode
                    imp.x = rawData.exportedx;
                    imp.y = rawData.exportedy;
                    imp.z = rawData.exportedz;
                else
                    weight=max(weight);
                    imp.x = zeros(size(rawData.X));
                    imp.y = zeros(size(rawData.Y));
                    imp.z = shape3D(rawData,plateThickness,height, period);
                end
                
                if max(imp.z)~=0; 
                    factor_x_z=max(imp.x)/max(imp.z);
                    factor_y_z=max(imp.y)/max(imp.z);
                    imp.z = bsxfun(@rdivide,imp.z,max(imp.z)); 
                end;
                if (max(imp.x)~=0); imp.x = bsxfun(@rdivide,imp.x,max(imp.x)); end;
                if max(imp.y)~=0 ; imp.y = bsxfun(@rdivide,imp.y,max(imp.y)); end;
               
                imp.x = plateThickness * imp.x * factor_x_z * weight;
                imp.y = plateThickness * imp.y * factor_y_z * weight;
                imp.z = plateThickness * imp.z * weight;
                imperfection = [imp.x imp.y imp.z];
                
            end
        end
    end
end

function [u v]=shape2D(data, hf, height, imp_period, natural_period,weight)
% Generates the modified Y for a given X corresponding to the shape defined by the function

%Step function
%v=(data.Y>=h).*5*h;
%v=~(data.X<7.5 | data.X>12.5).*v;

%Cosine solution
%v=(data.Y>=h).*(cos(2*pi*data.X/period));

%Cosine solution with higher order
%zeta=1;                              %Ratio of 2nd to 1st mode 
%zeta=0;
%v=1*(data.Y>=h).*(cos(2*pi*data.X/period) + zeta*cos(pi*data.X/period));

%Cosine solution with higher period
%zeta=1;                              %Ratio of 2nd to 1st mode 
%v=-1*(data.Y>=h).*(cos(2*pi*data.X/period) + zeta*cos(4*pi*data.X/period));

%Exponentially decaying along height
k=2*pi/(natural_period);
%z=(data.Y<=height).*(data.Y-height) - (data.Y>height).*(data.Y-height);     %For double sided samples
z=(data.Y<=height).*(data.Y-height) + (data.Y>height).*0;                    %For imperfection=h throughout the top film   

%Pre-multiplier for u and v that is dependent on z 
do_u=(data.Y>0).*(k*z).*exp(k*z);                     %With constraint u=0 at data.Y=0
do_v=(data.Y>0).*(1-k*z).*exp(k*z);                                 %With constraint u=0 at data.Y=0

%Evaluating mesh point displacement
do_u=do_u*(imp_period/natural_period).*(imp_period<natural_period) + do_u.*(imp_period>=natural_period);        %Using reduced u displcement for imp_period/natural_period<1
Lu=(floor(2*max(data.X)/imp_period))*imp_period/2;                          %Length over which u is applied
do_u=do_u.*(data.X<=Lu);                        %No u at boundary    

%v=v/(imp_period/natural_period).*(imp_period<natural_period) + v.*(imp_period>=natural_period);        %Using increased v displcement for imp_period/natural_period<1

%Periodic along x
u=do_u.*sin(2*pi*data.X/imp_period);
v=do_v.*cos(2*pi*data.X/imp_period);

%Implementing constraint: constant plate thickness (using equations for parallel curves)
Den= sqrt(1 +  (2*pi*weight*hf/imp_period).^2*(sin(2*pi*data.X/imp_period).^2));
d=(data.Y-height);     %Distance of parallel curve
du_top=(2*pi*weight*hf*d./(imp_period*Den)).*sin(2*pi*data.X/imp_period);
dv_top= weight*hf*cos(2*pi*data.X/imp_period) + d./Den;
%u=u.*(data.Y<=height) + du_top/(weight*hf).*(data.Y>height);
%v=v.*(data.Y<=height) + dv_top/(weight*hf).*(data.Y>height);

end

function w=shape3D(data,h,height, period)
% Generates the modified Z for a given X,Y corresponding to the shape defined by the
% function

%w=(data.Z>=h).*sin(data.X).*sin(data.Y);

%Step function
%w=(data.Z>=1.5).*5*h;
%w=~(data.X<1.25 | data.X>3.75).*w;
%w=~(data.Y<1.6 | data.Y>1.8).*w;

%Cosine solution with higher order
zeta=0;                              %Ratio of 2nd to 1st mode 
period=1.18;
w=1*(data.Z>=h).*(cos(2*pi*data.Y/period) + zeta*cos(pi*data.Y/period));

end