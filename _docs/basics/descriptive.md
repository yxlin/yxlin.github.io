---
title: Descriptive Statistics
category: Modelling Basics
order: 3
---

In most RT modelling work, researchers usually want to examine the manifested
statistics.  Often, these are the average response times (RTs) and accuracy rates.
In the following, I used a model not yet fully implemented here,
LNR (Heathcote & Love, 2012), as an example to illustrate a method in _R_ to
calculate these statistics efficiently. The user wishes to understand and
apply LNR model on her / his work can find useful information in the DMC tutorials
(Heathcote et al., 2018). Because LNR is not computationally intensive, I
have yet fully implemented it here.

This LNR model presumes one stimulus (S) factor, and similar to the LBA model, it
has a latent matching (M) factor.


```
library(data.table); library(ggdmc)

model <- BuildModel(
  p.map     = list(meanlog = "M", sdlog = "M", t0 = "1", st0 = "1"),
  match.map = list(M = list(left = "LEFT", right = "RIGHT")),
  factors   = list(S = c("left", "right")),
  responses = c("LEFT", "RIGHT"),
  constants = c(st0 = 0),
  type      = "lnr")
```


The arbitrary chosen true parameters generate a reasonable RT distribution,
which similar with typical choice RT data, giving approximately 25% errors
(I will show you this later).

```
p.vector <- c(meanlog.true = -1, meanlog.false = 0, sdlog.true = 1,
              sdlog.false = 1, t0 = .2)
```

_simulate_ function takes the first option, _model_ to generate data
based on the provided model. _ps_ option expects a true parameter vector that
matches the setting in the model object, _nsim_ option expects the number of
trial per condition.

```
dat <- simulate(model, ps = p.vector, nsim = 1024)
d <- data.table(dat)
##           S     R        RT
##    1:  left  LEFT 0.3821405
##    2:  left  LEFT 0.7859101
##    3:  left  LEFT 0.5237262
##    4:  left RIGHT 0.3932804
##    5:  left  LEFT 0.6604592
##   ---                      
## 2044: right RIGHT 0.7342084
## 2045: right RIGHT 1.3628130
## 2046: right RIGHT 0.3343844
## 2047: right RIGHT 0.4913930
## 2048: right RIGHT 0.6119065
```
- S is the stimulus factor
- R is the response type
- RT stores response time in second

By using  _data.table_ function **.N**, I confirmed that each condition
does has 1024 trials.

> d[, .N, .(S)]
```
##        S    N
## 1:  left 1024
## 2: right 1024
```

A similar syntax, with S and R factors, I printed out the information
regarding the hit, correct rejection, false alarm and miss responses.
> d[, .N, .(S, R)]
```
##        S     R   N  ## assuming the left is signal and right is noise
## 1:  left  LEFT 791  ## hit
## 2:  left RIGHT 233  ## miss
## 3: right RIGHT 786  ## correct rejection
## 4: right  LEFT 238  ## false alarm
```

I used a ifelse chain to calculate a C column to indicate correct (TRUE)
and error (FALSE) responses. In real world data, there would be some
responses missing or participants pressing wrong keys, so the last else
is "NA" to catch these situations.

```
d$C <- ifelse(d$S == "left"  & d$R == "LEFT",  TRUE,
       ifelse(d$S == "right" & d$R == "RIGHT", TRUE,
       ifelse(d$S == "left"  & d$R == "RIGHT", FALSE,
       ifelse(d$S == "right" & d$R == "LEFT",  FALSE, NA))))
```

The data table now looks like below.
```
##           S     R        RT     C
##    1:  left  LEFT 0.3821405  TRUE
##    2:  left  LEFT 0.7859101  TRUE
##    3:  left  LEFT 0.5237262  TRUE
##    4:  left RIGHT 0.3932804 FALSE
##    5:  left  LEFT 0.6604592  TRUE
##   ---                            
## 2044: right RIGHT 0.7342084  TRUE
## 2045: right RIGHT 1.3628130  TRUE
## 2046: right RIGHT 0.3343844  TRUE
## 2047: right RIGHT 0.4913930  TRUE
## 2048: right RIGHT 0.6119065  TRUE
```


This is one way to calculate average RTs with data.table.
```
d[, .(MRT = round(mean(RT), 2)), .(C)]
##        C  MRT
## 1:  TRUE 0.61
## 2: FALSE 0.71
```

The syntax to calculate the response proportions, namely correct and
error rates, are less straightforward, but possible. Firstly, I
calculated the counts for hit, correct rejection, miss, and false
alarm and store them in _prop_. Then I made up a new column, called _NN_, to store
the total number of trial. Lastly, I divided the four conditions by
the total number of trial. I also used a _round_ to print only to the
two decimal place below zero.

```
prop <- d[, .N, .(S, R)]
prop[, NN := sum(N), .(S)]
prop[, acc := round(N/NN, 2)]
prop
##        S     R   N   NN  acc
## 1:  left  LEFT 791 1024 0.77
## 2:  left RIGHT 233 1024 0.23
## 3: right RIGHT 786 1024 0.77
## 4: right  LEFT 238 1024 0.23
```

## Real-world Example
In this section, I will demonstrate advanced data processing techniques, using an
empirical data (Holmes, Trueblood & Heathcote (2016). This data set can be downloaded
from my [OSF site](https://osf.io/p4pdh/).

One raw data format often found in an psychological experiment is one subject per file
(*.txt or *.csv). For example, the file, "S125.2014-04-23_6-22-36.txt", stores the data
from participant, **S125**. There are 47 of them. All are in the same format. Later, I
will illustrate how to handle similar but not identical formatted data files.

```
block	trial	target	 CO1	CO2	ST	resp	RT	correct
    1	    1	     R    50	 -1	-1	   1   1076       1
    1	    2	     L    50	 -1	-1	   0    733       1
    1	    3	     R    50	 -1	-1	   1    637       1
    1	    4	     R    50	 -1	-1	   1    517       1
...
	
```

I stored data files in a standard location of usual R packaging. The
folder, named _data_ unsurprisingly, immediately in a project folder. And the
analysis scripts are stored in a folder, called _R_. I then used
_list.files_ function to store all file names in a object, called _fn_.

```
?list.files
dp <- "data/Holmes_etal_CogPsych_2016_Data";  ## data path
fn <- list.files(dp, pattern = "*.txt")       ## file name
print(fn)
##  [1] "S125.2014-04-23_6-22-36.txt"           
##  [2] "S126.2014-04-23_6-25-38.txt"           
##  [3] "S127.2014-04-23_6-26-46.txt"           
## ...
## [45] "S169.2014-05-07_6-16-49.txt"           
## [46] "S170.2014-05-07_6-18-16.txt"           
## [47] "S171.2014-05-07_6-38-56.txt"
```

Next I created a _DTLapply_ function to pipe the text files one after another to
the _fread_ of data.table to quickly process them. 

```
function(fn, dp) {
    v <- lapply(seq_along(fn), function(i) {
       s <- strsplit(fn[i], split = "[.]")[[1]][1]
       d <- data.table::fread(file.path(dp, fn[i]))
       S <- d$target
       R  <- d$resp
       RTSec <- d$RT / 1e3
       C  <- d$correct
       return(d[, c("s", "S", "R", "RT", "C") := list(s, S, R, RTSec, C)])
    })
    return(data.table::rbindlist(v))
}

x0 <- DTLapply(fn, dp)
```

**seq_along** function will convert _fn_, which store 47 file name strings to
numerical indices, for the looping.

```
seq_along(fn)
 [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
[26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
```

**function(i)** inside the _lapply_ function is an anonymous function, namely
a function used internally by the _lappy_ function. Inside this anonymous function is
basically a quicker R for loop. The first line in the anonymous function is to extract
the label for a participant. For example, if I just processed the first text file,
the _strsplit_ function split the string whenever it finds a dot symbol **.**.
Because _strsplit_ returns an R list, I took the first element in the first list.

```
print(fn[1])
## [1] "S125.2014-04-23_6-22-36.txt"

strsplit(fn[1], split = "[.]")
## [[1]]
## [1] "S125"               "2014-04-23_6-22-36" "txt"

s <- strsplit(fn[i], split = "[.]")[[1]][1]
print(s)
## [1] "S125"
```

Next line uses the convenient function, _file.path__ in R base to construct
a file path to a particular file. For example, if I extract the first participant.

```
dp <- "data/Holmes_etal_CogPsych_2016_Data";  ## data path
file.path(dp)
## [1] "data/Holmes_etal_CogPsych_2016_Data"
file.path(dp, fn[1])
## [1] "data/Holmes_etal_CogPsych_2016_Data/S125.2014-04-23_6-22-36.txt"
```

The function, _file.path_ returns the complete relative file path to the data file, which
is then read by the _fread_ function.

```
d <- data.table::fread(file.path(dp, fn[1]))
##       block trial target CO1 CO2  ST resp   RT correct
##    1:     1     1      R  50  -1  -1    1 1076       1
##    2:     1     2      L  50  -1  -1    0  733       1
##    3:     1     3      R  50  -1  -1    1  637       1
##    4:     1     4      R  50  -1  -1    1  517       1
##    5:     1     5      L  50  -1  -1    0  476       1
##   ---                                                 
## 1276:    20    68      L  15  -1  -1   -1   -1       1
## 1277:    20    69      L  15  -1  -1    0 1077       0
## 1278:    20    70     LR  15  15 529    0 1463       1
## 1279:    20    71      L  15  -1  -1    0 1895       0
## 1280:    20    72     LR  15  15 529    0 1311       1
```

The following four lines were simply convert the original column names to my factor
naming convention. For example, _target_ column indicates whether a stimulus was
right, left, left and right, or right and left moving dot, so I converted it to as
stimulus, namely _S_ factor. Similarly, R factor is from the _resp_ response column,
RT column was converted to second, and _correct_ column was converted to _C_.

```
S     <- d$target
R     <- d$resp
RTSec <- d$RT / 1e3
C     <- d$correct
```



## To be continue..

## Reference
Heathcote A., and Love J. (2012) Linear deterministic accumulator models of simple choice.
   frontiers in Psychology, 23. https://doi.org/10.3389/fpsyg.2012.00292.

Holmes, W.R. et al, A new framework for modeling decisions about changing
   information: The Piecewise Linear Ballistic Accumulator model”, 2015,
   _Cognitive Psychology_ 85, 1-29.
