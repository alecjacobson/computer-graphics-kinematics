#ifndef EULER_ANGLES_TO_TRANSFORM_H
#define EULER_ANGLES_TO_TRANSFORM_H
#include <Eigen/Core>
#include <Eigen/Geometry>
// Construct a rotation matrix (as a 4x4 transformation) given a set of Euler
// angles.
//
// Inputs:
//   xzx  3-vector of extrinsic Euler angles rotating about the x-, z-, and
//     x-axes.
// Returns 3d Eigen Affine transformation.
Eigen::Affine3d euler_angles_to_transform(const Eigen::Vector3d & xzx);
#endif
