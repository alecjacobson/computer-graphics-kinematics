#include "euler_angles_to_transform.h"

Eigen::Affine3d euler_angles_to_transform(
  const Eigen::Vector3d & xzx)
{
  /////////////////////////////////////////////////////////////////////////////
  // Replace with your code
  Eigen::Affine3d A;
  A.matrix() << 
    1,0,0,0,
    0,1,0,0,
    0,0,1,0,
    0,0,0,1;
  return A;
  /////////////////////////////////////////////////////////////////////////////
}
