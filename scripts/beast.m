dirpath = '../shared/data/'
[V,WI,P] = readBF([dirpath 'beast_triangles.bf']);
model_file = 'beast_triangles.obj';
[VV,FF] = load_mesh([dirpath model_file]);
weights_file = 'beast_triangles-weights.dmat';

seen = false(size(V,1),1);
A = zeros(size(V,1),1);
A(2) = 35;
A(3) = 15;
A(4) = 100;
A(5) = 90;
A(9) = 90;
A(11) = 100;
A(7) = -10;
A(8) = 100;
A(13) = 30;
A(17) =130;
A(21) = 40;

xzx_min = zeros(size(V,1),3);
xzx_max = zeros(size(V,1),3);
% Elbow
xzx_min(4,2) = -10;
xzx_max(4,2) = 100;
xzx_min(8,2) = -10;
xzx_max(8,2) = 100;
% hand
xzx_min(5,:) = [-0 -30 -0];
xzx_min(9,:) = [-0 -30 -0];
xzx_max(5,:) = [ 0  30  0];
xzx_max(9,:) = [ 0  30  0];

xzx_min(17,2) = -100;
xzx_max(17,2) = 10;
xzx_min(21,2) = -100;
xzx_max(21,2) = 10;
xzx_min(18,2) = -20;
xzx_max(18,2) = 20;
xzx_min(22,2) = -20;
xzx_max(22,2) = 20;

xzx_min( 6,:) = [-2 -5 -2];
xzx_max( 6,:) = [ 2  5  2];
xzx_min( 2,:) = [-2 -5 -2];
xzx_max( 2,:) = [ 2  5  2];

xzx_min(10,:) = [-2 -5 -2];
xzx_max(10,:) = [ 2  5  2];
xzx_min(11,:) = [-10 -20 -10];
xzx_max(11,:) = [ 10  30  10];
xzx_min(12,:) = [-20 -20 -20];
xzx_max(12,:) = [ 20  40  20];

xzx_min(13,:) = [-5 -10 -5];
xzx_max(13,:) = [ 5  10  5];
xzx_min(14,:) = [-5 -10 -5];
xzx_max(14,:) = [ 5  10  5];

% shoulder
xzx_min( 7,:) = [-40 -80 -40];
xzx_max( 7,:) = [ 40  80  40];
xzx_min( 3,:) = [-40 -80 -40];
xzx_max( 3,:) = [ 40  80  40];

xzx_min(16,:) = [-10 -40 -10];
xzx_max(16,:) = [ 10  40  10];
xzx_min(20,:) = [-10 -40 -10];
xzx_max(20,:) = [ 10  40  10];

[T,D,U,l] = skeleton_transformations(V,WI,P,A);

%s = norm(max(VV)-min(VV))/40;
%clf;
%hold on;
%for b = 1:size(V,1)
%  VV = [s*eye(4,3) ones(4,1)]*(T(1:3,1:4,b)');
%  plot_edges(VV,[1 4],'r','LineWidth',1);
%  plot_edges(VV,[2 4],'g','LineWidth',1);
%  plot_edges(VV,[3 4],'b','LineWidth',1);
%end
%hold off;
%axis equal;

[BVV,BFF,BCC] = rest_skeleton_mesh( ...
 T,l,norm(max(VV)-min(VV))*0.01);
tsurf(BFF,BVV,'FaceVertexCData',BCC);
axis equal;
text(U(:,1),U(:,2),U(:,3),num2str((1:size(U,1))'));
view(2);

ik_constraints = [22 18 9 5 12];

json = jsonencode( ...
  struct( ...
    'model',struct('file',model_file), ...
    'weights',struct('file',weights_file), ...
    'fk_animation',[], ...
    'ik_constraints',ik_constraints-1, ...
    'bones', arrayfun(@(b) struct( ...
      'parent_id',P(b)-1, ...
      'weight_id',WI(b)-1, ...
      'length',l(b), ...
      'xzx_min',xzx_min(b,:), ...
      'xzx_max',xzx_max(b,:), ...
      'rest_T',T(:,:,b)),1:size(P,1))));
fid = fopen([dirpath 'beast_triangles-rig.json'],'w');
fprintf(fid,'%s',json);
fclose(fid);

!../build-release/kinematics ~/Dropbox/models/beast/beast_triangles-rig.json
