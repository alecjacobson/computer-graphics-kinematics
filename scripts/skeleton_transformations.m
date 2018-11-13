function [T,D,U,l] = skeleton_transformations(V,WI,P,A)
  T = zeros(4,4,size(V,1));
  D = zeros(4,4,size(V,1));
  U = zeros(size(V,1),3);
  l = zeros(size(V,1),1);
  Q = 1:size(V,1);
  seen = false(size(V,1),1);
  while ~isempty(Q)
    b = Q(1);
    % bad matlab
    Q(1) = [];
    if seen(b)
      continue;
    end
    p = P(b);
    if p>0 && ~seen(p)
      % put the parent in front of the child
      Q = [p b Q];
    end
    if p == 0
      T(:,:,b) = eye(4);
      T(1:3,4,b) = V(b,:)';
      l(b) = 0;
    elseif seen(p)
      x = T(1:3,1,p);
      len = normrow(V(b,:));
      [w,a] = axisanglebetween(x',V(b,:));
      R = axisangle2matrix(w,a);
      W = axisangle2matrix([1 0 0],A(b)/180*pi);
      T(1:3,1:3,b) = R*T(1:3,1:3,p)*W;
      % Tail is parent's tip
      T(1:3,4,b) = T(1:3,:,p) * [l(p);0;0;1];
      l(b) = len;
      T(4,:,b) = [0 0 0 1];
      % Tb = Db Tp
      % Tb Tp⁻¹ = Db
      D(:,:,b) = T(:,:,b) * inv( T(:,:,p) );
    end
    U(b,:) = T(1:3,:,b) * [l(b);0;0;1];
    seen(b) = true;
    
  end
  UT = permute(T(1:3,4,:),[3 1 2]);

end
