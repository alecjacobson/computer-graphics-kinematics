# Computer Graphics – Kinematics

> **To get started:** Clone this repository using
> 
>     git clone --recursive http://github.com/alecjacobson/computer-graphics-kinematics.git
>

## Background

![](images/robot-arm.gif)

### Read Chapter 15.1-15.5 of _Fundamentals of Computer Graphics (4th Edition)_.

### Read Chapter 16.1-16.4 of _Fundamentals of Computer Graphics (4th Edition)_.

### Skeleton

In this assignment we'll consider animating shapes _rigged_ to an internal
skeleton. The skeleton is a [(graphical) user interface (UI)
_metaphor_](https://en.wikipedia.org/wiki/Interface_metaphor). A skeleton is a
[tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) of rigid bones, not
unlike the [anatomical bones](https://en.wikipedia.org/wiki/Bone) in a human or
animal.

Each "bone" in the skeleton is really a UI widget for visualizing and
controlling a 3D [rigid
transformation](https://en.wikipedia.org/wiki/Rigid_transformation). A common
visualization of 3D bone in computer graphics is a long, pointed [pyramid
shape](https://en.wikipedia.org/wiki/Pyramid_(geometry)). This reveals the
twisting rotation as well as the tree hierarchy: the bone points toward its
children.

![](images/robot-arm-wireframe.gif)

_Unlike_ anatomy where the brain triggers muscles to flex and pull the passive
bones around, the bones of a skeleton rig will define the pose of a shape.

For each bone, we will consider _**three**_ "states".

#### 1. Canonical Bone

The "Canonical Bone" of length <img src="svgs/d30a65b936d8007addc9c789d5a7ae49.svg?invert_in_darkmode&sanitize=true" align=middle width=6.849430499999999pt height=22.83138pt/> lies along the <img src="svgs/332cc365a4987aacce0ead01b8bdcc0b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.3951pt height=14.15535pt/>-axis with its "tail" at
the origin <img src="svgs/14fd3d9f61a5bc79012bc3ee8ac92d9a.svg?invert_in_darkmode&sanitize=true" align=middle width=52.05486pt height=24.6576pt/>, its "tip" at <img src="svgs/fdbfbfa4f80d9334e03890cf0313d2c7.svg?invert_in_darkmode&sanitize=true" align=middle width=50.68503pt height=24.6576pt/>. 

![](images/canonical-bone.png)

The bone is endowed with an
orientation or [frame](https://en.wikipedia.org/wiki/Moving_frame). This helps
define a canonical _twisting_ direction. We will define twisting as rotating about the <img src="svgs/332cc365a4987aacce0ead01b8bdcc0b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.3951pt height=14.15535pt/>-axis in the canonical frame. 

![](images/canonical-twisting.gif)

For example, in this assignment, _bending_ is accomplished by rotating about the
<img src="svgs/f93ce33e511096ed626b4719d50f17d2.svg?invert_in_darkmode&sanitize=true" align=middle width=8.367645pt height=14.15535pt/>-axis in the canonical frame.

![](images/canonical-bending.gif)

Composing a twist, bend and
another twist spans all possible 3D rotations. 

![](images/canonical-rotating.gif)

We call the three angles composed
into a rotation this way, [Euler angles][eulerangles] (not to be confused with
the [homophonous](https://en.wiktionary.org/wiki/homophonous) [Oiler
angles](https://upload.wikimedia.org/wikipedia/commons/9/97/Odessa_TX_Oil_Well_with_Lufkin_320D_pumping_unit.gif)).

#### 2. Rest Bone

To assemble a skeleton inside our shape will we map each bone from its
[canonical bone][1.canonicalbone] to its position _and orientation_ in the
undeformed model. Maintaining the rigidity of the bone, this means for each bone
there's a rigid transformation <img src="svgs/e4e894fddf2f412a176bb46f93357104.svg?invert_in_darkmode&sanitize=true" align=middle width=143.46997499999998pt height=32.14629pt/> that places its tail and tip to the desired positions in the model. 

![](images/rest-bone.png)

We
use the convention that the "canonical tail" (the origin <img src="svgs/14fd3d9f61a5bc79012bc3ee8ac92d9a.svg?invert_in_darkmode&sanitize=true" align=middle width=52.05486pt height=24.6576pt/>) is mapped to
the "rest tail" inside the model. This means that the _translation_ part of the
matrix <img src="svgs/ac1f0feae8dd6b2ca2cb67b3e48ed33e.svg?invert_in_darkmode&sanitize=true" align=middle width=13.150665pt height=32.14629pt/> is simply the tail position, <img src="svgs/3563b877675715bf1b360a6df4d8b36c.svg?invert_in_darkmode&sanitize=true" align=middle width=49.116209999999995pt height=26.76201pt/>:
<p align="center"><img src="svgs/7ac62e1378b7bb3428e08fed2f19ab73.svg?invert_in_darkmode&sanitize=true" align=middle width=261.2841pt height=138.08355pt/></p>

The bone's
rotation is chosen so that the "canonical tip" <img src="svgs/fdbfbfa4f80d9334e03890cf0313d2c7.svg?invert_in_darkmode&sanitize=true" align=middle width=50.68503pt height=24.6576pt/> maps to the "rest
tip" <img src="svgs/5de02a881c9969bdb7ea77cd77815aea.svg?invert_in_darkmode&sanitize=true" align=middle width=51.32391pt height=32.42019pt/>:
<p align="center"><img src="svgs/738e3f24ea4849ebad28caab669a0aaa.svg?invert_in_darkmode&sanitize=true" align=middle width=226.0038pt height=138.08355pt/></p>

Typically the "rest tail" of is coincident with the "rest tip" of its
parent (if it exists): 
<p align="center"><img src="svgs/96bfb1177171500cf655176546db4640.svg?invert_in_darkmode&sanitize=true" align=middle width=52.041pt height=20.913255pt/></p>

This still leaves any amount of _twisting_ of the bone. In the canonical frame,
we can think of this as pre-twisting the bone along the canonical <img src="svgs/332cc365a4987aacce0ead01b8bdcc0b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.3951pt height=14.15535pt/>-axis.
Clearly, twisting does not effect the ability to map the tail and tip to the
correct position. This twist is _chosen_ so that canonical bending aligns with a
meaningful direction. For example, we may twist a [tibia
(shinbone)](https://en.wikipedia.org/wiki/Tibia) bone so that canonical bending
around the <img src="svgs/f93ce33e511096ed626b4719d50f17d2.svg?invert_in_darkmode&sanitize=true" align=middle width=8.367645pt height=14.15535pt/>-axis means bending at the
[knee](https://en.wikipedia.org/wiki/Knee).

Each rest transformation <img src="svgs/ac1f0feae8dd6b2ca2cb67b3e48ed33e.svg?invert_in_darkmode&sanitize=true" align=middle width=13.150665pt height=32.14629pt/> _places_ its corresponding bone inside the
undeformed shape. The rest transformations do not measure any deformation of the
shape from its original position. Thus, the _pose_ of each bone will be measured
_relative_ to the "rest bone".

#### 3. Pose Bone

The final state to consider is when a bone is _posed_. That is, mapped to a new
position and orientation from its rest state. 

In general, each rest bone undergoes a rigid transformation <img src="svgs/e89070fea1f23ca7baf9956bd9680795.svg?invert_in_darkmode&sanitize=true" align=middle width=70.79885999999999pt height=26.76201pt/>,
composed of a rotation <img src="svgs/c23290b6dcef579d650eb996e983e0b2.svg?invert_in_darkmode&sanitize=true" align=middle width=71.826315pt height=26.76201pt/> and a translation <img src="svgs/5b3a6746479542bbd422d7c51de328dc.svg?invert_in_darkmode&sanitize=true" align=middle width=48.173235pt height=26.76201pt/>, mapping each of its 
rest points <img src="svgs/47a7cb84838ee3006335481c45b809b8.svg?invert_in_darkmode&sanitize=true" align=middle width=50.21676pt height=26.76201pt/> to its corresponding posed postion <img src="svgs/999935b7b3c784b87d1ae9f0f326abed.svg?invert_in_darkmode&sanitize=true" align=middle width=50.79888pt height=26.76201pt/>:

<p align="center"><img src="svgs/12e5530e36704c7b6e2d3821267c3306.svg?invert_in_darkmode&sanitize=true" align=middle width=59.58876pt height=12.1004895pt/></p>

![](images/beast-pose-bone.gif)

<img src="svgs/02f380174e367c8935a57f86907fc7da.svg?invert_in_darkmode&sanitize=true" align=middle width=13.150665pt height=22.557149999999996pt/> is expressed as a _global_ mapping of any point in the rest reference frame
to its pose position. This makes it convenient for [blending transformations
(see below)][linearblendskinning], but it's not so obvious how to pick coherent
values for <img src="svgs/02f380174e367c8935a57f86907fc7da.svg?invert_in_darkmode&sanitize=true" align=middle width=13.150665pt height=22.557149999999996pt/>. In particular, we would like each bone to rotate about its
parent's tip, but this position is determined by the parent's pose
transformation <img src="svgs/9edc4d158664ffc245acb3d645a207af.svg?invert_in_darkmode&sanitize=true" align=middle width=19.927214999999997pt height=22.557149999999996pt/>, which in turn should rotate about the grandparent's tip
and so on.

### Forward Kinematics

One way to determine the rigid pose transformations <img src="svgs/aefdf21b4530786d703eb199d0ef8680.svg?invert_in_darkmode&sanitize=true" align=middle width=76.271745pt height=26.76201pt/> for each
bone <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> in a skeleton is to aggregate _relative rotations_ <img src="svgs/5f30f962417028f73707b9c67c759def.svg?invert_in_darkmode&sanitize=true" align=middle width=77.2992pt height=27.81735pt/> between a bone <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> and its parent bone <img src="svgs/0d19b0a4827a28ecffa01dfedf5f5f2c.svg?invert_in_darkmode&sanitize=true" align=middle width=12.921479999999999pt height=14.15535pt/> in the skeletal tree.
The final transformation at some bone <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> deep in the skeletal tree is computed
via a recursive equation.

For each bone, (reading the effect of transformations _right to left_) we first
_undo_ the map from canonical to rest (i.e., via inverting <img src="svgs/3781bbdc0c2d33e3b38204ec3e50abb9.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80152pt height=32.14629pt/>), then
rotate by our relative rotation <img src="svgs/16716731bb131a1a4537324db4e3f635.svg?invert_in_darkmode&sanitize=true" align=middle width=18.828975pt height=27.81735pt/>, then map back to rest (via
<img src="svgs/eb17c8223b0f3c0aae89ee2237516cc6.svg?invert_in_darkmode&sanitize=true" align=middle width=14.257155000000001pt height=32.05488pt/>). With our relative transformation accomplished, we continue _up the
tree_ [recursively](https://en.wikipedia.org/wiki/Recursion_(computer_science))
applying our parent's relative transformation, and our grandparent's and so on:
<p align="center"><img src="svgs/713f2dd4ed0e6ef0dc95c592c3f68e39.svg?invert_in_darkmode&sanitize=true" align=middle width=402.50264999999996pt height=157.809795pt/></p>

> **Question:** Does using relative rotations ensure that bone tails stay
> coincident with parent tips?
>
> **Hint:** What do you get if you multiply <img src="svgs/e36717016e5278d19538bb9a5f500387.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80152pt height=22.557149999999996pt/> and <img src="svgs/06751f0b0b6caaa7955275b01f167bb2.svg?invert_in_darkmode&sanitize=true" align=middle width=12.945405pt height=24.20121pt/>?

As a base case, the _root_ transformation can be defined to be the identity (no
transformation) or the rigid transformation placing the object/character
generally into a larger scene.

This has the great advantage that if the entire model is rotated or translated
at the root, the relative transformations still apply correctly. This property
holds locally, too. If bone <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> controls the [tibia
(shinbone)](https://en.wikipedia.org/wiki/Tibia) and <img src="svgs/e468ef4a9a101ead715ed84a6b9bcc0b.svg?invert_in_darkmode&sanitize=true" align=middle width=18.828975pt height=22.557149999999996pt/> applies a bend at
the knee, then twisting and bending at the parent hip bone will naturally
_compose_ with the knee bend.

It is convenient to express the relative rotations of each bone in the
[canonical frame][1.canonicalbone]. We can utilize canonical twist-bend-twist
rotations (three [Euler angles][eulerangles], <img src="svgs/e1a50bfa56675544041de20cf7e64760.svg?invert_in_darkmode&sanitize=true" align=middle width=59.063895pt height=22.83138pt/>). Each bone's rotation
is conducted in its canonical frame and then _brought_ through the rest frame
through a change of coordinates:

<p align="center"><img src="svgs/1019920fa305d295d1cee633b09ed6c6.svg?invert_in_darkmode&sanitize=true" align=middle width=558.62235pt height=157.809795pt/></p>

where the matrix <img src="svgs/900aa2972f345f0258b2e6a8b61c3a49.svg?invert_in_darkmode&sanitize=true" align=middle width=106.006395pt height=26.76201pt/> is the rotation by <img src="svgs/0e62162a970fbed24c43cd8e91daf0d1.svg?invert_in_darkmode&sanitize=true" align=middle width=10.753544999999999pt height=14.15535pt/> degrees around
the <img src="svgs/31fae8b8b78ebe01cbfbe2fe53832624.svg?invert_in_darkmode&sanitize=true" align=middle width=12.210989999999999pt height=14.15535pt/>-axis.

When implementing a skeleton, it is tempting to use a traditional [tree data
structure](https://en.wikipedia.org/wiki/Tree_(data_structure)) where each node
(bone) contains a list of pointers to its children (other bones).  However, by
the _right-to-left_ reading of the forward kinematics formulae above, it is more
convenient to use a data structure where each node (bone) has a pointer to its
(unique) parent (other bone). This is ridiculously named a [Spaghetti
Stack](https://en.wikipedia.org/wiki/Parent_pointer_tree).

> **Question:** What abstract data-structure is good for ensuring a parent's transformation  <img src="svgs/62608795c18f3bd5ce9c26bce0e210e4.svg?invert_in_darkmode&sanitize=true" align=middle width=24.312749999999998pt height=22.557149999999996pt/>
> are computed before its child's <img src="svgs/e36717016e5278d19538bb9a5f500387.svg?invert_in_darkmode&sanitize=true" align=middle width=17.80152pt height=22.557149999999996pt/>?
>
> **Hint:** 🥞

### Keyframe animation

To create a long animation, specifying three Euler angles for every bone for
every frame manually would be too difficult. The standard way to determine the
relative bone transformations for each frame is to
[interpolate](https://en.wikipedia.org/wiki/Interpolation) values specified at a
small number of "key" times during the animation. [Linear
interpolation](https://en.wikipedia.org/wiki/Linear_interpolation) will lead to
a choppy, robotic animation (try this first!). Instead [Catmull-Rom
interpolation](https://en.wikipedia.org/wiki/Cubic_Hermite_spline#Catmull–Rom_spline)
will produce a smooth animation. Fancier interpolation such as the
[Kochanek-Bartels method](https://en.wikipedia.org/wiki/Kochanek–Bartels_spline)
(called TCB in [the book](https://www.cs.cornell.edu/~srm/fcg4/)) allow better
control of [easing between key
poses](https://en.wikipedia.org/wiki/12_basic_principles_of_animation#Slow_In_and_Slow_Out).

![](images/hand-animation-sped-up.gif)

In this assignment, we will interpolate Euler angles directly. This works well
when only a single angle is changing at a time. However, [Euler angles do not
provide easy movement in every rotational
direction](https://en.wikipedia.org/wiki/Gimbal_lock). Euler angles model
rotations as _twist-bend-twist_. For our canonical bones, bending around the
<img src="svgs/f93ce33e511096ed626b4719d50f17d2.svg?invert_in_darkmode&sanitize=true" align=middle width=8.367645pt height=14.15535pt/>-axis is easy, but bending around the <img src="svgs/deceeaf6940a8c7a5a02373728002b0f.svg?invert_in_darkmode&sanitize=true" align=middle width=8.6493pt height=14.15535pt/>-axis requires first twisting by
<img src="svgs/fe95fd1126bb6ed125fbbe619d694d02.svg?invert_in_darkmode&sanitize=true" align=middle width=23.173755pt height=22.638659999999998pt/> and then "un"-twisting by <img src="svgs/01077064f9efeed9db887638325020d3.svg?invert_in_darkmode&sanitize=true" align=middle width=35.959109999999995pt height=22.638659999999998pt/> after bending.

So, for more complex interpolation of rotations, a different representation such
as [unit quaternions](https://en.wikipedia.org/wiki/Slerp) would be needed. This is
outside the scope of this assignment.

### Inverse Kinematics

In the [forward kinematics][forwardkinematics] model, the final position of the
tip of a finger is determined by setting (manually or via interpolation) the
relative transformations of each joint in the finger, the hand, the elbow, the
shoulder, ... This
[indirect](https://en.wikipedia.org/wiki/Direct_manipulation_interface) control
makes it difficult to achieve basic poses.  Instead, we can treat the problem of
setting relative rotations of internal bones (shoulder, elbow, hand, ...) as an
optimization problem where we try to minimize the distance between the tip of
the finger and where we want it to be.

Stated mathematically, for a skeleton with <img src="svgs/0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode&sanitize=true" align=middle width=14.43321pt height=14.15535pt/> bones, if we create a vector
<img src="svgs/b1464b5666a93e4a68ce563fc82f5e56.svg?invert_in_darkmode&sanitize=true" align=middle width=61.67600999999999pt height=26.76201pt/> stacking all the Euler angles of each bone vertically:

<p align="center"><img src="svgs/967f000ac0f36a2f4433040aee371cdd.svg?invert_in_darkmode&sanitize=true" align=middle width=103.06873499999999pt height=384.66119999999995pt/></p>

then we can ask for the best vector of angles <img src="svgs/39fabd4269f3ed42d410d3f60e118a32.svg?invert_in_darkmode&sanitize=true" align=middle width=8.1735885pt height=22.83138pt/>. Best-ness must be quantified
by an cost/energy/obective-function <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>. This energy is typically first written
with respect to the (global, non-relative) pose positions of certains bones
<img src="svgs/e4ad6bc27b560b37ad836731988bf416.svg?invert_in_darkmode&sanitize=true" align=middle width=57.40168499999999pt height=26.76201pt/> (often the "tip" of a
[leaf](https://en.wikipedia.org/wiki/Tree_(data_structure)#Terminology_used_in_trees)
bone of the skeletal tree, called an [end
effector](https://en.wikipedia.org/wiki/Robot_end_effector)). For example, we 
then we could design our energy to measure the squared distance between the pose
tip <img src="svgs/c6fb89b60f91828eac09b587b990ddae.svg?invert_in_darkmode&sanitize=true" align=middle width=15.757995pt height=14.61207pt/> of some bone <img src="svgs/4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode&sanitize=true" align=middle width=7.0548554999999995pt height=22.83138pt/> and a desired goal location <img src="svgs/30d5d562f63636be72c19af8ec405255.svg?invert_in_darkmode&sanitize=true" align=middle width=50.79888pt height=26.76201pt/>:

<p align="center"><img src="svgs/38405dbde6e9d02d7ab8166b7db62c9b.svg?invert_in_darkmode&sanitize=true" align=middle width=139.39233pt height=18.312359999999998pt/></p>

Using forward kinematics, we can express <img src="svgs/c6fb89b60f91828eac09b587b990ddae.svg?invert_in_darkmode&sanitize=true" align=middle width=15.757995pt height=14.61207pt/> and in turn <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> with respect to
relative rotations: 

<p align="center"><img src="svgs/201fcb69625a74169bc67a2939ef5270.svg?invert_in_darkmode&sanitize=true" align=middle width=96.50883pt height=20.31975pt/></p>

where <img src="svgs/78d94e23f6db01c9f2c6d425303520f7.svg?invert_in_darkmode&sanitize=true" align=middle width=18.93144pt height=22.557149999999996pt/> depends on <img src="svgs/1ef545c57ac92de4f0e08ab1d8cdf759.svg?invert_in_darkmode&sanitize=true" align=middle width=76.406385pt height=22.83138pt/> and <img src="svgs/97f4017857fdbd5567a3cf5d2503cf92.svg?invert_in_darkmode&sanitize=true" align=middle width=25.132634999999997pt height=22.557149999999996pt/> which depends on 
<img src="svgs/947c63a44a9df8f47a88ab35f30fea5a.svg?invert_in_darkmode&sanitize=true" align=middle width=97.47556499999999pt height=22.83138pt/>. In this way our energy can be written as a
function of <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>:

<p align="center"><img src="svgs/8bc7d7faa47a4aa1b24e33c06e3f524d.svg?invert_in_darkmode&sanitize=true" align=middle width=183.3414pt height=18.312359999999998pt/></p>

We can design arbitrarily complex energies to satisfy our interaction needs. In
this assignment, we consider that there is a list of constrained end effectors
<img src="svgs/673132a12e241c60a8e077aff16402c2.svg?invert_in_darkmode&sanitize=true" align=middle width=133.2474pt height=24.6576pt/> and our objective is that all selected end effectors <img src="svgs/d3aa71141bc89a24937c86ec1d350a7c.svg?invert_in_darkmode&sanitize=true" align=middle width=11.70576pt height=22.83138pt/>
go to their prescribed locations (provided by the mouse-drag UI).
using the simple squared distance measure above.

So, over all choices of <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/> we'd like to optimize:

<p align="center"><img src="svgs/1daf19d464ed6d3feac47efc092705f0.svg?invert_in_darkmode&sanitize=true" align=middle width=190.0173pt height=44.969924999999996pt/></p>

<!--
Our energy will have two terms.

First, for a certain constrained end effector <img src="svgs/2020a79c00e140ee1a054ecab57a289c.svg?invert_in_darkmode&sanitize=true" align=middle width=13.15941pt height=22.83138pt/> we ask that it lies as close
as possible to the [viewing
ray](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)) through the user's
[mouse pointer](https://en.wikipedia.org/wiki/Pointer_(user_interface)). 
We can measure the distance between some point <img src="svgs/b0ea07dc5c00127344a1cad40467b8de.svg?invert_in_darkmode&sanitize=true" align=middle width=9.977219999999999pt height=14.61207pt/> and the line passing
through the camera/eye location <img src="svgs/b193e42944e06637195ea4bd2f3acdde.svg?invert_in_darkmode&sanitize=true" align=middle width=8.66448pt height=14.61207pt/> and the mouse location _unprojected_ onto
its 3D position on the screen placed in the scene at <img src="svgs/273457f251a6f8920e7b6c485c28b74f.svg?invert_in_darkmode&sanitize=true" align=middle width=15.753374999999998pt height=14.61207pt/> using:

<p align="center"><img src="svgs/4f83135b48b04a5c519cd66aaceaf3f2.svg?invert_in_darkmode&sanitize=true" align=middle width=435.80294999999995pt height=42.804134999999995pt/></p>

This formula can be simplified to a much simpler expression since <img src="svgs/273457f251a6f8920e7b6c485c28b74f.svg?invert_in_darkmode&sanitize=true" align=middle width=15.753374999999998pt height=14.61207pt/> and <img src="svgs/b193e42944e06637195ea4bd2f3acdde.svg?invert_in_darkmode&sanitize=true" align=middle width=8.66448pt height=14.61207pt/>
do not depend on <img src="svgs/b0ea07dc5c00127344a1cad40467b8de.svg?invert_in_darkmode&sanitize=true" align=middle width=9.977219999999999pt height=14.61207pt/> (left to the reader/implementor).


> **Question:** How would you _alternatively_ write this term by measuring
> distances in image space?
>
> **Hint:** 📽
>

Second, for all of the other end effectors <img src="svgs/1d0d9bd3ae0a6e8e2a4040fd35030b3b.svg?invert_in_darkmode&sanitize=true" align=middle width=59.837084999999995pt height=24.6576pt/>, we will
constrain their positions to their rest locations <img src="svgs/d4fccb3928bb15ad407ad7d33c994d70.svg?invert_in_darkmode&sanitize=true" align=middle width=20.14353pt height=24.20121pt/>, using the
simple squared distance measure above.

The goal of inverse kinematics is to minimize the sum of these energies over all
choices of <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>:

<p align="center"><img src="svgs/7908d516b2b431796ae291f29fdbf2d9.svg?invert_in_darkmode&sanitize=true" align=middle width=315.7638pt height=45.992595pt/></p>
-->

We will further constrain our problem by imposing
[upper and lower bounds](https://en.wikipedia.org/wiki/Constrained_optimization#Inequality_constraints)
on our angles <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>. These correspond to joint limits. For example, the joint
limits of a hinge or elbow type joint may look like:

<p align="center"><img src="svgs/651e1c92c0989b3bb2725464488cc71a.svg?invert_in_darkmode&sanitize=true" align=middle width=339.93135pt height=15.337525499999998pt/></p>

These would ensure that our joint cannot twist, and can only bend in one direction.

So our full optimization problem becomes 

<p align="center"><img src="svgs/d17f5179af2466ad0b3c92348acf53b3.svg?invert_in_darkmode&sanitize=true" align=middle width=166.50644999999997pt height=26.077425pt/></p>

where <img src="svgs/86fa7eae344632b6bdf796fb8b8bc82b.svg?invert_in_darkmode&sanitize=true" align=middle width=73.459155pt height=27.41046pt/> stack lower/upper bounds correspondingly to <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>.

![](images/ikea-lamp-ik.gif)

This type of minimization is non-trivial. Our energy is a quadratic [sum of
squares](https://en.wikipedia.org/wiki/Linear_least_squares) in <img src="svgs/c6fb89b60f91828eac09b587b990ddae.svg?invert_in_darkmode&sanitize=true" align=middle width=15.757995pt height=14.61207pt/>, but
<img src="svgs/c6fb89b60f91828eac09b587b990ddae.svg?invert_in_darkmode&sanitize=true" align=middle width=15.757995pt height=14.61207pt/> is a non-linear function of <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>. In turn, this means to minimize <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> as
a function of <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/> we must solve a [non-linear least
squares](https://en.wikipedia.org/wiki/Non-linear_least_squares) problem. 

#### Projected Gradient Descent

We're faced with a bound constrained non-linear optimization problem.  To solve
it, we will construct an initial guess and then iteratively improve the guess by
moving in a direction that decreases <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>, after each step _snap_ or project the
guess to stay within the bounds if necessary. This algorithm is called
_projected gradient descent_.

The idea behind [_gradient
descent_](https://en.wikipedia.org/wiki/Gradient_descent) is intuitive: if you
want to get to the bottom of a canyon, look at the ground and walk in the
direction that goes downhill.

So, we iteratively take a step in the _negative_ gradient direction of our
objective function <img src="svgs/207cd5ef005ea05c1025a66de9222f42.svg?invert_in_darkmode&sanitize=true" align=middle width=57.81963pt height=24.6576pt/>:

<p align="center"><img src="svgs/9aa9bf6609bfd893a34babef6ca3b720.svg?invert_in_darkmode&sanitize=true" align=middle width=180.81855pt height=43.251615pt/></p>

Applying the [chain rule](https://en.wikipedia.org/wiki/Chain_rule), this
iteration becomes

<p align="center"><img src="svgs/f354fcbf8db9e5a69bc921096f2ace93.svg?invert_in_darkmode&sanitize=true" align=middle width=231.05939999999998pt height=43.251615pt/></p>

where <img src="svgs/b8299584eb2f191a70ad2cb35778e6a8.svg?invert_in_darkmode&sanitize=true" align=middle width=68.419395pt height=29.19114pt/>,
<img src="svgs/fba60cf492f07e0c07fc2c35cd80ad72.svg?invert_in_darkmode&sanitize=true" align=middle width=69.032535pt height=29.19114pt/>, and <img src="svgs/11a81c264d5da44610abf6cd651cd155.svg?invert_in_darkmode&sanitize=true" align=middle width=91.930905pt height=29.19114pt/>

The change in tip positions <img src="svgs/b0ea07dc5c00127344a1cad40467b8de.svg?invert_in_darkmode&sanitize=true" align=middle width=9.977219999999999pt height=14.61207pt/> with respect to joint angles <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/> does not
depend on the choice of energy <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>. We call this matrix of changes the kinematic
[Jacobian](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant), <img src="svgs/cca353be29830628fd37bb9e11b61c0a.svg?invert_in_darkmode&sanitize=true" align=middle width=85.030605pt height=29.19114pt/>:


<p align="center"><img src="svgs/10d622f11190c4bc164f8e4aa28fb4ca.svg?invert_in_darkmode&sanitize=true" align=middle width=58.73373pt height=33.812129999999996pt/></p>

Written in terms of <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/> our step becomes,

<p align="center"><img src="svgs/488a9a40a4f71b24e857be2ad27f45ee.svg?invert_in_darkmode&sanitize=true" align=middle width=168.25379999999998pt height=39.45249pt/></p>

> **Question:** Can we take an arbitrarily large step <img src="svgs/e38aac0b1f52dfdadca9fba9bcfa5b95.svg?invert_in_darkmode&sanitize=true" align=middle width=52.905269999999994pt height=21.18732pt/>?
>
> **Hint:** What if we just need to change <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/> by a small, non-zero amount?
> What would chooing <img src="svgs/90d075faa5bfd8c2738cb5755789b24b.svg?invert_in_darkmode&sanitize=true" align=middle width=104.046855pt height=21.18732pt/> do to <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>? What would that in turn do to
> <img src="svgs/207cd5ef005ea05c1025a66de9222f42.svg?invert_in_darkmode&sanitize=true" align=middle width=57.81963pt height=24.6576pt/>?

For sufficiently small <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/>, each step will decrease the objective energy <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>.

If the gradient of <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> becomes zero, then we're at a [stationary
point](https://en.wikipedia.org/wiki/Stationary_point) and likely at a minimum.

To ensure that our bounds are obeyed, after each step we need to _project_ onto
our constraints by snapping each value to its respective bound if necessary:

<p align="center"><img src="svgs/6a07539d71381c6f93fa61e1190ad4c2.svg?invert_in_darkmode&sanitize=true" align=middle width=216.39089999999996pt height=18.636585pt/></p>

We'll refer to this as a projection filter acting on the entire vector <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/>:

<p align="center"><img src="svgs/1846b88871b01ae40369b157edb1db64.svg?invert_in_darkmode&sanitize=true" align=middle width=91.0272pt height=16.438356pt/></p>


> #### Newton's method
> 
> The local gradient of a function can be very different from the "best" descent
> direction. The choice of <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/> reflects how much we "trust" this direction.
> Unfortunately, if <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/> is too large our iterations may diverge. If <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/> is too
> small, we will have to do many iterations.
> 
> In order to find a _better_ descent direction, let's assume we knew _more_ about
> <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>. That is, suppose we also knew its second derivatives: <img src="svgs/de0ca7d78ee3005e08686dcfdc88070a.svg?invert_in_darkmode&sanitize=true" align=middle width=23.54187pt height=33.45969pt/>. 
> 
> Given an initial guess <img src="svgs/83dbb4b45296124797c845dc3b48fa63.svg?invert_in_darkmode&sanitize=true" align=middle width=16.529700000000002pt height=26.76201pt/> we're looking to find a change <img src="svgs/52cdbba1eb4fddc47169867a1330fa0d.svg?invert_in_darkmode&sanitize=true" align=middle width=23.67585pt height=22.46574pt/> so that <img src="svgs/0eaaed4bba880174a78a00910749ac23.svg?invert_in_darkmode&sanitize=true" align=middle width=101.59808999999998pt height=26.76201pt/> is a stationary point.
> 
> Starting with our equilibrium equation,
> <p align="center"><img src="svgs/d2662ad457e2e9d04a48fd0f18b32d60.svg?invert_in_darkmode&sanitize=true" align=middle width=114.41859pt height=34.725404999999995pt/></p>
> 
> we substitute in <img src="svgs/6ee763468647b8d38622efbf9969e596.svg?invert_in_darkmode&sanitize=true" align=middle width=92.431185pt height=26.76201pt/>
> 
> <p align="center"><img src="svgs/3c2038a3d8031baca0fdc78ba9cb1e6f.svg?invert_in_darkmode&sanitize=true" align=middle width=165.55935pt height=35.777445pt/></p>
> 
> Plugging in a [Taylor series](https://en.wikipedia.org/wiki/Taylor_series)
> expansion
> 
> <p align="center"><img src="svgs/056f19f2520a45baf7908599494fafdd.svg?invert_in_darkmode&sanitize=true" align=middle width=541.3435499999999pt height=35.777445pt/></p>
> 
> and dropping higher order terms (<img src="svgs/e378afcd7cae11e7306c61a9c35bf6cf.svg?invert_in_darkmode&sanitize=true" align=middle width=19.178115000000002pt height=14.15535pt/>), we get:
> 
> <p align="center"><img src="svgs/5a6ef2f98097ac74dd773860ce493761.svg?invert_in_darkmode&sanitize=true" align=middle width=481.7224499999999pt height=58.24764pt/></p>
> 
> where we call <img src="svgs/28f45976002fbde24198bb5d0102da54.svg?invert_in_darkmode&sanitize=true" align=middle width=89.86296pt height=29.19114pt/> the [Hessian
> matrix](https://en.wikipedia.org/wiki/Hessian_matrix).  
> 
> Applying the differentiation by <img src="svgs/52cdbba1eb4fddc47169867a1330fa0d.svg?invert_in_darkmode&sanitize=true" align=middle width=23.67585pt height=22.46574pt/> we get a system of equations:
> 
> <p align="center"><img src="svgs/2df94561e6c203c915f852939b3ab91d.svg?invert_in_darkmode&sanitize=true" align=middle width=320.75505pt height=35.777445pt/></p>
> Solving for the change <img src="svgs/3919bbc84b8079e27194efe99a1f6a80.svg?invert_in_darkmode&sanitize=true" align=middle width=23.093729999999997pt height=22.46574pt/> we get:
> <p align="center"><img src="svgs/4f6caa9a88919c674c7e279727f0c28d.svg?invert_in_darkmode&sanitize=true" align=middle width=238.42005pt height=35.777445pt/></p>
> 
> So a _raw_ Newton's method update would be:
> 
> <p align="center"><img src="svgs/90a130f831709bf3feb431b84a94c121.svg?invert_in_darkmode&sanitize=true" align=middle width=243.50039999999998pt height=35.777445pt/></p>
> 
> If our Taylor series approximation was perfect (no high order terms in <img src="svgs/e378afcd7cae11e7306c61a9c35bf6cf.svg?invert_in_darkmode&sanitize=true" align=middle width=19.178115000000002pt height=14.15535pt/>; in
> otherwords <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> was quadratic), then Newton's method would be perfect: a single
> update immediately takes us to the minimum.
> 
> Newton's method is problematic for a number of reasons.
> 
>  1. We built our step purely based on the equations for a stationary point.
>     Nothing says we won't get sent toward a maximum or saddle-point. 
>  2. <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/> is often difficult or expensive to compute.
>  4. <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/> may be singular.
>  3. Inverting <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/> (even if possible) is often slow.
>  5. Our system is built off a local approximation of <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> so the descent
>     direction may _still_ point in the wrong direction.
> 
> Since we're approximating <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/> at every iteration anyway, we'll skirt many of
> these issues by considering various approximations of the Hessian matrix <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/>.
> We'll never actually compute <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/>.
> 
> #### Gradient Descent _Revisited_
> 
> The simplest approximation of <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/> is the identity matrix <img src="svgs/d8471e559d932f20f66bec32f6002e08.svg?invert_in_darkmode&sanitize=true" align=middle width=7.1689859999999985pt height=22.557149999999996pt/>. Plugging this
> into our truncated Taylor series expansion above, our approximation would read:
> 
> <p align="center"><img src="svgs/3dd9fb9e69298032369fa5a788a0371f.svg?invert_in_darkmode&sanitize=true" align=middle width=300.78345pt height=35.777445pt/></p>
> 
> and our step reduces to good ol' gradient descent:
> 
> <p align="center"><img src="svgs/9419e96ede420bf144ab3a0f38405db7.svg?invert_in_darkmode&sanitize=true" align=middle width=204.37229999999997pt height=35.777445pt/></p>
> 
> #### Gauss-Newton
>
> Given that we have already computed first derivatives in the Jacobian <img src="svgs/92b02b175485ba3cf5d2e5ad2b4568fe.svg?invert_in_darkmode&sanitize=true" align=middle width=78.66375pt height=33.20559pt/>, an even better approximation for Hessian <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/> than the
> identity <img src="svgs/d8471e559d932f20f66bec32f6002e08.svg?invert_in_darkmode&sanitize=true" align=middle width=7.1689859999999985pt height=22.557149999999996pt/> would be to use <img src="svgs/e71c2eb0164135302652c3b5e3ca430a.svg?invert_in_darkmode&sanitize=true" align=middle width=29.640599999999996pt height=27.912719999999997pt/>. The resulting update becomes:
>
> <p align="center"><img src="svgs/8ba397bd9812841129ba3231d287f6a8.svg?invert_in_darkmode&sanitize=true" align=middle width=241.2927pt height=34.725404999999995pt/></p>
>
> Unlike <img src="svgs/930b956ef51654e0669455a2cdd62fb5.svg?invert_in_darkmode&sanitize=true" align=middle width=14.794559999999999pt height=22.557149999999996pt/>, <img src="svgs/b166bfa6fb8405dcd97b1c618c8fc258.svg?invert_in_darkmode&sanitize=true" align=middle width=28.715775pt height=27.912719999999997pt/> is easy to compute if we're already computing
> <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/>. It is guaranteed to be [positive
> semi-definite](https://en.wikipedia.org/wiki/Positive-definite_matrix) and it
> is possible to invert or reliably
> [pseudo-invert](https://en.wikipedia.org/wiki/Moore–Penrose_inverse) (<img src="svgs/68705bd1509c8a68347575469b28450f.svg?invert_in_darkmode&sanitize=true" align=middle width=19.86303pt height=26.17758pt/>
> acting in place of <img src="svgs/1c07d877903d3f5f02198e2a8195038c.svg?invert_in_darkmode&sanitize=true" align=middle width=109.81971pt height=30.41115pt/>).
>
> The descent directions are often significantly better than gradient descent.
> As a result this method, called Gauss-Newton, requires many fewer iterations
> to converge.
>
> It still may try to descend in bad directions. In particular, for inverse
> kinematics, this Gauss-Newton method performs poorly if the desired positions
> are not reachable: over extending an arm. First the solution locks in place
> and then diverges. This happens when our Hessian approximation
> <img src="svgs/b166bfa6fb8405dcd97b1c618c8fc258.svg?invert_in_darkmode&sanitize=true" align=middle width=28.715775pt height=27.912719999999997pt/> starts misbehaving.
>
> A good fix is to blend between the gradient descent and Gauss-Newton search
> directions. That is blend between <img src="svgs/d8471e559d932f20f66bec32f6002e08.svg?invert_in_darkmode&sanitize=true" align=middle width=7.1689859999999985pt height=22.557149999999996pt/> and <img src="svgs/b166bfa6fb8405dcd97b1c618c8fc258.svg?invert_in_darkmode&sanitize=true" align=middle width=28.715775pt height=27.912719999999997pt/>. This is called
> the [Levenberg-Marquadt
> algorithm](https://en.wikipedia.org/wiki/Levenberg–Marquardt_algorithm).

#### Finite Differencing

But how do we compute the kinematic Jacobian <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/>? Since each entry in <img src="svgs/b0ea07dc5c00127344a1cad40467b8de.svg?invert_in_darkmode&sanitize=true" align=middle width=9.977219999999999pt height=14.61207pt/> is
the result of forward kinematics and not just a math expression, it's not
immediately obvious how to determine its derivatives. However, a derivative is
nothing more than the limit of a small change output divided by a small change
in the input:

<p align="center"><img src="svgs/f5b3db30acc4b16dff9a92781a5e219f.svg?invert_in_darkmode&sanitize=true" align=middle width=224.51055pt height=34.725404999999995pt/></p>

where <img src="svgs/165578d0076311fa849ec1a5bcc4c619.svg?invert_in_darkmode&sanitize=true" align=middle width=63.440189999999994pt height=29.19114pt/> is a vector of zeros except a 1 at location <img src="svgs/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710483pt height=21.68331pt/>.

We can numerically approximate this limit by fixing <img src="svgs/2ad9d098b937e46f9f58968551adac57.svg?invert_in_darkmode&sanitize=true" align=middle width=9.471165pt height=22.83138pt/> to a small value (e.g.,
<img src="svgs/09fb33d7908fa6a6ba9ff8defb106e4e.svg?invert_in_darkmode&sanitize=true" align=middle width=64.65376499999999pt height=26.76201pt/>). This is called the [finite
difference](https://en.wikipedia.org/wiki/Finite_difference) approximation:

<p align="center"><img src="svgs/6e43cbc57ea75c217e8e14d4ef76d2b9.svg?invert_in_darkmode&sanitize=true" align=middle width=194.41785pt height=34.725404999999995pt/></p>

For inverse kinematics, we will need to compute <img src="svgs/d430f21b99301012e11e0d7ab4fe7076.svg?invert_in_darkmode&sanitize=true" align=middle width=81.21943499999999pt height=24.6576pt/> once for each
Euler angle of each bone <img src="svgs/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710483pt height=21.68331pt/>. This requires <img src="svgs/fa8a4889423020a0642f17c77c07e4ea.svg?invert_in_darkmode&sanitize=true" align=middle width=22.652355pt height=21.18732pt/> calls to our forward kinematics
function (each with a slightly different input), which is in turn <img src="svgs/5e12273846712182a9633dc4c62b94f7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.213964999999995pt height=24.6576pt/>. This
makes the total cost <img src="svgs/d9fad1122d3ed3c58f6d9342c9260180.svg?invert_in_darkmode&sanitize=true" align=middle width=47.588474999999995pt height=26.76201pt/> to fill in our <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/> matrix.


>
> #### Automatic Differentiation
>
> Forward differencing requires <img src="svgs/5e12273846712182a9633dc4c62b94f7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.213964999999995pt height=24.6576pt/> evaluations but doesn't require us to
> change our code for function evaluation _at all_: we just evaluate it. If
> we're willing to sprinkle some special types on top of our code (but otherwise
> leave in all the sub-routine calls, if statements, for loops, etc.), we could
> use [automatic
> differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation) to
> compute <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/>.
>
> The are two extremes when it comes to autodiff: forward mode and backward
> mode. 
>
> **Forward mode** works like finite differencing, except the perturbation to
> the differentiation variable is symbolic and derivatives are tracked through
> each basic operation (`+`,`-`,`sin`,etc.): the total computational cost to
> construct <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/> is again <img src="svgs/d9fad1122d3ed3c58f6d9342c9260180.svg?invert_in_darkmode&sanitize=true" align=middle width=47.588474999999995pt height=26.76201pt/>.
>
> **Backward mode** works by pushing each function call and basic operation onto
> a list.  Derivatives for all variables are then computed as we pop backward
> through the evaluation: identical to how we read right-to-left on our
> recursive kinematics formula. This means we compute derivatives with respect
> to all variables <img src="svgs/41f28962986ecdd9c1dc2af8b83fef84.svg?invert_in_darkmode&sanitize=true" align=middle width=9.189509999999999pt height=14.61207pt/> in a single _backwards_ evaluation. The total cost is
> only <img src="svgs/5e12273846712182a9633dc4c62b94f7.svg?invert_in_darkmode&sanitize=true" align=middle width=40.213964999999995pt height=24.6576pt/> to fill <img src="svgs/4b89c22bc825ade97f0e007ade8f761b.svg?invert_in_darkmode&sanitize=true" align=middle width=9.77163pt height=22.557149999999996pt/>. 
>

#### Line Search

Whether we're using gradient descent, Newton's method or Gauss-Newton, we a
generally _attempting_ improving our guess by iteratively moving in a descent
direction <img src="svgs/0f0383e9a0c12009f46abaadace3108c.svg?invert_in_darkmode&sanitize=true" align=middle width=22.88814pt height=22.46574pt/>, followed by projecting onto constraints:

<p align="center"><img src="svgs/0ec8258ea51b223aa975915910f5f3de.svg?invert_in_darkmode&sanitize=true" align=middle width=134.006565pt height=16.438356pt/></p>

Despite our best efforts, this step is not guaranteed to actually decrease
our energy <img src="svgs/84df98c65d88c6adf15d4645ffa25e47.svg?invert_in_darkmode&sanitize=true" align=middle width=13.08219pt height=22.46574pt/>. We can think of the descent _direction_ <img src="svgs/0f0383e9a0c12009f46abaadace3108c.svg?invert_in_darkmode&sanitize=true" align=middle width=22.88814pt height=22.46574pt/> as defining a line (or really
a _ray_) and we'd like to find a positive amount <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/> to move along this line that actually
does decrease the energy:

<p align="center"><img src="svgs/1ca721bb236bc9eac6f1c5ec58939490.svg?invert_in_darkmode&sanitize=true" align=middle width=192.07154999999997pt height=16.438356pt/></p>

While there exists an optimal step <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/>, we don't want to spend too long finding
it as we would be better off spending our computational efforts improving the
descent _direction_ for the next step. So, starting with a large value <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/>
(e.g., 10,000), we decrease <img src="svgs/7aed918aa12a276a602e30e90b0b109d.svg?invert_in_darkmode&sanitize=true" align=middle width=9.982994999999999pt height=14.15535pt/> by a constant factor (e.g., <img src="svgs/2eacd907c22e9ad1db070a00eef0f2cd.svg?invert_in_darkmode&sanitize=true" align=middle width=6.552644999999999pt height=27.775769999999998pt/>) until our
inequality passes.

Depending on the configuration, it may or may not be possible to exactly satisfy
the constraints (i.e., <img src="svgs/714ba8178989415a28bbb031a6144c0b.svg?invert_in_darkmode&sanitize=true" align=middle width=43.21911pt height=22.46574pt/>). But after many iterations, the solution should
converge to a [local minimum](https://en.wikipedia.org/wiki/Maxima_and_minima)
(i.e., <img src="svgs/49b56b61879620cabceffb019733f6f5.svg?invert_in_darkmode&sanitize=true" align=middle width=43.21911pt height=22.46574pt/>, but <img src="svgs/445f6c51de634201dfa36e3e70c305ce.svg?invert_in_darkmode&sanitize=true" align=middle width=77.73958499999999pt height=24.6576pt/>). In our assignment, a thin line will appear if
the user-given constraint is not coincident with the end-effector tip position.

![](images/knight-dab.gif)
 
### Linear Blend Skinning

So far we have only discussed bones floating and moving around in space.
Ultimately, we would like to deform interesting models: for example, animals and
characters. Unlike robots or mechanical objects, the animals tend to deform
smoothly, even near joints: an elbow does not tear into two rigid parts when
bent. Instead, the skin around the elbow stretches and smoothly warps. Skin
closer to the forearm deforms more like the rigid rotation and translation of
the forearm, and likewise the skin near the upper arm deforms like the rigid
upper arm bone. In between, we see a smooth transition or blend.

To approximate this smooth blending quickly on the computer, we begin with a 3D
triangle mesh in its "rest" position. The "rest bones" are embedded inside of
this model. Each vertex <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> of the mesh is assigned a weight <img src="svgs/9982a9d682d08696452d15a2576d80da.svg?invert_in_darkmode&sanitize=true" align=middle width=26.42805pt height=14.15535pt/> for each
bone <img src="svgs/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710483pt height=21.68331pt/> corresonding to how much it is "attached" to that bone on a scale of 0%
to 100%. Generally, if the rest position of the vertex <img src="svgs/57d35b8873c32071acfdc8ff6b851232.svg?invert_in_darkmode&sanitize=true" align=middle width=14.628075pt height=24.20121pt/> is nearer to
a bone <img src="svgs/36b5afebdba34564d884d347484ac0c7.svg?invert_in_darkmode&sanitize=true" align=middle width=7.710483pt height=21.68331pt/> then its weight <img src="svgs/9982a9d682d08696452d15a2576d80da.svg?invert_in_darkmode&sanitize=true" align=middle width=26.42805pt height=14.15535pt/> will be larger. A vertex in the middle of
the elbow may have  a weight of 50% for the upper arm and 50% the forearm and
0% for all other bones (toes, fingers, legs, spine, etc.).

Smoothly varying weights produce a smooth deformation. In constrast,
piecewise-constant weights lead to a piece-wise rigid deformation.

![](images/beast-weights.gif)

The "pose" position <img src="svgs/5474c8baa2bc6feabb0eac4237772aab.svg?invert_in_darkmode&sanitize=true" align=middle width=14.628075pt height=14.61207pt/> of this vertex <img src="svgs/77a3b857d53fb44e33b53e4c8b68351a.svg?invert_in_darkmode&sanitize=true" align=middle width=5.663295pt height=21.68331pt/> will be computed as a weighted
average or linear combination of each bone's pose transformation <img src="svgs/cf88dd7d2caab71d7d04c50df09687a9.svg?invert_in_darkmode&sanitize=true" align=middle width=19.25517pt height=22.557149999999996pt/> applied
to the vertex's rest position <img src="svgs/57d35b8873c32071acfdc8ff6b851232.svg?invert_in_darkmode&sanitize=true" align=middle width=14.628075pt height=24.20121pt/>:

<p align="center"><img src="svgs/dfde9dc786b8138fcbdba5029eb4f174.svg?invert_in_darkmode&sanitize=true" align=middle width=181.8795pt height=59.178735pt/></p>

> **Question:** What happens to per-vertex normals after applying a skinning
> deformation?
>
> **Hint:** 🤯

Linear blend skinning has many defects. Good "rigging artists" can mitigate
these by carefully painting (yes, painting) weight functions and position the
[rest bones][2.restbone]. However, some of the linear blend skinning defects are
theoretical: most notably problems that occur by averaging
rotations as matrices. 

> **Question:** What transformation matrix do you get if you compute: <img src="svgs/756285da3ecfc8e56dc7f53510fc54ff.svg?invert_in_darkmode&sanitize=true" align=middle width=170.36943pt height=27.775769999999998pt/>?
>
> **Hint:** It's not <img src="svgs/d3b817835ae8683319cc3ad05d622305.svg?invert_in_darkmode&sanitize=true" align=middle width=51.01602pt height=24.6576pt/>.

## Tasks

### White List

 - `Eigen::Affine3d`
 - [`Eigen::AngleAxis`](https://eigen.tuxfamily.org/dox/classEigen_1_1AngleAxis.html)
 - `#include <Eigen/Geometry>`
 - c++ lambda functions and capturing `#include <functional>`

### Black List

 - `igl::lbs`
 - `igl::forward_kinematics`

### `src/euler_angles_to_transform.cpp`

### `src/forward_kinematics.cpp`

### `src/transformed_tips.cpp`

### `src/catmull_rom_interpolation.cpp`

### `src/linear_blend_skinning.cpp`

### `src/copy_skeleton_at.cpp`

### `src/end_effectors_objective_and_gradient.cpp`

### `src/kinematics_jacobian.cpp`

### `src/projected_gradient_descent.cpp`

### `src/line_search.cpp`

[eulerangles]: https://en.wikipedia.org/wiki/Euler_angles

> ## Notes for TAs editing the README
>
> This README file is too complex for [texify](https://github.com/apps/texify) to render. Use [readme2tex](https://github.com/leegao/readme2tex) locally to render the TeX to SVGs.
>
> `python -m readme2tex --output README.md README.tex.md --nocdn`
> 
> `sed -i 's/invert_in_darkmode\"/invert_in_darkmode\&sanitize=true\"/g' README.md`
