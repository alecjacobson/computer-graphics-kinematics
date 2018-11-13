#ifndef COPY_SKELETON_AT_H
#define COPY_SKELETON_AT_H
#include "Skeleton.h"
#include <Eigen/Core>
// Copy a given skeleton with joint angles set to those in vector A.
//
// Inputs:
//   skeleton  input skeleton
//   A  #bones*3 list of Euler angles
// Returns a skeleton copy
Skeleton copy_skeleton_at(const Skeleton & skeleton, const Eigen::VectorXd & A);
#endif
