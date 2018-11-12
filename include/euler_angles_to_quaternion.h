#ifndef EULER_ANGLES_TO_QUATERNION_H
#define EULER_ANGLES_TO_QUATERNION_H
#include <Eigen/Core>
#include <Eigen/Geometry>

Eigen::Quaterniond euler_angles_to_quaternion(
  const Eigen::Vector3d & xzx);
#endif
