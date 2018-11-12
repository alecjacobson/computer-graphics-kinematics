#ifndef EULER_ANGLES_TO_TRANSFORM_H
#define EULER_ANGLES_TO_TRANSFORM_H
#include <Eigen/Core>
#include <Eigen/Geometry>

Eigen::Affine3d euler_angles_to_transform(
  const Eigen::Vector3d & xzx);
#endif
