#ifndef FORWARD_KINEMATICS_H
#define FORWARD_KINEMATICS_H
#include "Skeleton.h"
#include <Eigen/Core>
#include <vector>
// Compute the deformations (tranformations from rest pose) for each node in a
// forward kinematics hiearchy (reading each node's relative transformation from
// rest).
//
// Inputs:
//   skeleton  transformation hierarchy of #T bones
// Outputs:
//   T  #T list of affine transformations
void forward_kinematics(
  const Skeleton & skeleton,
  std::vector<Eigen::Affine3d,Eigen::aligned_allocator<Eigen::Affine3d> > & T);
#endif
