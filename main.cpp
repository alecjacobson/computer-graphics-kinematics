#include "Bone.h"
#include "Skeleton.h"
#include "end_effectors_objective_and_gradient.h"
#include "projected_gradient_descent.h"
#include "transformed_tips.h"
#include "read_model_and_rig_from_json.h"
#include "skeleton_visualization_mesh.h"
#include "linear_blend_skinning.h"
#include "catmull_rom_interpolation.h"
#include <vector>
#include <igl/opengl/glfw/Viewer.h>
#include <igl/unproject.h>
#include <igl/project.h>
#include <igl/get_seconds.h>
#include <igl/parula.h>
#include <igl/randperm.h>
#include <igl/pinv.h>
#include <igl/LinSpaced.h>
#include <igl/matlab_format.h>


int main(int argc, char * argv[])
{
  typedef 
    Eigen::Map<
      Eigen::Matrix<double,Eigen::Dynamic,Eigen::Dynamic,Eigen::RowMajor> > 
    MapRXd;
  igl::opengl::glfw::Viewer v;
  Eigen::MatrixXd V,U,W;
  Eigen::MatrixXi F;
  Skeleton skeleton;
  // Index of selected end-effector
  int sel = -1;

  // list of indices into skeleton of bones whose tips are constrained during IK
  Eigen::VectorXi b;
  std::vector<std::vector<std::pair<double, Eigen::Vector3d> > > fk_anim;

  // read mesh, skeleton and weights
  read_model_and_rig_from_json(
    argc>1?argv[1]:"../data/robot-arm.json",
    V,F,skeleton,W,
    fk_anim,b);
  // If not provided use last bone;
  if(b.size() == 0) { b.setConstant(1,1,skeleton.size()-1); }

  // endpoint positions in a single column
  Eigen::VectorXd xb0 = transformed_tips(skeleton,b);

  // U will track the deforming mesh
  U = V;
  const int model_id    = 0;
  // skeleton after so dots can be on top
  const int skeleton_id = 1;
  v.append_mesh();
  v.selected_data_index = 0;
  v.data_list[model_id].set_mesh(U,F);
  v.data_list[model_id].show_faces = false;
  v.data_list[model_id].set_face_based(true);
  // Color the model based on linear blend skinning weights
  {
    Eigen::MatrixXd CM = 
      (Eigen::MatrixXd(8,3)<<
        228,26,28,
        55,126,184,
        77,175,74,
        152,78,163,
        255,127,0,
        255,255,51,
        166,86,40,
        247,129,191
      ).finished()/255.0;
    Eigen::MatrixXd VC =
      W*CM.replicate((W.cols()+CM.rows()-1)/CM.rows(),1).topRows(W.cols());
    Eigen::MatrixXd FC = Eigen::MatrixXd::Zero(F.rows(),VC.cols());
    for (int i = 0; i <F.rows(); ++i)
      for (int j = 0; j<F.cols(); ++j)
        FC.row(i) += VC.row(F(i,j));
    FC.array() /= F.cols();
    v.data_list[model_id].set_colors(FC);
  }
  // Create a mesh to visualize the skeleton
  Eigen::MatrixXd SV,SC;
  Eigen::MatrixXi SF;
  const double thickness = 
    0.01*(V.colwise().maxCoeff() - V.colwise().minCoeff()).norm();
  skeleton_visualization_mesh(skeleton,thickness,SV,SF,SC);
  v.data_list[skeleton_id].set_mesh(SV,SF);
  v.data_list[skeleton_id].set_colors(SC);
  v.data_list[skeleton_id].set_face_based(true);
  v.core.animation_max_fps = 30.;
  v.core.is_animating = true;

  double anim_last_t = igl::get_seconds();
  double anim_t = 0;
  // Update the skeleton mesh and the linear blend skinning model based on
  // current skeleton deformation
  const auto update = [&]()
  {
    skeleton_visualization_mesh(skeleton,thickness,SV,SF,SC);
    v.data_list[skeleton_id].set_mesh(SV,SF);
    v.data_list[skeleton_id].compute_normals();
    v.data_list[skeleton_id].set_colors(SC);
    // Draw teal dots with lines attached to end-effectors and constraints (pink
    // if selected)
    const Eigen::RowVector3d teal(0.56471,0.84706,0.76863);
    const Eigen::RowVector3d pink(0.99608,0.76078,0.76078);
    {
      Eigen::MatrixXd C = teal.replicate(xb0.size()/3,1);
      if(sel != -1) { C.row(sel) = pink; }
      v.data_list[skeleton_id].set_points(MapRXd(xb0.data(),xb0.size()/3,3),C);
      Eigen::MatrixXd P(xb0.size()/3*2,3);
      Eigen::VectorXd xb = transformed_tips(skeleton,b);
      P <<
        MapRXd(xb0.data(),xb0.size()/3,3),
        MapRXd(xb.data(),xb.size()/3,3);
      Eigen::MatrixXi E(xb.size()/3,2);
      for(int e = 0;e<E.rows();e++) { E(e,0) = e; E(e,1) = e+E.rows(); }
      v.data_list[skeleton_id].set_edges(P,E,C);
      v.data_list[skeleton_id].show_overlay_depth = false;
    }
    // Compute transformations of skeleton bones
    std::vector<Eigen::Affine3d,Eigen::aligned_allocator<Eigen::Affine3d> > T;
    forward_kinematics(skeleton,T);
    // Apply bone transformations to deform shape
    linear_blend_skinning(V,skeleton,T,W,U);
    v.data_list[model_id].set_vertices(U);
    v.data_list[model_id].compute_normals();
  };

  int mouse_x, mouse_y;
  double mouse_z;
  bool use_ik = true;
  const auto ik = [&]()
  {
    // If in debug mode use 1 ik iteration per drawn frame, otherwise 100
    const int max_iters =
#if NDEBUG
      100;
#else
      1;
#endif
    // Gather initial angles
    Eigen::VectorXd A(skeleton.size()*3);
    for(int si = 0;si<skeleton.size();si++)
    {
      A.block(si*3,0,3,1) = skeleton[si].xzx;
    }
    std::function<double(const Eigen::VectorXd &)> f;
    std::function<Eigen::VectorXd(const Eigen::VectorXd &)> grad_f;
    std::function<void(Eigen::VectorXd &)> proj_z;
    end_effectors_objective_and_gradient(skeleton,b,xb0,f,grad_f,proj_z);
    // Optimize angles
    projected_gradient_descent(f,grad_f,proj_z,max_iters,A);
    // Distribute optimized angles
    for(int si = 0;si<skeleton.size();si++)
    {
      skeleton[si].xzx = A.block(si*3,0,3,1);
    }
  };

  v.callback_pre_draw = [&](igl::opengl::glfw::Viewer &)->bool
  {
    if(use_ik)
    {
      ik();
    }else
    // Forward Kinematice animation
    {
      if(v.core.is_animating)
      {
        const double now = igl::get_seconds();
        anim_t += now - anim_last_t;
        anim_last_t = now;
      }
      // Robot-arm
      for(int b = 0;b<skeleton.size();b++)
      {
        skeleton[b].xzx = catmull_rom_interpolation( fk_anim[b],anim_t);
      }
    }
    update();
    return false;
  };

  // Record mouse information on click
  v.callback_mouse_down = [&](igl::opengl::glfw::Viewer&, int, int)->bool
  {
    Eigen::RowVector3f last_mouse(mouse_x,v.core.viewport(3)-mouse_y,0);
    // Move closest control point
    Eigen::MatrixXf CP;
    igl::project(
      MapRXd(xb0.data(),xb0.size()/3,3),
      v.core.view,
      v.core.proj, v.core.viewport,
      CP);
    Eigen::VectorXf D = (CP.rowwise()-last_mouse).rowwise().norm();
    sel = (D.minCoeff(&sel) < 30)?sel:-1;
    if(sel != -1)
    {
      mouse_z = CP(sel,2);
      return true;
    }
    return false;
  };
  // Unset selection on mouse up
  v.callback_mouse_up = [&](igl::opengl::glfw::Viewer&, int, int)->bool
  {
    sel = -1;
    return false;
  };
  // update selected constraint on mouse drag
  v.callback_mouse_move = [&](
    igl::opengl::glfw::Viewer & v,
    int _mouse_x,
    int _mouse_y)
  {
    // Remember mouse position
    if(sel != -1)
    {
      Eigen::Vector3f drag_scene,last_scene;
      igl::unproject(
        Eigen::Vector3f(_mouse_x,v.core.viewport(3) - _mouse_y,mouse_z),
        v.core.view,
        v.core.proj,
        v.core.viewport,
        drag_scene);
      igl::unproject(
        Eigen::Vector3f(mouse_x,v.core.viewport(3) - mouse_y,mouse_z),
        v.core.view,
        v.core.proj,
        v.core.viewport,
        last_scene);
      xb0.block(sel*3,0,3,1) += (drag_scene-last_scene).cast<double>();
    }
    mouse_x = _mouse_x;
    mouse_y = _mouse_y;
    return sel!=-1;
  };

  v.callback_key_pressed = [&](
    igl::opengl::glfw::Viewer & v,
    unsigned char key,
    int /*modifier*/
    )->bool
  {
    switch(key)
    {
      default:
        return false;
      case 'R':
      case 'r':
        // Reset bone transformations
        for(auto & bone : skeleton) { bone.xzx.setConstant(0); }
        sel = -1;
        xb0 = transformed_tips(skeleton,b);
        anim_last_t = igl::get_seconds();
        anim_t = 0;
        update();
        break;
      case 'I':
      case 'i':
        use_ik = !use_ik;
        v.data_list[skeleton_id].show_overlay = use_ik;
        break;
      case ' ':
        v.core.is_animating = !v.core.is_animating;
        if(v.core.is_animating)
        {
          // Reset clock
          anim_last_t = igl::get_seconds();
        }
        break;
    }
    return true;
  };
  std::cout<< R"(
[space]  toggle animation
I,i      toggle between interactive demo (IK) / animation (pure FK)
R,r      reset bone transformations to rest
)";
  v.launch();
}
