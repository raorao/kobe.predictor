# kobe.predictor

predictor of Kobe Bryant's shot success. Solution for the associated [Kaggle Challenge](https://www.kaggle.com/c/kobe-bryant-shot-selection)

#### to run:

1) make sure Rscript is installed on your computer.
2) navigate to the project's root.
3) download [the required data sets from Kaggle](https://www.kaggle.com/c/kobe-bryant-shot-selection/data) to the current directory.


%o generate the csv suitable for [upload to Kaggle](https://www.kaggle.com/c/kobe-bryant-shot-selection/details/evaluation), type:

```sh
$ Rscript Predictor.R production
```

other acceptable parameters:

* `rfe` will attempt recursive feature elminiation
* `eval` will train a model and print out descriptive statistics on it
* `varimp` will evaluate variable importance
