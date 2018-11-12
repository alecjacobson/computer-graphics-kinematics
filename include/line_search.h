#ifndef LINE_SEARCH_H
#define LINE_SEARCH_H
#include <Eigen/Core>
#include <functional>
// Inputs:
//   f  function that computes scalar objective value at a given z
//   z  #z vector of initial z values
//   dz  #z vector of changes to z
//   max_step  maximum step to take in dir
// Returns optimal step
double line_search(
  const std::function<double(const Eigen::VectorXd &)> & f,
  const std::function<void(Eigen::VectorXd &)> & proj_z,
  const Eigen::VectorXd & z,
  const Eigen::VectorXd & dz,
  const double max_step);
#endif
