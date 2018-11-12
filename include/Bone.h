#ifndef BONE_H
#define BONE_H
#include <Eigen/Core>
#include <Eigen/Geometry>
#include <limits>

class Bone
{
  const double inf = std::numeric_limits<double>::infinity();
  public:
    int parent_index;
    int weight_index;
    Eigen::Affine3d rest_T;
    Eigen::Vector3d xzx;
    Eigen::Vector3d xzx_max;
    Eigen::Vector3d xzx_min;
    Bone(
      int _parent_index,
      int _weight_index,
      Eigen::Affine3d _rest_T):
      rest_T(std::move(_rest_T)),
      parent_index(std::move(_parent_index)),
      weight_index(std::move(_weight_index)),
      xzx(0,0,0),
      xzx_max(inf,inf,inf),
      xzx_min(-inf,-inf,-inf)
  { };
  public:
    EIGEN_MAKE_ALIGNED_OPERATOR_NEW
};
#endif
