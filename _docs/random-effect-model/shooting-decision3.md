---
title: Shooting Decision Model - Model Selection
category: Hierarchical Model
order: 6
---

One advantage of model fitting is it informs more than just parameter estimations.
In previous two tutorials, I demonstrated one parameter-recovery 
study and one model fitting to the empirical data. The real challenge is to
conduct many hierarchical model fits, which _ggdmc_ is designed to do well, with
the help of parallel computing. The purpose of model selection is to find a best
model accounting for the data. Because one aim of shooting decision study was to
examine whether race stereotypes affects shooting decision, I listed the
model-of-interest below.

1. a ~ 1    & v ~ S
2. a ~ RACE & v ~ S
3. a ~ 1    & v ~ RACE + S
4. a ~ RACE & v ~ RACE + S

Pleskac, Cesario and Johnson's (2017) showed an interesting finding that
their participants appeared to bias (reflected in starting point parameter)
towards not shoot a black target and to increase thresholds (reflected
in the boundary separation parameter) towards a black target. Also their
main findings suggest that research participants is at the decision rate.

The main question is whether the race stereotype is true. In other words,
do people decide to shoot a black target faster than a white target? This
question can be answered by the finding that if models 2, 3, or 4 
account for the data better than model 1. If the finding is negative
(i.e., no difference between models 2, 3, and 4 and model 1), then I can
claim that I do not find evidence to support the race stereotype hypothesis.

A further question continuing on the first one is that:
- do people have a higher decision threshold for a white target than a black target, 
so they decide to shoot a black target quicker? Or,
- do people increase their decision rate for a black target than a white target, 
so they decide to shoot a black target quicker? Or,
- both. People have a higher threshold and a slower rate for a white target than
for a black target?

This question can be answered by comparing the model 2, 3 and 4 to see which one
better accounts for the data. 

A next interesting question is whether people raises their decision
thresholds to a black target, relative to a white target, when deciding shoot or
not shoot a black target, because of the concern of the race stereotype. That is,
if we find model 2 or 4 better accounts for the data, but the decision threshold is
higher for a black target, instead of a white target.

## Reference
Pleskac, T.J., Cesario, J. & Johnson, D.J. (2017). How race affects evidence accumulation during the decision to shoot.
_Psychonomic Bulletin & Review_, 1-30. https://doi.org/10.3758/s13423-017-1369-6
