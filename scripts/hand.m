
dirpath = '../shared/data/';
[V,WI,P] = readBF([dirpath 'chimpanzee-hand-model.bf']);
model_file = 'chimpanzee-hand-model.obj';
[VV,FF] = load_mesh([dirpath model_file]);
weights_file = 'chimpanzee-hand-model-weights.dmat';

A = zeros(size(V,1),1);
xzx_min = zeros(size(V,1),3);
xzx_max = zeros(size(V,1),3);
% thumb
A([6 10 14 18]) = 0;
A([6 10 14 18]+1) = 90;
A(11) = 85;
A(7) = 85;
A(14) = -10;

xzx_min(4,:) = [-20 -5 -20];
xzx_max(4,:) = [ 20 60  20];
xzx_min(5,2) = -5;
xzx_max(5,2) = 70;
xzx_min([6 10 14 18]) = -5;
xzx_max([6 10 14 18]) =  5;

xzx_min([7:9 11:13 15:17 19:21],2) = -10;
xzx_max([7:9 11:13 15:17 19:21],2) = 70;

[T,D,U,l] = skeleton_transformations(V,WI,P,A);

[BVV,BFF,BCC] = rest_skeleton_mesh( ...
 T,l,norm(max(VV)-min(VV))*0.01);
tsh = tsurf(BFF,BVV,'FaceVertexCData',BCC);
%tsh.FaceColor = 'none';
axis equal;
text(U(:,1),U(:,2),U(:,3),num2str((1:size(U,1))'));
view(2);
ik_constraints = [5 9 13 17 21];

json_file = [dirpath 'chimpanzee-hand-model.json'];
fk_animation = ...
[
  struct('bone_id',3,'keys',keys([0 0 0 0;1 10 60 0;2 10 58 0;3 10 60 0;4 10 58 0;5 10 60 0;6 0 0 0])),
  struct('bone_id',4,'keys',keys([0 0 0 0;1  0 20 0;2  0 19 0;3  0 20 0;4  0 19 0;5  0 20 0;6 0 0 0]))
  struct('bone_id',6,'keys',keys([0 0 0 0;1 0 60 0;2 0 -5 0;3 0 -2 0;4 0 -5 0;6 0 0 0 ])),
  struct('bone_id',7,'keys',keys([0 0 0 0;1 0 80 0;2 0 -5 0;3 0 -2 0;4 0 -5 0;6 0 0 0])),
  struct('bone_id',8,'keys',keys([0 0 0 0;1 0 80 0;2 0 -5 0;3 0 -2 0;4 0 -5 0;6 0 0 0])),
  struct('bone_id',10,'keys',keys([0 0 0 0;1 0 60 0;2 0 60 0;3 0 -5 0;4 0 -2 0;5 0 -5 0;6 0 0 0 ])),
  struct('bone_id',11,'keys',keys([0 0 0 0;1 0 80 0;2 0 80 0;3 0 -5 0;4 0 -2 0;5 0 -5 0;6 0 0 0])),
  struct('bone_id',12,'keys',keys([0 0 0 0;1 0 80 0;2 0 80 0;3 0 -5 0;4 0 -2 0;5 0 -5 0;6 0 0 0])),
  struct('bone_id',14,'keys',keys([0 0 0 0;1 0 60 0;3 0 60 0;4 0 -5 0;5 0 -2 0;6 0 0 0 ])),
  struct('bone_id',15,'keys',keys([0 0 0 0;1 0 80 0;3 0 80 0;4 0 -5 0;5 0 -2 0;6 0 0 0])),
  struct('bone_id',16,'keys',keys([0 0 0 0;1 0 80 0;3 0 80 0;4 0 -5 0;5 0 -2 0;6 0 0 0])),
  struct('bone_id',18,'keys',keys([0 0 0 0;1 0 60 0;4 0 60 0;5 0 -5 0;6 0 0 0 ])),
  struct('bone_id',19,'keys',keys([0 0 0 0;1 0 80 0;4 0 80 0;5 0 -5 0;6 0 0 0])),
  struct('bone_id',20,'keys',keys([0 0 0 0;1 0 80 0;4 0 80 0;5 0 -5 0;6 0 0 0])),
];

json = jsonencode( ...
  struct( ...
    'model',struct('file',model_file), ...
    'weights',struct('file',weights_file), ...
    'fk_animation',fk_animation, ...
    'ik_constraints',ik_constraints-1, ...
    'bones', arrayfun(@(b) struct( ...
      'parent_id',P(b)-1, ...
      'weight_id',WI(b)-1, ...
      'length',l(b), ...
      'xzx_min',xzx_min(b,:), ...
      'xzx_max',xzx_max(b,:), ...
      'rest_T',T(:,:,b)),1:size(P,1))));
fid = fopen(json_file,'w');
fprintf(fid,'%s',json);
fclose(fid);
system(['../build-release/kinematics "' json_file '"']);
