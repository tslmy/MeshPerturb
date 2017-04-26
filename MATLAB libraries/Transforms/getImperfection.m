function imperfection = getImperfection(rawData,weight,plateThickness)
%Generates weighted imperfection to be added to mesh coordinates 
% Input: (rawData,weight,plateThickness)
% rawData: raw mode shape displacements exported from COMSOL
% weight: multiplier by which displacements are weighted before adding to
% coordinates (is a column matrix, number of rows=number of mode shapes)
% plateThickness: thickness of the plate (in units as specified in calling function)
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
switch_mode=0;

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
                [u v]=shape2D(rawData,plateThickness, height, period);
                imp.x = u;
                imp.y = v;
                weight=max(weight);
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
                    imp.x = zeros(size(rawData.X));
                    imp.y = zeros(size(rawData.Y));
                    imp.z = shape3D(rawData,plateThickness,height, period);
                    weight=max(weight);
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

function [u v]=shape2D(data,h, height, period)
% Generates the modified Y for a given X corresponding to the shape defined by the
% function

%v=(data.Y>=3).*sin(2*pi*data.X/5);
%v=~(data.X<8 | data.X>12).*v;

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
period_n=period;
alpha=0.5*pi/period_n;

%do_uv=1/(height*exp(pi*height/period_n));
do_v=1/(exp(alpha*height)-1);
do_u=do_v * alpha/(3+alpha);


%d_u=1*(data.Y<=height)*do_uv.*(height-data.Y).*exp(pi*data.Y/period_n) + 1*(data.Y>height);                 %Decay factor for u
%d_v=1*(data.Y<=height)*do_uv.*data.Y.*exp(pi*data.Y/period_n) + 1*(data.Y>height);                 %Decay factor for v

%d_u=1*(data.Y<=height)*do_u.*(1+alpha*(height-data.Y)).*(exp(alpha*data.Y)-1) + 1*(data.Y>height);                 %Decay factor for u
d_u=1*(data.Y<=height)*do_u.*(alpha*(height-data.Y)).*(exp(alpha*data.Y)-1) + 0*(data.Y>height);
d_v=1*(data.Y<=height)*do_v.*(1+alpha*(height-data.Y)-alpha*(height-data.Y).*cos(2*pi*data.X/period)).*(exp(alpha*data.Y)-1) + 1*(data.Y>height);                 %Decay factor for v

%d_v=1*(data.Y<=height)*do_u.*(1+alpha*(height-data.Y)).*(exp(alpha*data.Y)-1) + 1*(data.Y>height);                 %Decay factor for v

u=d_u.*sin(4*pi*data.X/period);
v=d_v.*cos(2*pi*data.X/period);

%Test imperfection
%v = zeros(size(data.Y));
%u=v;
%v=1*(data.Y>=height).*(cos(2*pi*data.X/period));

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