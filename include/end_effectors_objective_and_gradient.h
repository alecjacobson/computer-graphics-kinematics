#ifndef END_EFFECTORS_OBJECTIVE_AND_GRADIENT_H
#define END_EFFECTORS_OBJECTIVE_AND_GRADIENT_H
#include <Eigen/Core>
#include <functional>
#include "Skeleton.h"
// Given a skeleton and a list of end-effector constraints, construct function
// handles that will compute:
//    the least-squares objective value,
//    the least-squares objective gradient, and
//    project a potential solution onto a feasible solution (within joint limit
//    bounds).
//
// Inputs:
//   skeleton  #bones list of bones
//   b  #b list of indices into skeleton of end-effector constraints
//   xb0  3*#b list of end-effector positions, ordered as [x0 y0 z0 x1 y1 z1 …]
// Outputs:
//   f  function handle that computes the least-squares objective value given a
//     #bones list of Euler angles 
//   grad_f  function handle that computes the least-squares objective gradient
//     given a #bones list of Euler angles 
//   proj_z  function handle that projects a given set of Euler angles onto the
//     input skeleton's joint angles
//   
void end_effectors_objective_and_gradient(
  const Skeleton & skeleton,
  const Eigen::VectorXi & b,
  const Eigen::VectorXd & xb0,
  std::function<double(const Eigen::VectorXd &)> & f,
  std::function<Eigen::VectorXd(const Eigen::VectorXd &)> & grad_f,
  std::function<void(Eigen::VectorXd &)> & proj_z);
#endif
