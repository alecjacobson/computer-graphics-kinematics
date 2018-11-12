#include "Bone.h"
#include "Skeleton.h"
#include "kinematics_jacobian.h"
#include "projected_gradient_descent.h"
#include "transformed_tips.h"
#include "euler_angles_to_quaternion.h"
#include "read_model_and_rig_from_json.h"
#include "skeleton_visualization_mesh.h"
#include "linear_blend_skinning.h"
#include "catmull_rom_interpolation.h"
#include <vector>
#include <Eigen/StdVector>
#include <igl/opengl/glfw/Viewer.h>
#include <igl/unproject.h>
#include <igl/get_seconds.h>
#include <igl/parula.h>
#include <igl/randperm.h>
#include <igl/pinv.h>
#include <igl/matlab_format.h>


int main(int argc, char * argv[])
{
  igl::opengl::glfw::Viewer v;
  Eigen::MatrixXd V,U,W;
  Eigen::MatrixXi F;
  Skeleton skeleton;
  Eigen::VectorXi b;
  // which constraint in b is attached to the mouse
  int mouse_bi = 0;

  std::vector<std::vector<std::pair<double, Eigen::Vector3d> > > fk_anim;
  // read mesh, skeleton and weights
  read_model_and_rig_from_json(
    argc>1?argv[1]:"../shared/data/knight-rig.json",
    V,F,skeleton,W,
    fk_anim,b);
  if(b.size() == 0)
  {
    b.setConstant(1,1,skeleton.size()-1);
  }

  // endpoint positions in a single column
  Eigen::VectorXd xb0 = transformed_tips(skeleton,b);

  assert(fk_anim.size() == skeleton.size());
  // U will track the deforming mesh
  U = V;
  const int model_id    = 1;
  const int skeleton_id = 0;
  v.append_mesh();
  v.data_list[model_id].set_mesh(U,F);
  v.data_list[model_id].show_faces = false;
  v.data_list[model_id].set_face_based(true);
  // Color the model based on linear blend skinning weights
  {
    Eigen::MatrixXd CM;
    Eigen::VectorXi I;
    igl::randperm(W.cols(),I);
    igl::parula(I.cast<double>().eval(),true,CM);
    Eigen::MatrixXd VC = W*CM;
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
  v.core.background_color = Eigen::Vector4f(0.8,0.8,0.8,1.0);

  double anim_last_t = igl::get_seconds();
  double anim_t = 0;
  // Update the skeleton mesh and the linear blend skinning model based on
  // current skeleton deformation
  const auto update = [&]()
  {
    skeleton_visualization_mesh(skeleton,thickness,SV,SF,SC);
    v.data_list[skeleton_id].clear();
    v.data_list[skeleton_id].set_mesh(SV,SF);
    v.data_list[skeleton_id].set_colors(SC);

    std::vector<Eigen::Affine3d,Eigen::aligned_allocator<Eigen::Affine3d> > T;
    forward_kinematics(skeleton,T);
    linear_blend_skinning(V,skeleton,T,W,U);
    v.data_list[model_id].set_vertices(U);
    v.data_list[model_id].compute_normals();
  };

  int mouse_x, mouse_y;
  bool use_ik = true;
  bool mouse_moved = false;
  const auto ik = [&]()
  {
    if(!mouse_moved) { return; }
    const auto view = v.core.view;
    const auto proj = v.core.proj;
    const auto viewport = v.core.viewport;
    Eigen::Vector3d mouse = igl::unproject(
      Eigen::Vector3f(mouse_x,viewport[3]-mouse_y,0.),
      view,proj,viewport).cast<double>();
    Eigen::Vector3d eye = view.inverse().block(0,3,3,1).cast<double>();
    Eigen::Vector3d d = (mouse-eye).normalized();
    Eigen::Matrix3d P = Eigen::Matrix3d::Identity() - d*d.transpose();
    v.data().set_edges(
      (Eigen::MatrixXd(2,3)<<
       eye.transpose(),
       (eye+(mouse-eye)*100.).transpose()
       ).finished(),
      (Eigen::MatrixXi(1,2)<<0,1).finished(),
      (Eigen::MatrixXd(1,3)<<1,0,0).finished());
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
    const auto skeleton_at = [&](const Eigen::VectorXd & A)->Skeleton
    {
      Skeleton copy = skeleton;
      for(int si = 0;si<skeleton.size();si++)
      {
        copy[si].xzx = A.block(si*3,0,3,1);
      }
      return copy;
    };
    const auto f = [&](const Eigen::VectorXd & A)->double
    {
      Skeleton copy = skeleton_at(A);
      Eigen::VectorXd xb = transformed_tips(copy,b);
      // grab tip at mouse
      Eigen::Vector3d xbm = xb.block(3*mouse_bi,0,3,1);
      // zero out part of first term cooresponding to tip controlled by mouse
      xb.block(3*mouse_bi,0,3,1).setConstant(0);
      xb0.block(3*mouse_bi,0,3,1).setConstant(0);
      return 0.5*((xb-xb0).squaredNorm() + (P*(xbm - eye)).squaredNorm());
    };
    const auto grad_f = [&](const Eigen::VectorXd & A)->Eigen::VectorXd
    {
      Skeleton copy = skeleton_at(A);
      Eigen::VectorXd xb = transformed_tips(copy,b);
      // grab tip at mouse
      Eigen::Vector3d xbm = xb.block(3*mouse_bi,0,3,1);
      Eigen::VectorXd dEdx = xb-xb0;
      // Overwrite energy gradient of endpoint attached to mouse
      dEdx.block(mouse_bi*3,0,3,1) = P.transpose()*(P*(xbm - eye));
      // We want to build dx/dθ where θ are _all_ of the joint angles.
      Eigen::MatrixXd J;
      kinematics_jacobian(b,copy,J);
      return J.transpose() * dEdx;
    };
    const auto proj_z = [&](Eigen::VectorXd & A)
    {
      assert(skeleton.size()*3 == A.size());
      for(int si = 0;si<skeleton.size();si++)
      {
        const auto bone = skeleton[si];
        for(int a = 0;a<3;a++)
        {
          A(si*3+a) = 
            std::min(std::max(A(si*3+a),bone.xzx_min(a)),bone.xzx_max(a));
        }
      }
    };
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
    //if(v.core.is_animating)
    if(use_ik && !v.down)
    {
      ik();
      update();
    }else
    // Forward Kinematice animation
    {
      const double now = igl::get_seconds();
      anim_t += now - anim_last_t;
      anim_last_t = now;
      // Robot-arm
      for(int b = 0;b<skeleton.size();b++)
      {
        skeleton[b].xzx = catmull_rom_interpolation( fk_anim[b],anim_t);
      }
      update();
    }
    return false;
  };
  v.core.animation_max_fps = 30.;

  v.callback_mouse_move = [&](
    igl::opengl::glfw::Viewer & v,
    int _mouse_x,
    int _mouse_y)
  {
    mouse_moved = true;
    mouse_x = _mouse_x;
    mouse_y = _mouse_y;
    if(v.down)
    {
      return false;
    }
    return false;
  } ;

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
      case 'r':
        for(auto & bone : skeleton)
        { bone.xzx.setConstant(0); }
        anim_last_t = igl::get_seconds();
        anim_t = 0;
        update();
        break;
      case ',':
      case '.':
      {
        mouse_bi = (mouse_bi+b.size()+(key==','?-1:+1)) % b.size();
        break;
      }
      case 'I':
      case 'i':
        use_ik = !use_ik;
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
    
    // Save current endpoint states as new targets
    xb0 = transformed_tips(skeleton,b);

    return true;
  };
  std::cout<< R"(
[space]  toggle animation
)";

  v.core.is_animating = true;
  v.launch();
}
