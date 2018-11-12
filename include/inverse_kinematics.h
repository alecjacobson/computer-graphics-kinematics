#ifndef INVERSE_KINEMATICS_H
#define INVERSE_KINEMATICS_H
#include <functional>
#include <Eigen/Dense>
void inverse_kinematics(
  const std::function<double(Skeleton &)> & E,
  const std::function<Eigen::VectorXd(Skeleton &)> & dEdx,
  const Eigen::VectorXi & b,
  Skeleton & skeleton);
#endif
