#ifndef SKELETON_VISUALIZATION_MESH_H
#define SKELETON_VISUALIZATION_MESH_H

#include "Skeleton.h"
#include <Eigen/Core>

// Visualize a skeleton as a 3D mesh using long oriented pyramids to represent
// the bones.
//
// Inputs:
//   skeleton  #bones list of bone objects
//   thickness  amount to scale in non-axial directions
// Outputs:
//   SV  #SV by 3 list of mesh vertex positions
//   SF  #SF by 3 list of triangle indices into SV
//   SV  #SF by 3 list of face colors
void skeleton_visualization_mesh(
  const Skeleton & skeleton,
  const double thickness,
  Eigen::MatrixXd & SV,
  Eigen::MatrixXi & SF,
  Eigen::MatrixXd & SC);

// Implementation
#include "forward_kinematics.h"

void skeleton_visualization_mesh(
  const Skeleton & skeleton,
  const double thickness,
  Eigen::MatrixXd & SV,
  Eigen::MatrixXi & SF,
  Eigen::MatrixXd & SC)
{
  std::vector<Eigen::Affine3d,Eigen::aligned_allocator<Eigen::Affine3d> > T;
  forward_kinematics(skeleton,T);
  Eigen::MatrixXd BV(5,3);
  BV << 
     0,-1,-1,
     0, 1,-1,
     0, 1, 1,
     0,-1, 1,
     1, 0, 0;
  BV.rightCols(2) *= thickness;
  Eigen::MatrixXi BF(6,3);
  BF <<
    0,2,1,
    0,3,2,
    0,1,4,
    1,2,4,
    2,3,4,
    3,0,4;
  Eigen::MatrixXd BC(6,3);
  Eigen::RowVector3d red(1,0,0),green(0,1,0),blue(0,0,1);
  BC <<
    1-red.array(),
    1-red.array(),
    1-blue.array(),
    green,
    blue,
    1-green.array();
  int num_bones = 0;
  for(int b = 0;b<skeleton.size();b++)
  { if(skeleton[b].parent_index>=0) { num_bones++; } }
  SV.resize(BV.rows()*num_bones,3);
  SF.resize(BF.rows()*num_bones,3);
  SC.resize(BF.rows()*num_bones,3);
  {
    int k = 0;
    for(int b = 0;b<skeleton.size();b++)
    {
      if(skeleton[b].parent_index<0) continue;
      const Eigen::Affine3d& rTp = skeleton[skeleton[b].parent_index].rest_T;
      const Eigen::Affine3d& rTb = skeleton[b].rest_T;
      const double len = skeleton[b].length;
      Eigen::MatrixXd BVk(BV.rows(),3);
      for(int v = 0;v<BV.rows();v++)
      {
        const Eigen::Vector3d p = 
          T[b] * (rTb * Eigen::Vector3d(len*BV(v,0),BV(v,1),BV(v,2)));
        BVk.row(v) = p.transpose();
      }
      SV.block(k*BV.rows(),0,BV.rows(),3) = BVk;
      SF.block(k*BF.rows(),0,BF.rows(),3) = (BF.array()+k*BV.rows()).matrix();
      SC.block(k*BC.rows(),0,BC.rows(),3) = BC;
      k++;
    }
  }
}

#endif 
