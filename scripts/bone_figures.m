[V,F,C] = canonical_bone();
ell = 10;
V(:,1) = V(:,1)*ell;
E = sharp_edges(V,F);
AV =[-1 0 0;ell+1 0 0;0 -2 0; 0 2 0;0 0 -2; 0 0 2];
TV = [-1.8 0 0;ell+1.1 0 0;0.2 -2 0;-0.8 2.4 0;0 0 -2.3; 0 0 2.3];

%im = uint8([]);
%for pass = 1
%R = axisangle2matrix([1 0 0],-pi/2) * diag([1 -1 1]);
%switch pass
%case 1 
%  offon = 'on';
%case 2
%  offon = 'off';
%end
%clf;
%hold on;
%tsh = tsurf(F,V*R,'FaceVertexCData',C,'EdgeColor','none','Visible',offon);
%plot_edges(V*R,E,'k');
%%plot_edges( ...
%%  AV,[1 2;3 4;5 6], ...
%%  ':k','LineWidth',3);
%%txt = text(TV(:,1),TV(:,2),TV(:,3),['-x';'+x';'+z';'-z';'-y';'+y'], ...
%%  'FontSize',50,'FontName','Times','FontAngle','italic');
%if pass == 2
%tsurf([1 1 4;2 2 5;3 3 6],[eye(3);zeros(3,3)]*R,'LineWidth',3,'FaceVertexCData',[eye(3);eye(3)],'EdgeColor','interp');
%end
%text(5, 2.5,-1,'x','FontSize', 70,'FontName','Times','FontAngle','italic');
%text(-1, 0,-1.2,'z','FontSize',70,'FontName','Times','FontAngle','italic');
%text(-1, 0,0.9,'y','FontSize', 70,'FontName','Times','FontAngle','italic');
%set(gca,'YDir','reverse')
%set(gcf,'color','w')
%hold off;
%axis equal
%axis([0 ell -1 1 -1 1])
%view(-18,22);
%camproj('persp');
%set(gca,'FontSize',30)
%set(gcf,'Position',[846         807        1386         536])
%t = title('Bone of length $\ell = 10$','interpreter','latex','FontSize',60)
%drawnow;
%figpng('../images/canonical-bone.png');
%%frame = getframe(gcf);
%%im(:,:,:,pass) = frame.cdata;
%end


delete('../images/canonical-bending.gif');
ease = @(t) 3.*t.^2-2.*t.^3;
for th = -pi/2*ease([linspace(0,1,30) linspace(1,0,30)]);
R = axisangle2matrix([1 0 0],-pi/2) * diag([1 -1 1]);
U = V*axisangle2matrix([0 0 1],th);
clf;
hold on;
tsh = tsurf(F,U*R,'FaceVertexCData',C,'EdgeColor','none','Visible',offon);
plot_edges(U*R,E,'k');
%plot_edges( ...
%  AV,[1 2;3 4;5 6], ...
%  ':k','LineWidth',3);
%txt = text(TV(:,1),TV(:,2),TV(:,3),['-x';'+x';'+z';'-z';'-y';'+y'], ...
%  'FontSize',50,'FontName','Times','FontAngle','italic');
text(5, 2.5,-1,'x','FontSize', 70,'FontName','Times','FontAngle','italic');
text(-2.5, 0,-1.2,'z','FontSize',70,'FontName','Times','FontAngle','italic');
text(-2.5, 0,5.9,'y','FontSize', 70,'FontName','Times','FontAngle','italic');
set(gca,'YDir','reverse')
set(gcf,'color','w')
hold off;
axis equal
axis([-1 ell -1 1 -1 ell])
view(-18,22);
camproj('persp');
set(gca,'FontSize',30)
set(gcf,'Position',[846         807        1386         1386])
t = title(sprintf('Bending around $z$ axis: $\\theta_2 = %4d^\\circ$',round(-th*180/pi)),'interpreter','latex','FontSize',60);
drawnow;
figgif('../images/canonical-bending.gif');
end

delete('../images/canonical-twisting.gif');
ease = @(t) 3.*t.^2-2.*t.^3;
for th = -2*pi*ease(linspace(0,1,60))
R = axisangle2matrix([1 0 0],-pi/2) * diag([1 -1 1]);
U = V*axisangle2matrix([1 0 0],th);
clf;
hold on;
tsh = tsurf(F,U*R,'FaceVertexCData',C,'EdgeColor','none','Visible',offon);
plot_edges(U*R,E,'k');
%plot_edges( ...
%  AV,[1 2;3 4;5 6], ...
%  ':k','LineWidth',3);
%txt = text(TV(:,1),TV(:,2),TV(:,3),['-x';'+x';'+z';'-z';'-y';'+y'], ...
%  'FontSize',50,'FontName','Times','FontAngle','italic');
text(5, 3,-1.5,'x','FontSize', 70,'FontName','Times','FontAngle','italic');
text(-1.2,0,-2,'z','FontSize',70,'FontName','Times','FontAngle','italic');
text(-sqrt(2), 0,0.9,'y','FontSize', 70,'FontName','Times','FontAngle','italic');
set(gca,'YDir','reverse')
set(gcf,'color','w')
hold off;
axis equal
axis([0 ell [-1 1 -1 1]*sqrt(2)])
view(-18,22);
camproj('persp');
set(gca,'FontSize',30)
set(gcf,'Position',[846         807        1386         536])
t = title(sprintf('Twisting around $x$ axis: $\\theta_1 = %4d^\\circ$',round(-th*180/pi)),'interpreter','latex','FontSize',60);
drawnow;
figgif('../images/canonical-twisting.gif');
end

delete('../images/canonical-rotating.gif');
ease = @(t) 3.*t.^2-2.*t.^3;
for t = [ease([linspace(0,1,30) ones(1,60) linspace(1,0,30)]); ...
         ease([zeros(1,30) linspace(0,1,30) ones(1,30) linspace(1,0,30)]); ...
         ease([zeros(1,60) linspace(0,1,30) linspace(1,0,30)])]
th = [-2*pi/3;-pi/3;-pi/4].*t;
R = axisangle2matrix([1 0 0],-pi/2) * diag([1 -1 1]);
U = V * ( ...
  axisangle2matrix([1 0 0],th(1)) * ...
  axisangle2matrix([0 0 1],th(2)) * ...
  axisangle2matrix([1 0 0],th(3)) );
clf;
hold on;
tsh = tsurf(F,U*R,'FaceVertexCData',C,'EdgeColor','none','Visible',offon);
plot_edges(U*R,E,'k');
%plot_edges( ...
%  AV,[1 2;3 4;5 6], ...
%  ':k','LineWidth',3);
%txt = text(TV(:,1),TV(:,2),TV(:,3),['-x';'+x';'+z';'-z';'-y';'+y'], ...
%  'FontSize',50,'FontName','Times','FontAngle','italic');
text(4.5, 13,-1,'x','FontSize', 70,'FontName','Times','FontAngle','italic');
text(-3, 6,-1.2,'z','FontSize',70,'FontName','Times','FontAngle','italic');
text(-3.5, 0,6.4,'y','FontSize', 70,'FontName','Times','FontAngle','italic');
set(gca,'YDir','reverse')
set(gcf,'color','w')
hold off;
axis equal
axis([-sqrt(2) ell -sqrt(2) ell -sqrt(2) ell])
view(-18,22);
camproj('persp');
set(gca,'FontSize',30)
set(gcf,'Position',[846         807        1386         1386])
t = title( ...
  sprintf(['Twist-bend-twist: $(\\theta_1,\\theta_2,\\theta_3) = ' ...
    '(%4d^\\circ,%4d^\\circ,%4d^\\circ)$'], ... 
    round(-th'*180/pi)),'interpreter','latex','FontSize',60);
drawnow;
figgif('../images/canonical-rotating.gif');
end
