#include "kinematics_jacobian.h"
#include "transformed_tips.h"
#include <iostream>

void kinematics_jacobian(
  const Skeleton & skeleton,
  const Eigen::VectorXi & b,
  Eigen::MatrixXd & J)
{
  /////////////////////////////////////////////////////////////////////////////
  // Replace with your code
  J = Eigen::MatrixXd::Zero(b.size()*3,skeleton.size()*3);
  /////////////////////////////////////////////////////////////////////////////
}
