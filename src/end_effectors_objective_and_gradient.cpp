#include "end_effectors_objective_and_gradient.h"
#include "transformed_tips.h"
#include "kinematics_jacobian.h"
#include "copy_skeleton_at.h"
#include <iostream>

void end_effectors_objective_and_gradient(
  const Skeleton & skeleton,
  const Eigen::VectorXi & b,
  const Eigen::VectorXd & xb0,
  std::function<double(const Eigen::VectorXd &)> & f,
  std::function<Eigen::VectorXd(const Eigen::VectorXd &)> & grad_f,
  std::function<void(Eigen::VectorXd &)> & proj_z)
{
  /////////////////////////////////////////////////////////////////////////////
  // Replace with your code
  f = [&](const Eigen::VectorXd & A)->double
  {
    return 0.0;
  };
  grad_f = [&](const Eigen::VectorXd & A)->Eigen::VectorXd
  {
    return Eigen::VectorXd::Zero(A.size());
  };
  proj_z = [&](Eigen::VectorXd & A)
  {
    assert(skeleton.size()*3 == A.size());
  };
  /////////////////////////////////////////////////////////////////////////////
}
