#ifndef CATMULL_ROM_INTERPOLATION_H
#define CATMULL_ROM_INTERPOLATION_H
#include <Eigen/Core>
#include <vector>
#include <utility> // std::pair

Eigen::Vector3d catmull_rom_interpolation(
  const std::vector<std::pair<double, Eigen::Vector3d> > & keyframes,
  double t);
#endif
