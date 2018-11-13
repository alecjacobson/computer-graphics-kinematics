#ifndef CATMULL_ROM_INTERPOLATION_H
#define CATMULL_ROM_INTERPOLATION_H
#include <Eigen/Core>
#include <vector>
#include <utility> // std::pair

// Interpolate a given set of 3d vector keyframes (e.g., of Euler angles) at a
// time t using a Catmull-Rom spline.
//
// Inputs:
//   keyframes  #keyframes list of pairs of key-times and key-values sorted in
//     ascending order of key-time
//   t  query time
// Returns inteprolated value at time t
Eigen::Vector3d catmull_rom_interpolation(
  const std::vector<std::pair<double, Eigen::Vector3d> > & keyframes,
  double t);
#endif
