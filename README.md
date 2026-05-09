# Climber and diver metrics for posets

This file provides a set of SageMath functions for computing the climber and diver distances between elments in finite posets as well as the calculation of the shortest path in this context. These metrics are introduced in the article

> Olave A. A. "A new family of distances over partially ordered sets".

## Usage

To load the functions to your SageMath session, ensure that you are working in the same directory as the file `functions.sage`, and then run

```SageMath
load('functions.sage')
```
Given a poset `P` from the class `sage.combinat.posets.posets.FinitePoset` use the function k_distance to calculate any distance from the family of climber and diver metrics. 

```SageMath
## Create a random set of 10 elements
set_random_seed(1)  # Results are reproducible
P = posets.RandomPoset(10, 0.3)
P
```
![Poset example](figs/poset.png) 





