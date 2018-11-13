#ifndef KINEMATICS_JACOBIAN_H
#define KINEMATICS_JACOBIAN_H
#include <Eigen/Core>
#include "Skeleton.h"
// Given a list of 
//
// Inputs:
//   b  #b list of indices into skeleton of endpoints to consider
//   skeleton  #bones list of bones
// Outputs:
//   J  #b*3 by #bones*3 Jacobian matrix of partial derivatives. So that
//     J(i*3+c,j*3+a) = ∂xi,c/∂θj,a where xi,c is the cth component of the ith
//     endpoint position in b and θj,a is the ath Euler angle in the jth bone.
void kinematics_jacobian(
  const Skeleton & skeleton,
  const Eigen::VectorXi & b,
  Eigen::MatrixXd & J);
#endif
