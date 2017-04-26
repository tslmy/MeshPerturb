function out = nonlinear_analysis_seed3d(modifiedMesh, weight)
%
% nonlinear_analysis_seed.m
%
% Model exported on Oct 4 2013, 20:26 by COMSOL 4.2.0.228.

import com.comsol.model.*
import com.comsol.model.util.*
ModelUtil.showProgress(true);

model = ModelUtil.create('Model NL');

model.modelPath('.\1D parametric');

model.name('nonlinear_analysis_seed.mph');

model.param.set('L', '10 [um]', 'Length of plate');
model.param.set('W', 'L/2 [um]', 'Multiplier for Width of plate: W=Wm*L');
model.param.set('hf', '25.4e-3 [um]', 'Height of plate');
model.param.set('H', '3 [um]', 'Height of foundation');
model.param.set('epsilonp', '0', 'Initial prestretch');
model.param.set('epsilon', '0', 'Current compression');
model.param.set('epsilon0', '-0.75e-2', 'Final compression');
model.param.set('Et', '70e9 [Pa]', 'Modulus of top layer');
model.param.set('Mub', '0.9e6 [Pa]', 'Modulus of bottom layer');
model.param.set('nsteps', '25', 'Number of eigen values');
model.param.set('weight',weight, 'Weight factor');

model.modelNode.create('mod1');

model.geom.create('geom1', 3);
model.geom('geom1').lengthUnit([native2unicode(hex2dec('00b5'), 'Cp1252') 'm']);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('imp1', 'Import');
model.mesh('mesh1').name('Plate top swept');
model.mesh('mesh1').feature('imp1').set('source', 'native');
model.mesh('mesh1').feature('imp1').set('filename',modifiedMesh);
model.mesh('mesh1').run;

model.selection.create('solid_dst_pc1', 'Explicit');
model.selection.create('solid_dst_pc2', 'Explicit');

model.material.create('mat1');
model.material('mat1').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat1').propertyGroup.create('RefractiveIndex', 'Refractive index');
model.material('mat1').selection.set([2]);
model.material.create('mat3');
model.material('mat3').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat3').propertyGroup.create('NeoHookean', 'Neo-Hookean');
model.material('mat3').selection.set([1]);

model.physics.create('solid', 'SolidMechanics', 'geom1');
model.physics('solid').feature('lemm1').feature.create('iss1', 'InitialStressandStrain', 3);
model.physics('solid').feature.create('hmm1', 'HyperelasticModel', 3);
model.physics('solid').feature('hmm1').selection.set([1]);
model.physics('solid').feature.create('sym1', 'SymmetrySolid', 2);
model.physics('solid').feature('sym1').selection.set([1 4]);
model.physics('solid').feature.create('disp2', 'Displacement2', 2);
model.physics('solid').feature.create('disp1', 'Displacement2', 2);
model.physics('solid').feature('disp1').selection.set([10 11]);
model.physics('solid').feature.create('roll1', 'Roller', 2);
model.physics('solid').feature('roll1').selection.set([3]);
model.physics('solid').feature.create('disp3', 'Displacement2', 2);
model.physics('solid').feature.create('pc1', 'PeriodicCondition', 2);
model.physics('solid').feature.create('bndl1', 'BoundaryLoad', 2);
model.physics('solid').feature.create('pc2', 'PeriodicCondition', 2);
model.physics('solid').feature('pc2').selection.set([1 4 10 11]);
model.physics('solid').feature.create('sym2', 'SymmetrySolid', 2);
model.physics('solid').feature('sym2').selection.set([2 5]);

model.result.table.create('evl3', 'Table');

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
model.material('mat3').name('PDMS');
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
model.material('mat3').propertyGroup('NeoHookean').set('lambda', '2e9');

model.physics('solid').feature('lemm1').set('AdvMatRes', '1');
model.physics('solid').feature('lemm1').feature('iss1').selection.active(false);
model.physics('solid').feature('lemm1').feature('iss1').set('eil', {'epsilonp'; '0'; '0'; '0'; '0'; '0'; '0'; '0'; '-mat1.Enu.nu*epsilonp'});
model.physics('solid').feature('lemm1').feature('iss1').active(false);
model.physics('solid').feature('hmm1').set('kappa', '3e9');
model.physics('solid').feature('hmm1').set('NearlyIncompressible', '1');
model.physics('solid').feature('hmm1').set('minput_velocity_src', 'root.mod1.solid.u_tX');
model.physics('solid').feature('sym1').name('Symmetry along x');
model.physics('solid').feature('disp2').selection.active(false);
model.physics('solid').feature('disp2').set('Direction', {'1'; '0'; '0'});
model.physics('solid').feature('disp2').active(false);
model.physics('solid').feature('disp2').name('Zero x displacement');
model.physics('solid').feature('disp1').set('U0', {'epsilon*L'; '0'; '0'});
model.physics('solid').feature('disp1').set('Direction', {'1'; '0'; '0'});
model.physics('solid').feature('disp1').name('Applied compression');
model.physics('solid').feature('roll1').name('Roller z base');
model.physics('solid').feature('disp3').selection.active(false);
model.physics('solid').feature('disp3').set('Direction', {'0'; '1'; '0'});
model.physics('solid').feature('disp3').active(false);
model.physics('solid').feature('disp3').name('Zero y displacement');
model.physics('solid').feature('pc1').selection.active(false);
model.physics('solid').feature('pc1').set('PeriodicInDirection', {'0'; '0'; '1'});
model.physics('solid').feature('pc1').active(false);
model.physics('solid').feature('pc1').name('Periodic Condition on y faces');
model.physics('solid').feature('bndl1').selection.active(false);
model.physics('solid').feature('bndl1').set('LoadType', 'FollowerPressure');
model.physics('solid').feature('bndl1').set('FollowerPressure', '-mat3.Enu.nu*epsilonp*0.9*mat3.Enu.E');
model.physics('solid').feature('bndl1').active(false);
model.physics('solid').feature('pc2').set('PeriodicInDirection', {'0'; '0'; '1'});
model.physics('solid').feature('pc2').name('Periodic Condition on x faces');
model.physics('solid').feature('sym2').name('Symmetry along y');

%model.mesh('mesh1').run;

model.result.table('evl3').name('Evaluation 3D');
model.result.table('evl3').comments('Interactive 3D values');

model.study.create('std1');
model.study('std1').feature.create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('p1', 'Parametric');
model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.create('se1', 'Segregated');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.study('std1').feature('stat').set('useparam', 'on');
model.study('std1').feature('stat').set('pname', {'epsilon'});
model.study('std1').feature('stat').set('plist', 'range(epsilonp,(epsilon0-epsilonp)/(nsteps-1),epsilon0)');

model.sol('sol1').feature('st1').name('Compile Equations: Stationary {stat}');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').feature('s1').set('control', 'stat');
model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');
model.sol('sol1').feature('s1').feature('p1').set('control', 'stat');
model.sol('sol1').feature('s1').feature('p1').set('pname', {'epsilon'});
model.sol('sol1').feature('s1').feature('p1').set('plist', 'range(epsilonp,(epsilon0-epsilonp)/(nsteps-1),epsilon0)');
model.sol('sol1').feature('s1').feature('se1').feature('ssDef').set('subdtech', 'auto');

out = model;
