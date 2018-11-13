#ifndef PROJECTED_GRADIENT_DESCENT_H
#define PROJECTED_GRADIENT_DESCENT_H

#include <Eigen/Core>
#include <functional>

// Conduct `max_iters` iterations of projected gradient descent.
//
// Inputs:
//   f  function that computes scalar objective value at a given z
//   grad_f  function that computes gradient of f with respect to z at a given z
//   proj_z  function that projects z onto the set of feasible values
//   z  #z vector of initial z values
// Outputs
//   z  #z vector of optimized z values
void projected_gradient_descent(
  const std::function<double(const Eigen::VectorXd &)> & f,
  const std::function<Eigen::VectorXd(const Eigen::VectorXd &)> & grad_f,
  const std::function<void(Eigen::VectorXd &)> & proj_z,
  const int max_iters,
  Eigen::VectorXd & z);

#endif
