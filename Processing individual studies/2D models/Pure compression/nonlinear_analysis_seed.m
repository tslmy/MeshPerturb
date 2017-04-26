function out = nonlinear_analysis_seed(modifiedMesh)
%
% nonlinear_analysis_seed.m
%
% Model exported on Jul 18 2013, 19:13 by COMSOL 4.2.0.228.

import com.comsol.model.*
import com.comsol.model.util.*

ModelUtil.showProgress(true);
model = ModelUtil.create('Model NL');

model.modelPath('.\Pure compression');

model.name('nonlinear_analysis_seed.mph');

model.comments('Linear buckling analysis');

model.param.set('L', '20e-6 [m]', 'Length of stamp');
model.param.set('H', '3e-6 [m]', 'Height of stamp');
model.param.set('W', '1e-3 [m]', 'Width of stamp');
model.param.set('hf', '20e-9[m]', 'Thickness of top film');
model.param.set('epsilonp', '0', 'Initial prestretch strain');
model.param.set('epsilon0', '-2e-2', 'Final strain');
model.param.set('epsilon', '0', 'Current strain value (varies from epsilonp to epsilon0)');
model.param.set('nsteps', '35', 'Number of steps for load ramp-up');
model.param.set('Et', '70e9 [Pa]', 'Young''s modulus of top layer');
model.param.set('Mub', '2e6 [Pa]', 'Modulus of base layer');

model.modelNode.create('mod1');

model.geom.create('geom1', 2);
model.geom('geom1').lengthUnit([native2unicode(hex2dec('00b5'), 'Cp1252') 'm']);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('imp1', 'Import');
model.mesh('mesh1').feature('imp1').set('source', 'native');
model.mesh('mesh1').feature('imp1').set('filename', modifiedMesh);
model.mesh('mesh1').run;

model.material.create('mat1');
model.material('mat1').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat1').propertyGroup.create('RefractiveIndex', 'Refractive index');
model.material.create('mat3');
model.material('mat3').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat3').propertyGroup.create('NeoHookean', 'Neo-Hookean');
model.material('mat3').selection.set([1]);

model.physics.create('solid', 'SolidMechanics', 'geom1');
%model.physics('solid').feature('lemm1').feature.create('iss1', 'InitialStressandStrain', 2);
%model.physics('solid').feature('lemm1').feature('iss1').selection.set([2]);
model.physics('solid').feature.create('hmm1', 'HyperelasticModel', 2);
model.physics('solid').feature('hmm1').selection.set([1]);
model.physics('solid').feature.create('sym1', 'SymmetrySolid', 1);
model.physics('solid').feature('sym1').selection.set([1 3]);
model.physics('solid').feature.create('roll1', 'Roller', 1);
model.physics('solid').feature('roll1').selection.set([2]);
model.physics('solid').feature.create('disp2', 'Displacement1', 1);
model.physics('solid').feature('disp2').selection.set([6 7]);

model.view('view1').axis.set('xmax', '21');
model.view('view1').axis.set('ymin', '-10.225907325744629');
model.view('view1').axis.set('ymax', '13.245924949645996');

model.material('mat1').name('Silica glass');
model.material('mat1').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat1').propertyGroup('def').set('electricconductivity', {'1e-14[S/m]' '0' '0' '0' '1e-14[S/m]' '0' '0' '0' '1e-14[S/m]'});
model.material('mat1').propertyGroup('def').set('thermalexpansioncoefficient', {'0.55e-6[1/K]' '0' '0' '0' '0.55e-6[1/K]' '0' '0' '0' '0.55e-6[1/K]'});
model.material('mat1').propertyGroup('def').set('heatcapacity', '703[J/(kg*K)]');
model.material('mat1').propertyGroup('def').set('relpermittivity', {'2.09' '0' '0' '0' '2.09' '0' '0' '0' '2.09'});
model.material('mat1').propertyGroup('def').set('density', '2203[kg/m^3]');
model.material('mat1').propertyGroup('def').set('thermalconductivity', {'1.38[W/(m*K)]' '0' '0' '0' '1.38[W/(m*K)]' '0' '0' '0' '1.38[W/(m*K)]'});
model.material('mat1').propertyGroup('Enu').set('youngsmodulus', 'Et');
model.material('mat1').propertyGroup('Enu').set('poissonsratio', '0.17');
model.material('mat1').propertyGroup('RefractiveIndex').set('n', {'1.45' '0' '0' '0' '1.45' '0' '0' '0' '1.45'});
model.material('mat3').name('PDMS elastic');
model.material('mat3').propertyGroup('def').set('relpermeability', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').propertyGroup('def').set('electricconductivity', {'3.030e7[S/m]' '0' '0' '0' '3.030e7[S/m]' '0' '0' '0' '3.030e7[S/m]'});
model.material('mat3').propertyGroup('def').set('thermalexpansioncoefficient', {'23.4e-6[1/K]' '0' '0' '0' '23.4e-6[1/K]' '0' '0' '0' '23.4e-6[1/K]'});
model.material('mat3').propertyGroup('def').set('heatcapacity', '900[J/(kg*K)]');
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').propertyGroup('def').set('density', '0.9700[kg/m^3]');
model.material('mat3').propertyGroup('def').set('thermalconductivity', {'201[W/(m*K)]' '0' '0' '0' '201[W/(m*K)]' '0' '0' '0' '201[W/(m*K)]'});
model.material('mat3').propertyGroup('Enu').set('youngsmodulus', '20e6[Pa]');
model.material('mat3').propertyGroup('Enu').set('poissonsratio', '0.49');
model.material('mat3').propertyGroup('NeoHookean').set('mu', 'Mub');
model.material('mat3').propertyGroup('NeoHookean').set('lambda', '1.33e9');

model.physics('solid').prop('d').set('d', 'W');
model.physics('solid').feature('lemm1').set('AdvMatRes', '1');
%model.physics('solid').feature('lemm1').feature('iss1').set('eil', {'epsilonp'; '0'; '0'; '0'; '-mat1.Enu.nu*epsilonp'; '0'; '0'; '0'; '0'});
model.physics('solid').feature('hmm1').set('kappa', '2e9');
model.physics('solid').feature('hmm1').set('NearlyIncompressible', '1');
model.physics('solid').feature('hmm1').set('minput_velocity_src', 'root.mod1.solid.u_tX');
model.physics('solid').feature('disp2').selection.active(false);
model.physics('solid').feature('disp2').set('U0', {'L*epsilon'; '0'; '0'});
model.physics('solid').feature('disp2').set('Direction', {'1'; '0'; '0'});

model.cpl.create('avop1', 'Average', 'geom1');
model.cpl('avop1').selection.set([1]);
model.cpl.create('avop2', 'Average', 'geom1');
model.cpl('avop2').selection.set([2]);
model.cpl.create('avop12', 'Average', 'geom1');
model.cpl('avop12').selection.set([1 2]);

model.mesh('mesh1').run;

model.study.create('std3');
model.study('std3').feature.create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std3');
model.sol('sol1').attach('std3');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('p1', 'Parametric');

%model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.create('se1', 'Segregated');

model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').feature.create('def', 'Deform');

model.study('std3').feature('stat').set('useparam', 'on');
model.study('std3').feature('stat').set('pname', {'epsilon'});
model.study('std3').feature('stat').set('plist', 'range(epsilonp,(epsilon0-epsilonp)/(nsteps-1),epsilon0)');

model.sol('sol1').feature('st1').name('Compile Equations: Stationary');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').feature('v1').feature('mod1_solid_pw').set('scalemethod', 'manual');
model.sol('sol1').feature('v1').feature('mod1_solid_pw').set('scaleval', '0.1');
model.sol('sol1').feature('s1').set('control', 'stat');
model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');
model.sol('sol1').feature('s1').feature('aDef').set('convinfo', 'detailed');
model.sol('sol1').feature('s1').feature('p1').set('control', 'stat');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'epsilon'});
model.sol('sol1').feature('s1').feature('p1').set('plist', 'range(epsilonp,(epsilon0-epsilonp)/(nsteps-1),epsilon0)');


%model.sol('sol1').runAll;

model.result('pg1').name('Stress (solid)');
model.result('pg1').set('title', 'epsilon(25)=0 Surface: von Mises stress (MPa)   Surface Deformation: Displacement field (Material) ');
model.result('pg1').set('titleactive', false);
model.result('pg1').feature('surf1').set('expr', 'solid.mises');
model.result('pg1').feature('surf1').set('unit', 'MPa');
model.result('pg1').feature('surf1').set('descr', 'von Mises stress');
model.result('pg1').feature('surf1').feature('def').set('scale', '5');
model.result('pg1').feature('surf1').feature('def').set('scaleactive', true);

out = model;
