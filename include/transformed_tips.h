#ifndef TRANSFORMED_TIPS_H
#define TRANSFORMED_TIPS_H

#include "Skeleton.h"
#include <Eigen/Core>
// Compute the positions of specified bone "tips" (e.g., where the bone
// connects to its children; as opposed to "tails", where the bone connects to
// its parent) _after_ evaluating the forward kinematics chain in the given
// skeleton.
//
// Inputs:
//   skeleton  #bones list of bones with relative transformations stored in .xzx
//   b  #b list of indices into skelton of endpoints to compute
// Returns  #b*3 vector of transformed tip positions 
Eigen::VectorXd transformed_tips(
  const Skeleton & skeleton, 
  const Eigen::VectorXi & b);
#endif
