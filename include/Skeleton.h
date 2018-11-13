#ifndef SKELETON_H
#define SKELETON_H
#include "Bone.h"
// A skeleton is just a list of Bones. Each bone knows its parent as an index
// into this list.
#include <vector>
using Skeleton = std::vector<Bone> ;
#endif 
