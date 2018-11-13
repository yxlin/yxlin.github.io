---
title: Bayes' Theorem
category: Bayesian Basics
order: 1
---

How do we reach decisions to act on something?  One way to answer this question is
the action driven by a decision would bring positive feedback.
The feedback is often accompanied by monetary or other forms of rewards;
thereby motivates us to make such decisions in the future. In
psychological research, the feedback is usually shown in the form of data,
which are collected from human and/or animal subjects.  In other words, the
theories (our _prior beliefs_) behind every decision that entails an
action (_prediction_) resulting in _data_ affect us. How?
Often the closer our prediction matches the resultant data, the more rewards we
might receive.  Hence when there are some mismatches between the predictions
and the data, we would likely modify our theories/beliefs. They then become
_posterior belief_. This intuitive idea of human decision-making is
described by the well-known Bayes' theorem (Bayes, Price, & Canton, 1763):

$$
\begin{align*}
& P(\theta | y) = \frac{P(y | \theta) P(\theta)}{P(y)}
\end{align*}
$$


$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$

1. **y** represents data. For example, a serial of response times in seconds,
c(0.533, 0.494, 0.494, ...);
2. **&theta;** represents a set of parameters. That is, it is a parameter
vector;
3. **P(&theta;)** represents our _prior belief_ in the form of a probability
distribution, which is fully accounted for the parameter vector. This is
often dubbed the _prior distribution_.
4. **P(y &#124; &theta;)** represents the mechanism accounting for the data.
This is often dubbed (data's) likelihood function.
5. **P(&theta; &#124; y)** represents _posterior belief_, which similar to the prior
belief, is often dubbed the posterior distribution.




