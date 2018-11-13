#ifndef LINEAR_BLEND_SKINNING_H
#define LINEAR_BLEND_SKINNING_H

#include "Skeleton.h"
#include <Eigen/Core>
#include <Eigen/Geometry>
#include <vector>

// Given a mesh with vertices in their rest positions, a skeleton, bone
// transformations, and per-vertex weights, compute the linear blend skinning
// deformation.
//
// Inputs:
//   V  #V by 3 list of rest pose mesh vertex positions
//   skeleton  #T list of skeleton bones 
//   T  #T list of affine transformations
//   W  #V by #W list of weights (so that W(v,skeleton[i].weight_index) is the
//     weight at vertex v corresponding to transformation T[i]
// Outputs:
//   U  #V by 3 list of deformed mesh vertex positions
void linear_blend_skinning(
  const Eigen::MatrixXd & V,
  const Skeleton & skeleton,
  const std::vector<Eigen::Affine3d,Eigen::aligned_allocator<Eigen::Affine3d> > & T,
  const Eigen::MatrixXd & W,
  Eigen::MatrixXd & U);
#endif
