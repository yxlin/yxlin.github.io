---
title: Summary Statistics
category: Modelling Basics
order: 3
---

In analyzing response time data with two choices, researchers would usually
examine average response times (RTs) and response proportions.  Depending on
the model a researcher wishes to presume, the response proportions can simply 
be correct and error rates, or, if using SDT model, hits, correct rejections,
false alarms and misses.  Here I used Pleskac, Cesario, and Johnson's (2017)
data in the first-person shooter task (FPST; Correll et al., 2002) to
illustrate one method to calculate average RTs and response proportions
across participants.

Firstly, I use _fread_ function to load the data file, which is in csv
format. The data set provides a very clear and good column names.
That is, the column names have informed the coding method. I simply
just followed column names to code the factor levels and later checked
against the data in the paper. 

- S: stimulus factor, gun vs. non-gun objects.
- BC: blurry or clear object
- CT: context, a safe or dangerous neighborhood
- RACE: race, a black or white target
- R: response factor, shoot or not to shoot
- RT: response times
- s: subject / participant nominal labels

```
library(data.table);
study3 <- fread("data/race/Study3/original/Study3TrialData.csv")
study3$S    <- factor(ifelse(study3$Object0NG1G == 0, "non", "gun"))
study3$BC   <- factor(ifelse(study3$Blurry0Clear1Blur == 0, "clear", "blur"))
study3$CT   <- factor(ifelse(study3$Context1Safe2Danger == 0, "safe", "danger"))
study3$RACE <- factor(ifelse(study3$Race012B == 0, "white", "black"))
study3$R    <- factor(ifelse(study3$Resp0NS1Sh == 0, "not", "shoot"))
study3$RT   <- study3$RT / 1e3
study3$s    <- factor(study3$Subject)
```

After reorganizing the columns, I removed the replicated columns by assigning
them as _NULL_.

```
study3[, c("Subject", "NewSubject", "conditionRaceDangerBlurbject",
"conditionRaceDangerBlur",  "Object0NG1G", "Blurry0Clear1Blur",
"Context1Safe2Danger", "Race012B", "Resp0NS1Sh", "DiffusionRT") := NULL]
```

There are NaN response times in this data set, so I simply replaced them with
random RTs drawn from the range of all valid RTs. This was achieved by using
the **data.table** internal function *.I*.  I firstly found the (row) index of
these NaN RTs, and then replaced them.

```
## save organized data to a temporary object, so I can roll back.
dtmp <- data.table(study3)
minmax <- range(study3$RT, na.rm = TRUE); minmax
idx <- dtmp[, .I[is.nan(RT)]]; idx
dtmp[idx, RT := runif(1, minmax[1], minmax[2])]
d <- dtmp

## scoring a correctness column
d$C <- ifelse(d$S == "gun" & d$R == "shoot", TRUE,
       ifelse(d$S == "non" & d$R == "not",   TRUE,
       ifelse(d$S == "gun" & d$R == "not",   FALSE,
       ifelse(d$S == "non" & d$R == "shoot", FALSE, NA))))
```

Now the data table looks like:

```
dplyr::tbl_df(d)
## # A tibble: 12,033 x 8
##       RT S     BC    CT    RACE  R     s     C
##    <dbl> <fct> <fct> <fct> <fct> <fct> <fct> <lgl>
##  1 0.753 gun   blur  safe  black shoot 11    TRUE
##  2 0.851 non   blur  safe  white not   11    TRUE
##  3 0.742 gun   clear safe  black shoot 11    TRUE
##  4 0.636 non   clear safe  white not   11    TRUE
##  5 0.644 gun   blur  safe  black not   11    FALSE
##  6 0.625 non   clear safe  black shoot 11    FALSE
##  7 0.889 non   clear safe  white not   11    TRUE
##  8 0.597 gun   blur  safe  black shoot 11    TRUE
##  9 0.724 gun   clear safe  white shoot 11    TRUE
## 10 0.656 non   blur  safe  white not   11    TRUE
## # ... with 12,023 more rows

```


### Censoring RT data
Censoring data is often an hard to decide what and how to do.  Here
I illustrated one way to do it via Heathcote's _rc_, a collection of
his useful R functions and my _summarise_, a collection of my
useful R functions.  First, I used R's _source_ function to load
this large collection of R functions.

```
source("~/rc/data.analysis.R")
source("~/rc/utils.R")
source("~/functions/summarise.R")

## Scoring ------------
se3 <- score.rc(data.frame(d), S = "s", R = "R", RT = "RT", SC = "C",
                F = c("BC", "CT", "RACE", "S"))
## Spreading 11851 of 12033 RTs that are ties given preceision 0.001 .
##    497 have ties out of 679 unique values
##
## Added the following manifest design
##      S  RACE     CT    BC     R rcell
## 1  gun black danger  blur   not     1
## 2  gun black danger  blur shoot     1
## 3  gun black danger clear   not     2
## ...
## 30 non white   safe  blur shoot    15
## 31 non white   safe clear   not    16
## 32 non white   safe clear shoot    16

```
_score.rc_ function takes first argument data.frame, which is the data as seen
previously.  Because I stored it as data.table, I needed to convert it back
to data.frame. Just a note. Although data.table may accommodate many functions
operating in data.frame, there are some operations in _rc_ functions, which
cannot work in data.table.

Note the second argument, uppercase *S*, which takes the _subject_ column, instead
of the column of stimulus factor. The *R* and *RT* arguments take response column
and the response time column. *SC* takes the column of score correctness, which
is purely my guess. I cannot be sure why it is called *SC*. The last useful
argument is *F*, which takes user-defined factors, including the stimulus factor.

_score.rc_ detects the identical (ties) RTs and spread them into finer scale.
For example, in this data set, there are 31 trials with 60y ms.

```
table(d$RT)
##             0.01            0.015            0.019            0.025 
##                1                1                1                1 
##            0.027             0.03            0.035            0.036 
##                1                1                1                1 
##    	       ...
##            0.386            0.387            0.388            0.389 
##                7                3                1                3 
##             0.39            0.391            0.392            0.393 
##                1                4                3                3 
##            0.394            0.395            0.396            0.397 
##                2                6                7                3 
##     		   ...
##            0.606            0.607            0.608            0.609 
##               50               31               40               39 
##             0.61            0.611            0.612            0.613 
##               42               49               31               41 
##            0.614            0.615            0.616            0.617 
##               49               55               42               39 
##            ...

```

If I printed them all out, the data set after scoring spreads these
RT to a 

> se3[se3$RT >= .607 & se3$RT < .608,]

```
      cell rcell   s    BC     CT  RACE   S     C     R        RT
539     31    16  19 clear   safe white non  TRUE   not 0.6070000
838     31    16  24 clear   safe white non  TRUE   not 0.6075488
1909    26    13  39  blur danger white non FALSE shoot 0.6070313
2108     6     3  44  blur   safe black gun  TRUE shoot 0.6072812
2321     4     2  50 clear danger black gun  TRUE shoot 0.6079634
2354    19    10  50 clear danger black non  TRUE   not 0.6071250
2939    15     8  62 clear   safe white gun FALSE   not 0.6072188
3083    32    16  62 clear   safe white non FALSE shoot 0.6077683
3319    12     6  72 clear danger white gun  TRUE shoot 0.6075244
3762    19    10  82 clear danger black non  TRUE   not 0.6079146
4802    23    12 120 clear   safe black non  TRUE   not 0.6076951
5211    17     9 129  blur danger black non  TRUE   not 0.6075976
5391    19    10 129 clear danger black non  TRUE   not 0.6074063
6095     1     1 184  blur danger black gun FALSE   not 0.6073125
7057    10     5 201  blur danger white gun  TRUE shoot 0.6077195
7201    17     9 201  blur danger black non  TRUE   not 0.6078659
7288     6     3 214  blur   safe black gun  TRUE shoot 0.6073438
7345    25    13 214  blur danger white non  TRUE   not 0.6071875
7747    23    12 218 clear   safe black non  TRUE   not 0.6077439
8259     8     4 231 clear   safe black gun  TRUE shoot 0.6076707
8305    19    10 231 clear danger black non  TRUE   not 0.6079390
8671    12     6 235 clear danger white gun  TRUE shoot 0.6071563
8923    19    10 247 clear danger black non  TRUE   not 0.6073750
9002    31    16 247 clear   safe white non  TRUE   not 0.6074375
9045    31    16 247 clear   safe white non  TRUE   not 0.6070625
9509    31    16 286 clear   safe white non  TRUE   not 0.6076220
9551    31    16 286 clear   safe white non  TRUE   not 0.6078415
9692     6     3 286  blur   safe black gun  TRUE shoot 0.6075732
9903    27    14 288 clear danger white non  TRUE   not 0.6079878
10432   25    13 307  blur danger white non  TRUE   not 0.6077927
10534   10     5 308  blur danger white gun  TRUE shoot 0.6078902
10666   21    11 308  blur   safe black non  TRUE   not 0.6074688
10979   16     8 325 clear   safe white gun  TRUE shoot 0.6078171
11201    9     5 326  blur danger white gun FALSE   not 0.6070937
11642   19    10 344 clear danger black non  TRUE   not 0.6072500
11866   25    13 348  blur danger white non  TRUE   not 0.6076463

```

The original data set is to the millisecond scale.
> d[RT == .607]

```
       RT   S    BC     CT  RACE     R   s     C
 1: 0.607 gun  blur danger black   not  11 FALSE
 2: 0.607 non  blur danger black   not  19  TRUE
 3: 0.607 non clear   safe white   not  19  TRUE
 4: 0.607 gun  blur   safe black shoot  24  TRUE
 5: 0.607 non clear danger white   not  28  TRUE
 6: 0.607 non clear   safe white   not  37  TRUE
 7: 0.607 non  blur danger white shoot  39 FALSE
 8: 0.607 non  blur danger black   not  44  TRUE
 9: 0.607 gun  blur   safe black shoot  44  TRUE
10: 0.607 non clear danger black   not  50  TRUE
11: 0.607 gun clear danger white shoot  50  TRUE
12: 0.607 gun clear   safe white   not  62 FALSE
13: 0.607 non clear danger black   not 129  TRUE
14: 0.607 gun  blur danger black   not 184 FALSE
15: 0.607 non clear   safe white   not 184  TRUE
16: 0.607 non  blur danger black   not 184  TRUE
17: 0.607 gun  blur   safe black shoot 214  TRUE
18: 0.607 non  blur danger white   not 214  TRUE
19: 0.607 non clear   safe white   not 218  TRUE
20: 0.607 gun clear danger white shoot 235  TRUE
21: 0.607 non clear danger black   not 247  TRUE
22: 0.607 non clear   safe white   not 247  TRUE
23: 0.607 non clear   safe white   not 247  TRUE
24: 0.607 gun clear danger white shoot 288  TRUE
25: 0.607 non  blur   safe black   not 308  TRUE
26: 0.607 non clear   safe white   not 325  TRUE
27: 0.607 gun  blur   safe white shoot 326  TRUE
28: 0.607 gun  blur danger black shoot 326  TRUE
29: 0.607 gun  blur danger white   not 326 FALSE
30: 0.607 non  blur danger black   not 344  TRUE
31: 0.607 non clear danger black   not 344  TRUE
       RT   S    BC     CT  RACE     R   s     C
```


The scored data set, _se3_, will also attach two new columns, _cell_ and _rcell_,
indicating the experimental design.  In this example, it has 32 cell, so
_cell_ is from 1 to 32 and _rcell_ is from 1 to 16, because this is a two-choice
experiment, response, _shoot_ and _not to shoot_ in cell 1 and cell 2, belong to
the same experimental design, but with different response types.

```
## 1  gun black danger  blur   not     1
## 2  gun black danger  blur shoot     1
## 3  gun black danger clear   not     2
## 4  gun black danger clear shoot     2
```

A usual practice is to take 3 times the standard deviation, respectively in each
participants. This can be achieved via _tapply_ function. If the data set is large,
one can use data.table to achieve the same aim, which I will demonstrate in a
later tutorial.

```
sd3 <- tapply(se3$RT, se3$s, mean) + tapply(se3$RT, se3$s, sd) * 3;
```

A second useful function in _rc_ collection is the _make.rc_, which does the censoring
work. It takes a first argument of the scored data set, from _score.rc_ and a
second argument, _correct.name_, indicating the character string for the correctness
column, and the last two arguments, for the lower and upper bounds of the censoring.

```
me3 <- make.rc(se3, correct.name = "C", minrt = .2, maxrt = sd3)
```

## How to average across trials 

- mv: measurement / dependent variable
- gvs: grouping variables
- wvs: within variables

```
acc0 <- summarySE(d, mv = "error", gvs = c("s", "BC", "CT", "RACE", "S"))
mrt0 <- summarySE(d[C == TRUE], mv = "RT",    gvs = c("s", "BC", "CT", "RACE", "S"))
## Within se average across subjects for pc and nt
figA <- summarySEwithin(acc0, wvs = c("BC","CT", "RACE", "S"), mv = "error")
figB <- summarySEwithin(mrt0, wvs = c("BC","CT", "RACE", "S"), mv = "RT")
names(figA) <- c("BC", "CT", "RACE", "S", "N", "y", "sd", "se", "ci")
names(figB) <- c("BC", "CT", "RACE", "S", "N", "y", "sd", "se", "ci")
```

## Reference
