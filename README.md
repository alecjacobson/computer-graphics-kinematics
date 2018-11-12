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
skeleton. The skeleton is a user interface (UI) _metaphor_. A skeleton is a
[tree](https://en.wikipedia.org/wiki/Tree_(data_structure)) of rigid bones, not
unlike the [anatomical bones](https://en.wikipedia.org/wiki/Bone) in a human or
animal.

Each "bone" in the skeleton is really a UI widget for visualizing and
controlling a 3D [rigid
transformation](https://en.wikipedia.org/wiki/Rigid_transformation).

Unlike anatomy where the brain triggers muscles to flex and pull the passive
bones around, the bones of a skeleton rig will define the pose of a shape.

For each bone, we will consider _**three**_ "states".

#### 1. Canonical Bone

The "Canonical Bone" of length $\ell$ lies along the $x$-axis with its "tail" at
the origin $(0,0,0)$, its "tip" at $(\ell,0,0)$. The bone is endowed with an
orientation or [frame](https://en.wikipedia.org/wiki/Moving_frame). This helps
define a canonical _bending_ direction. For example, in this assignment, we will
define bending as rotating about the $z$-axis in the canonical frame. _Twisting_
is accomplished by rotating about the $x$-axis. Composing a twist, bend and
another twist spans all possible 3D rotations. We call the three angles composed
into a rotation this way, [Euler angles][eulerangles] (not to be confused with
the [homophonous](https://en.wiktionary.org/wiki/homophonous) [Oiler
angles](https://upload.wikimedia.org/wikipedia/commons/9/97/Odessa_TX_Oil_Well_with_Lufkin_320D_pumping_unit.gif)).

#### 2. Rest Bone

To assemble a skeleton inside our shape will we map each bone from its
[canonical bone][1.canonicalbone] to its position _and orientation_ in the
undeformed model. Maintaining the rigidity of the bone, this means for each bone
there's a rigid transformation $\hat{\T} = (\hat{\Rot} \quad \hat{\t} ) ∈
\R^{3×4}$ that places its tail and tip to the desired positions in the model. We
use the convention that the "canonical tail" (the origin $(0,0,0)$) is mapped to
the "rest tail" inside the model. This means that the _translation_ part of the
matrix $\hat{\T}$ is simply the tail position, $\hat{\s}∈\R^3$:
$$
\hat{\s} = \T \left(\begin{array}{c}0\\\\0\\\\0\\\\1\end{array}\right) =
\Rot\left(\begin{array}{c}0\\\\0\\\\0\end{array}\right) + \hat{\t} 1 = \hat{\t}.
$$

The bone's
rotation is chosen so that the "canonical tip" $(\ell,0,0)$ maps to the "rest
tip" $\hat{\d} ∈ \R³$:
$$
\hat{\d} = 
\T \left(\begin{array}{c}\ell\\\\0\\\\0\\\\1\end{array}\right) =
\Rot\left(\begin{array}{c}\ell\\\\0\\\\0\end{array}\right) + \hat{\t}.
$$

Typically the "rest tail" of is coincident with the "rest tip" of its
parent (if it exists): 
$$
\hat{\d}_{p} = \hat{\s}.
$$

This still leaves any amount of _twisting_ of the bone. In the canonical frame,
we can think of this as pre-twisting the bone along the canonical $x$-axis.
Clearly, twisting does not effect the ability to map the tail and tip to the
correct position. This twist is _chosen_ so that canonical bending aligns with a
meaningful direction. For example, we may twist a [tibia
(shinbone)](https://en.wikipedia.org/wiki/Tibia) bone so that canonical bending
around the $z$-axis means bending at the
[knee](https://en.wikipedia.org/wiki/Knee).

This rest transformations $\hat{\T}$ _place_ each bone inside the undeformed
shape. They do not measure any deformation of the shape from its original
position. Thus, the _pose_ of each bone will be measured _relative_ to the "rest
bone".

#### 3. Pose Bone

The final state to consider is when a bone is _posed_. That is, mapped to a new
position and orientation from its rest state. 

In general, each rest bone undergoes a rigid transformation $\T ∈ \R^{3×4}$,
composed of a rotation $\Rot ∈ \R^{3×3}$ and a translation $\t∈\R^{3}$, mapping each of its 
rest points $\hat{x} ∈ \R³$ to its corresponding posed postion $\x ∈ \R³$:

$$
\x = \T \hat{\x}.
$$

$\T$ is expressed as a _global_ mapping of any point in the rest reference frame
to its pose position. This makes it convenient for [blending transformations
(see below)][linearblendskinning], but it's not so obvious how to pick coherent
values for $\T$. In particular, we would like each bone to rotate about its
parent's tip, but this position is determined by the parent's pose
transformation $\T_p$, which in turn should rotate about the grandparent's tip
and so on.

### Forward Kinematics

One way to determine the rigid pose transformations $\T_i ∈ \R^{3×4}$ for each
bone $i$ in a skeleton is to aggregate _relative rotations_ $\overline{\R}_i ∈
\R^{3×3}$ between a bone $i$ and its parent bone $p_i$ in the skeletal tree.
The final transformation at some bone $i$ deep in the skeletal tree is computed
via a recursive equation.

For each bone, (reading the effect of transformations _right to left_) we first
_undo_ the map from canonical to rest (i.e., via inverting $\hat{\T}_i$), then
rotate by our relative rotation $\overline{\Rot}_i$, then map back to rest (via
$\hat{T}_i$). With our relative transformation accomplished, we continue _up the
tree_ [recursively](https://en.wikipedia.org/wiki/Recursion_(computer_science))
applying our parent's relative transformation, and our grandparent's and so on:
$$
\T_i = \T_{p_i} 
\left(\begin{array}{c} \hat{\T}_i \\\\ 0\ 0\ 0 \ 1\end{array}\right)
\left(\begin{array}{cccc} \overline{\Rot}_i      & \begin{array}{c}0\\\\0\\\\0\\\\\end{array} \\\\ 0\ 0\ 0 & 1\end{array}\right)
\left(\begin{array}{c} \hat{\T}_i \\\\ 0\ 0\ 0 \ 1\end{array}\right)^{-1}
$$

> **Question:** Does using relative rotations ensure that bone tails stay
> coincident with parent tips?
>
> **Hint:** What do you get if you multiply $\T_i$ and $\hat{\s}_i$?

As a base case, the _root_ transformation can be defined to be the identity (no
transformation) or the rigid transformation placing the object/character
generally into a larger scene.

This has the great advantage that if the entire model is rotated or translated
at the root, the relative transformations still apply correctly. This property
holds locally, too. If bone $i$ controls the [tibia
(shinbone)](https://en.wikipedia.org/wiki/Tibia) and $\Rot_i$ applies a bend at
the knee, then twisting and bending at the parent hip bone will naturally
_compose_ with the knee bend.

It is convenient to express the relative rotations of each bone in the
[canonical frame][1.canonicalbone]. We can utilize canonical twist-bend-twist
rotations (three [Euler angles][eulerangles], $Θ₁,θ₂,θ₃$). Each bone's rotation
is conducted in its canonical frame and then _brought_ through the rest frame
through a change of coordinates:

$$
\T_i 
= 
\T_{p_i} 
\hat{\T}_i
\left(\begin{array}{cccc} \Rot_x(θ_{i3})      & \begin{array}{c}0\\\\0\\\\0\\\\\end{array} \\\\ 0\ 0\ 0 & 1\end{array}\right)
\left(\begin{array}{cccc} \Rot_z(θ_{i2})      & \begin{array}{c}0\\\\0\\\\0\\\\\end{array} \\\\ 0\ 0\ 0 & 1\end{array}\right)
\left(\begin{array}{cccc} \Rot_x(θ_{i1})      & \begin{array}{c}0\\\\0\\\\0\\\\\end{array} \\\\ 0\ 0\ 0 & 1\end{array}\right)
\left.\hat{\T}_i\right.^{-1}
$$
where the matrix $\Rot_w(φ) ∈ \R^{3×3}$ is the rotation by $φ$ degrees around
the $w$-axis.

When implementing a skeleton, it is tempting to use a traditional [tree data
structure](https://en.wikipedia.org/wiki/Tree_(data_structure)) where each node
(bone) contains a list of pointers to its children (other bones).  However, by
the _right-to-left_ reading of the forward kinematics formulae above, it is more
convenient to use a data structure where each node (bone) has a pointer to its
(unique) parent (other bone). This is ridiculously named a [Spaghetti
Stack](https://en.wikipedia.org/wiki/Parent_pointer_tree).

> **Question:** What abstract data-structure is good for ensuring a parent's transformation  $\T_{p_i}$
> are computed before its child's $\T_i$?
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

In this assignment, we will interpolate Euler angles directly. This works well
when only a single angle is changing at a time. However, [Euler angles do not
provide easy movement in every rotational
direction](https://en.wikipedia.org/wiki/Gimbal_lock). Euler angles model
rotations as _twist-bend-twist_. For our canonical bones, bending around the
$z$-axis is easy, but bending around the $y$-axis requires first twisting by
$90°$.

So, for more complex interpolation of rotations, a different representation such
as [quaternions](https://en.wikipedia.org/wiki/Slerp) would be needed. This is
outside the scope of this assignment.

### Inverse Kinematics

In the [forward kinematics][forwardkinematics] model, the final position of the
tip of a finger is determined by setting (manually or via interpolation) the
relative transformations of each joint in the finger, the hand, the elbow, the
shoulder, ... This
[indirect](https://en.wikipedia.org/wiki/Direct_manipulation_interface) control
makes it difficult to achieve basic poses.  Instead, we can treat the problem of
setting relative rotations of internal bones (shoulder, elbow, hand, ...) as an
optimization problem subject to a constraint that the finger goes _directly_
where we want.

Stated mathematically, for a skeleton with $m$ bones, if we create a vector
$\a ∈ \R^{3m}$ stacking all the Euler angles of each bone vertically:
$$\a = \left(\begin{array}{c}
θ_{11} \\\\
θ_{12} \\\\
θ_{13} \\\\
θ_{21} \\\\
θ_{22} \\\\
θ_{23} \\\\
\vdots \\\\
θ_{m1} \\\\
θ_{m2} \\\\
θ_{m3}
\end{array}\right)
$$

then we can ask for the best vector of angles $θ$. Best-ness must be quantified
by an cost/energy/obective-function $E$. This energy is typically first written
with respect to the (global, non-relative) pose positions of certains bones
$\x_b ∈ \R³$ (often the "tip" of a
[leaf](https://en.wikipedia.org/wiki/Tree_(data_structure)#Terminology_used_in_trees)
bone of the skeletal tree, called an [end
effector](https://en.wikipedia.org/wiki/Robot_end_effector)). For example, we 
then we could design our energy to measure the squared distance between the pose
tip $\x_b of some bone $b$ and a desired goal location $\q∈\R³$:

$$
E(\x_b) = ‖\x_b - \q‖².
$$

Using forward kinematics, we can express $\x_b$ and in turn $E$ with respect to
relative rotations: 

$$
\x_b(\a) = \T_b \hat{\d}_b
$$
where $\T_b$ depends on $θ_{b1},θ_{b2},θ_{b2}$ and $\T_{p_b}$ which depends on 
$θ_{p_b1},θ_{p_b2},θ_{p_b2}$. In this way our energy can be written as a
function of $\a$:

$$
E(\x_b(\a)) = ‖\x_b(\a) - \q‖².
$$

We can design arbitrarily complex energies to satisfy our interaction needs. In
this assignment, we consider that there is a list of constrained end effectors
$b = \{b₁,b₂,…,b_k\}$. Our energy will have two terms.

First, for a certain constrained end effector $b_j$ we ask that it lies as close
as possible to the [viewing
ray](https://en.wikipedia.org/wiki/Ray_tracing_(graphics)) through the user's
[mouse pointer](https://en.wikipedia.org/wiki/Pointer_(user_interface)). 
We can measure the distance between some point $\x$ and the line passing
through the camera/eye location $\e$ and the mouse location _unprojected_ onto
its 3D position on the screen placed in the scene at $\m$ using:
$$
E_\text{mouse}(\x) = \left|\left| (\x - \m) - \left((\x - \m)⋅\frac{\e-\m}{‖\e-\m‖}\right)\frac{\e-\m}{‖\e-\m‖}\right|\right|^2.
$$
This formula can be simplified to a much simpler expression since $\m$ and $\e$
do not depend on $\x$ (left to the reader/implementor).


> **Question:** How would you _alternatively_ write this term by measuring
> distances in image space?
>
> **Hint:** 📽
>

Second, for all of the other end effectors $b_i \left|\right. i≠j$, we will
constrain their positions to their rest locations $\hat{\x}_{b_i}$, using the
simple squared distance measure above.

The goal of inverse kinematics is to minimize the sum of these energies over all
choices of $\a$:

$$
\min_{\a} \quad
\underbrace{
E_{\text{mouse}}(\x_{b_j}(\a)) + 
∑\limits_{i≠j} ‖\x_{b_i}(\a) - \hat{\x}_{b_i}‖²
}_{E(\x_b (\a))}
$$

We may further constrain our problem by imposing
[upper and lower bounds](https://en.wikipedia.org/wiki/Constrained_optimization#Inequality_constraints)
on our angles $\a$. These correspond to joint limits. For example, the joint
limits of a hinge or elbow type joint may look like:
$$
0° ≤ θ₁ ≤ 0°, \quad 0° ≤ θ₂ ≤ 170°, \quad 0° ≤ θ₃ ≤ 0°.
$$
These would ensure that our joint cannot twist, and can only bend in one direction.

So our full optimization problem becomes 

$$
\min\_{\a\^{\text{min}} ≤ \a ≤
\a\^{\text{max}}}
\quad E(\x_b(\a))
$$
where $\a^{\text{min}}/\a^{\text{max}}$ stack lower/upper bounds correspondingly to $\a$.


This type of minimization is non-trivial. Our energy is a quadratic [sum of
squares](https://en.wikipedia.org/wiki/Linear_least_squares) in $\x_b$, but
$\x_b$ is a non-linear function of $\a$. In turn, this means to minimize $E$ as
a function of $\a$ we must solve a [non-linear least
squares](https://en.wikipedia.org/wiki/Non-linear_least_squares) problem. 

#### Projected Gradient Descent

Faced with a bound constrained non-linear optimization problem, an immediate
idea is to construct an initial guess and then iteratively improve the guess by
moving in a direction that decreases $E$, after each step _snap_ or project the
guess to stay within the bounds if necessary. This algorithm is called
_projected gradient descent_.

The idea behind gradient descent is intuitive: if you want to get to the bottom
of a canyon, look at the ground and walk in the direction that goes downhill.

So, we iteratively take a step in the _negative_ gradient direction.

$$
\a ← \a - σ \left(\frac{dE(\a)}{d\a}\right)^T
$$

Applying the [chain rule](https://en.wikipedia.org/wiki/Chain_rule), this
iteration becomes

$$
\a ← \a - σ \left(\frac{d\x(\a)}{d\a}\right)^T\left(\frac{dE(\x)}{d\x}\right)
$$

where $\frac{dE}{d\a} ∈ \R^{|\a|}$,
$\frac{dE}{d\x} ∈ \R^{|\x|}$, and $\frac{d\x}{d\a} ∈ \R^{|\x| × |\a|}$

The change in tip positions $\x$ with respect to joint angles $\a$ does not
depend on the choice of energy $E$. We call this matrix of changes the kinematic
[Jacobian](https://en.wikipedia.org/wiki/Jacobian_matrix_and_determinant), $\J ∈
\R^{|\x| × |\a|}$:


$$
\J = \frac{d\x}{d\a}.
$$

Written in terms of $\J$ our step becomes,

$$
\a ← \a - σ \J^\transpose\left(\frac{dE(\x)}{d\x}\right)
$$

> **Question:** Can we take an arbitrarily large step $σ>>0$?
>
> **Hint:** What if we just need to change $\a$ by a small, non-zero amount?
> What would chooing $σ=1,000,000$ do to $\a$? What would that in turn do to
> $E(\x(\a))$?

For sufficiently small $σ$, each step will decrease the objective energy $E$.

If the gradient of $E$ becomes zero, then we're at a [stationary
point](https://en.wikipedia.org/wiki/Stationary_point) and likely at a minimum.

To ensure that our bounds are obeyed, after each step we need to _project_ onto
our constraints by snapping each value to its respective bound if necessary:

$$
\a\_i ← \max[\a\^\text{min}_i, \min[\a\^\text{max}\_i,\a\_i]].
$$

We'll refer to this as a projection filter acting on the entire vector $\a$:

$$
\a ← \text{proj}(\a).
$$


> #### Newton's method
> 
> The local gradient of a function can be very different from the "best" descent
> direction. The choice of $σ$ reflects how much we "trust" this direction.
> Unfortunately, if $σ$ is too large our iterations may diverge. If $σ$ is too
> small, we will have to do many iterations.
> 
> In order to find a _better_ descent direction, let's assume we knew _more_ about
> $E$. That is, suppose we also knew its second derivatives: $\frac{d²E}{d\x²}$. 
> 
> Given an initial guess $\x⁰$ we're looking to find a change $∆\x$ so that $E(\x⁰
> + ∆\x)$ is a stationary point.
> 
> Starting with our equilibrium equation,
> $$
> \frac{dE(\x)}{d\x} = \0
> $$
> 
> we substitute in $x = \x⁰ + ∆\x$
> 
> $$
> \frac{dE(\x⁰+∆\x)}{d∆\x} = \0
> $$
> 
> Plugging in a [Taylor series](https://en.wikipedia.org/wiki/Taylor_series)
> expansion
> 
> $$
> E(\x⁰+∆\x) \approx E(\x⁰) + \frac{d E(\x⁰+∆\x)}{d\x} ∆\x +
> \frac{d²E(\x⁰+∆\x)}{d\x²}\frac{(∆\x)²}{2} + …$$
> 
> and dropping higher order terms ($…$), we get:
> 
> $$
> \frac{d}{d∆\x}(E(\x⁰) + \frac{d E(\x⁰+∆\x)}{d\x} ∆\x + \underbrace{\frac{d²E(\x⁰+∆\x)}{d\x²}}_\H\frac{(∆\x)²}{2}) = \0,
> $$
> where we call $\H ∈ \R^{|x| × |x|}$ the [Hessian
> matrix](https://en.wikipedia.org/wiki/Hessian_matrix).  
> 
> Applying the differentiation by $∆\x$ we get a system of equations:
> 
> $$
> \frac{d E(\x⁰+∆\x)}{d\x} + \frac{d²E(\x⁰+∆\x)}{d\x²} ∆\x = \0.
> $$
> Solving for the change $∆x$ we get:
> $$
> ∆x = -\left.\H\right.^{-1} \frac{d E(\x⁰+∆\x)}{d\x}.
> $$
> 
> So a _raw_ Newton's method update would be:
> 
> $$
> \x ← \x - \left.\H\right.^{-1} \frac{d E(\x⁰+∆\x)}{d\x}.
> $$
> 
> If our Taylor series approximation was perfect (no high order terms in $…$; in
> otherwords $E$ was quadratic), then Newton's method would be perfect: a single
> update immediately takes us to the minimum.
> 
> Newton's method is problematic for a number of reasons.
> 
>  1. We built our step purely based on the equations for a stationary point.
>     Nothing says we won't get sent toward a maximum or saddle-point. 
>  2. $\H$ is often difficult or expensive to compute.
>  4. $\H$ may be singular.
>  3. Inverting $\H$ (even if possible) is often slow.
>  5. Our system is built off a local approximation of $E$ so the descent
>     direction may _still_ point in the wrong direction.
> 
> Since we're approximating $E$ at every iteration anyway, we'll skirt many of
> these issues by considering various approximations of the Hessian matrix $\H$.
> We'll never actually compute $\H$.
> 
> #### Gradient Descent _Revisited_
> 
> The simplest approximation of $\H$ is the identity matrix $\I$. Plugging this
> into our truncated Taylor series expansion above, our approximation would read:
> 
> $$
> E(\x⁰) + \frac{d E(\x⁰+∆\x)}{d\x} ∆\x + \I \frac{(∆\x)²}{2}.
> $$
> 
> and our step reduces to good ol' gradient descent:
> 
> $$
> \x ← \x - \frac{d E(\x⁰+∆\x)}{d\x}.
> $$
> 
> #### Gauss-Newton
>
> Given that we have already computed first derivatives in the Jacobian $\J
> =\frac{d\x(\a)}{d\a}$, an even better approximation for Hessian $\H$ than the
> identity $\I$ would be to use $\J^\transpose J$. The resulting update becomes:
>
> $$
> \a ← \a + (\left.\J\right.^\transpose\J)^{-1} \left.\J\right.^\transpose \frac{dE(\x)}{d\x}
> $$
>
> Unlike $\H$, $\J^\transpose\J$ is easy to compute if we're already computing
> $\J$. It is guaranteed to be [positive
> semi-definite](https://en.wikipedia.org/wiki/Positive-definite_matrix) and it
> is possible to invert or reliably
> [pseudo-invert](https://en.wikipedia.org/wiki/Moore–Penrose_inverse) ($\J^+$
> acting in place of $(\left.\J\right.^\transpose\J)^{-1}
> \left.\J\right.^\transpose$).
>
> The descent directions are often significantly better than gradient descent.
> As a result this method, called Gauss-Newton, requires many fewer iterations
> to converge.
>
> It still may try to descend in bad directions. In particular, for inverse
> kinematics, this Gauss-Newton method performs poorly if the desired positions
> are not reachable: over extending an arm. First the solution locks in place
> and then diverges. This happens when our Hessian approximation
> $\J^\transpose\J$ starts misbehaving.
>
> A good fix is to blend between the gradient descent and Gauss-Newton search
> directions. That is blend between $\I$ and $\J^\transpose\J$. This is called
> the [Levenberg-Marquadt
> algorithm](https://en.wikipedia.org/wiki/Levenberg–Marquardt_algorithm).


#### Finite Differencing

But how do we compute the kinematic Jacobian $\J$? Since each entry in $\x$ is
the result of forward kinematics and not just a math expression, it's not
immediately obvious how to determine its derivatives. However, a derivative is
nothing more than the limit of a small change output divided by a small change
in the input:

$$
\J_{i,j} = \lim_{h → 0} \frac{\x_i(\a+h δ_j)}{h},
$$
where $δ_j ∈ \R^{|a|}$ is a vector of zeros except a 1 at location $j$.

We can numerically approximate this limit by fixing $h$ to a small value (e.g.,
$h=10^{-7}$). This is called the [finite
difference](https://en.wikipedia.org/wiki/Finite_difference) approximation:
$$
\J_{i,j} \approx  \frac{\x_i(\a+h δ_j)}{h}.
$$

For inverse kinematics, we will need to compute $\x_i(\a+h δ_j)$ once for each
Euler angle of each bone $j$. This requires $3m$ calls to our forward kinematics
function (each with a slightly different input), which is in turn $O(m)$. This
makes the total cost $O(m²)$ to fill in our $\J$ matrix.


>
> #### Automatic Differentiation
>
> Forward differencing requires $O(m)$ evaluations but doesn't require us to
> change our code for function evaluation _at all_: we just evaluate it. If
> we're willing to sprinkle some special types on top of our code (but otherwise
> leave in all the sub-routine calls, if statements, for loops, etc.), we could
> use [automatic
> differentiation](https://en.wikipedia.org/wiki/Automatic_differentiation) to
> compute $\J$.
>
> The are two extremes when it comes to autodiff: forward mode and backward
> mode. 
>
> **Forward mode** works like finite differencing, except the perturbation to
> the differentiation variable is symbolic and derivatives are tracked through
> each basic operation (`+`,`-`,`sin`,etc.): the total computational cost to
> construct $\J$ is again $O(m²)$.
>
> **Backward mode** works by pushing each function call and basic operation onto
> a list.  Derivatives for all variables are then computed as we pop backward
> through the evaluation: identical to how we read right-to-left on our
> recursive kinematics formula. This means we compute derivatives with respect
> to all variables $\a$ in a single _backwards_ evaluation. The total cost is
> only $O(m)$ to fill $\J$. 
>

#### Line Search

Whether we're using gradient descent, Newton's method or Gauss-Newton, we a
generally _attempting_ improving our guess by iteratively moving in a descent
direction $∆\a$, followed by projecting onto constraints:

$$
\a ← \text{proj}(\a + ∆\a).
$$

Despite our best efforts, this direction is not guaranteed to actually decrease
our energy $E$. We can think of the descent direction $∆\a$ as a line (or really
a _ray_) and we'd like to find an amount $α$ to move along this line that actually
does decrease the energy:

$$
E(\text{proj}(\a + α ∆\a)) < E(\a).
$$

While there exists an optimal step $α$, we don't want to spend too long finding
it as we would be better off spending our computational efforts improving the
descent _direction_ for the next step. So, starting with a large value $α$
(e.g., 10,000), we decrease $α$ by a constant factor (e.g., $½$) until our
inequality passes.
 
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
this model. Each vertex $i$ of the mesh is assigned a weight $w_{i,j}$ for each
bone $j$ corresonding to how much it is "attached" to that bone on a scale of 0%
to 100%. Generally, if the rest position of the vertex $\hat{\v}_i$ is nearer to
a bone $j$ then its weight $w_{i,j}$ will be larger. A vertex in the middle of
the elblow may have  a weight of 50% for the upper arm and 50% the forearm and
0% for all other bones (toes, fingers, legs, spine, etc.).

The "pose" position $\v_i$ of this vertex $i$ will be computed as a weighted
average or linear combination of each bone's pose transformation $\T_j$ applied
to the vertex's rest position $\hat{\v}_i$:

$$
\v_i = 
\sum\limits\^{m}_{j=1}
w_{i,j}
\T_j
\left(\begin{array}{c}\hat{\v}_i\\\\1\end{array}\right).
$$

> **Question:** What happens to per-vertex normals after applying a skinning
> deformation?

Linear blend skinning has many artifacts, most notably problems that occur by
averaging rotations as matrices. 

> **Question:** What transformation matrix do you get if you compute: $½ \Rot_x(90°) + ½ \Rot_x(-90°)$?
>
> **Hint:** It's not $\Rot_x(0°)$.

## Tasks


- forward kinematics
- euler angles to matrix
- catmull rom interpolation
- finite difference jacobian
- linear blend skinning
- gradient descent
- line search
- levenberg marquadt

[eulerangles]: https://en.wikipedia.org/wiki/Euler_angles
