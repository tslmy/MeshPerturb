function out = linear_analysis_seed()
%
% linear_analysis_seed.m
%
% Model exported on Jun 21 2013, 21:38 by COMSOL 4.2.0.150.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');
%ModelUtil.showProgress(true);

model.modelPath('.\1D parametric study');

model.name('linear_analysis.mph');

model.comments('Linear buckling analysis for pre-stretch of bilayers');

model.param.set('L', '20e-6 [m]', 'Length of stamp');
model.param.set('H', '3e-6 [m]', 'Height of stamp');
model.param.set('W', '1e-3 [m]', 'Thickness of stamp');
model.param.set('hf', '20e-9 [m]', 'Thickness of top film');
model.param.set('epsilonp', '1e-3', 'Initial prestretch strain');
model.param.set('epsilon0', '0', 'Final strain');
model.param.set('epsilon', '0', 'Current strain value (varies from epsilonp to epsilon0)');
model.param.set('Et', '70e9 [Pa]', 'Young''s modulus');
model.param.set('Mub', '2e6 [Pa]', 'Modulus of bottom layer');
model.param.set('nsteps', '25', 'Number of steps for nonlinear study/Not used here');

model.modelNode.create('mod1');

model.geom.create('geom1', 2);
model.geom('geom1').lengthUnit([native2unicode(hex2dec('00b5'), 'Cp1252') 'm']);
model.geom('geom1').feature.create('r1', 'Rectangle');
model.geom('geom1').feature.create('r2', 'Rectangle');
model.geom('geom1').feature('r1').set('pos', {'0' '0'});
model.geom('geom1').feature('r1').set('size', {'L' 'H'});
model.geom('geom1').feature('r2').set('pos', {'0' 'H'});
model.geom('geom1').feature('r2').set('size', {'L' 'hf'});
model.geom('geom1').run;

model.material.create('mat1');
model.material('mat1').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat1').propertyGroup.create('RefractiveIndex', 'Refractive index');
model.material.create('mat3');
model.material('mat3').propertyGroup.create('Enu', 'Young''s modulus and Poisson''s ratio');
model.material('mat3').propertyGroup.create('NeoHookean', 'Neo-Hookean');
model.material('mat3').selection.set([1]);

model.physics.create('solid', 'SolidMechanics', 'geom1');
model.physics('solid').feature('lemm1').feature.create('iss1', 'InitialStressandStrain', 2);
model.physics('solid').feature('lemm1').feature('iss1').selection.set([2]);
model.physics('solid').feature.create('hmm1', 'HyperelasticModel', 2);
model.physics('solid').feature('hmm1').selection.set([1]);
model.physics('solid').feature.create('sym1', 'SymmetrySolid', 1);
model.physics('solid').feature('sym1').selection.set([1 3]);
model.physics('solid').feature.create('roll1', 'Roller', 1);
model.physics('solid').feature('roll1').selection.set([2]);
model.physics('solid').feature.create('disp2', 'Displacement1', 1);
model.physics('solid').feature('disp2').selection.set([6 7]);

model.mesh.create('mesh1', 'geom1');
model.mesh('mesh1').feature.create('ftri1', 'FreeTri');

model.view('view1').axis.set('xmin', '-1.0000009536743164');
model.view('view1').axis.set('xmax', '21');
model.view('view1').axis.set('ymin', '-6.439837455749512');
model.view('view1').axis.set('ymax', '9.514837265014648');

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
model.material('mat3').propertyGroup('NeoHookean').set('lambda', '1.33e6');

model.physics('solid').prop('d').set('d', 'W');
model.physics('solid').feature('lemm1').set('AdvMatRes', '1');
model.physics('solid').feature('lemm1').feature('iss1').set('eil', {'epsilonp'; '0'; '0'; '0'; '-mat1.Enu.nu*epsilonp'; '0'; '0'; '0'; '0'});
model.physics('solid').feature('hmm1').set('minput_velocity_src', 'root.mod1.solid.u_tX');
model.physics('solid').feature('disp2').selection.active(false);
model.physics('solid').feature('disp2').set('U0', {'L*epsilonp*0.9'; '0'; '0'});
model.physics('solid').feature('disp2').set('Direction', {'1'; '0'; '0'});

model.mesh('mesh1').run;

model.study.create('std3');
model.study('std3').feature.create('stat', 'Stationary');
model.study('std3').feature.create('buckling', 'LinearBuckling');

model.sol.create('sol1');
model.sol('sol1').study('std3');
model.sol('sol1').attach('std3');
model.sol('sol1').feature.create('st1', 'StudyStep');
model.sol('sol1').feature.create('v1', 'Variables');
model.sol('sol1').feature.create('s1', 'Stationary');
model.sol('sol1').feature('s1').feature.create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').feature.remove('fcDef');
model.sol('sol1').feature.create('su1', 'StoreSolution');
model.sol('sol1').feature.create('st2', 'StudyStep');
model.sol('sol1').feature.create('v2', 'Variables');
model.sol('sol1').feature.create('e1', 'Eigenvalue');

model.result.dataset.remove('dset3');
model.result.create('pg1', 'PlotGroup2D');
model.result('pg1').feature.create('surf1', 'Surface');
model.result('pg1').feature('surf1').feature.create('def', 'Deform');
model.result.export.create('mesh1', 'Mesh');
model.result.export.create('data1', 'Data');

model.study('std3').feature('buckling').set('neigs', '25');

model.sol('sol1').feature('st1').name('Compile Equations: Stationary {stat}');
model.sol('sol1').feature('st1').set('studystep', 'stat');
model.sol('sol1').feature('v1').set('control', 'stat');
model.sol('sol1').feature('s1').set('control', 'stat');
model.sol('sol1').feature('s1').feature('dDef').set('linsolver', 'pardiso');
model.sol('sol1').feature('su1').name('Store Solution 2');
model.sol('sol1').feature('su1').set('sol', 'sol2');
model.sol('sol1').feature('st2').name('Compile Equations: Linear Buckling {buckling} (2)');
model.sol('sol1').feature('st2').set('studystep', 'buckling');
model.sol('sol1').feature('v2').set('initmethod', 'sol');
model.sol('sol1').feature('v2').set('initsol', 'sol1');
model.sol('sol1').feature('v2').set('notsolmethod', 'sol');
model.sol('sol1').feature('v2').set('notsol', 'sol1');
model.sol('sol1').feature('e1').set('control', 'buckling');
model.sol('sol1').feature('e1').set('neigs', '25');
model.sol('sol1').feature('e1').set('transform', 'critical_load_factor');
model.sol('sol1').feature('e1').set('linpmethod', 'sol');
model.sol('sol1').feature('e1').set('linpsol', 'sol1');
model.sol('sol1').feature('e1').set('linpsoluse', 'sol2');
model.sol('sol1').feature('e1').feature('dDef').set('linsolver', 'pardiso');

%model.sol('sol1').runAll;

%model.result('pg1').name('Mode Shape (solid)');
%model.result('pg1').set('solnum', '3');
%model.result('pg1').set('title', ['Critical load factor=8.978977 Surface: Total displacement (' native2unicode(hex2dec('00b5'), 'Cp1252') 'm)   Surface Deformation: Displacement field (Material) ']);
%model.result('pg1').set('titleactive', false);
%model.result('pg1').feature('surf1').feature('def').set('scale', '4.828020531794557E-7');
%model.result('pg1').feature('surf1').feature('def').set('scaleactive', false);
model.result.export('data1').set('expr', {'u' 'v'});
model.result.export('data1').set('unit', {[native2unicode(hex2dec('00b5'), 'Cp1252') 'm'] [native2unicode(hex2dec('00b5'), 'Cp1252') 'm']});
model.result.export('data1').set('descr', {'Displacement field, X component' 'Displacement field, Y component'});
model.result.export('data1').set('location', 'file');

out = model;
