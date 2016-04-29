setwd('./')
require('caret')
require('mice')

prep.data <- function(data) {
  #clean the data
  keeps = c( "FIELDS" )

  # column transformations

  # engineer features

  # filter to necessary columns
  data <- data[,(colnames(data) %in% keeps)]

  # missing value munging
  data <-
    complete(
      mice(
        data,
        m = 5,
        meth = 'pmm',
        printFlag = F
      )
      , 1
    )

  data
}

evaluate.model <- function(model, test.data) {
  predictions <- predict(model, prep.data(test.data))
  print(confusionMatrix(model))
  print(model$results)
}

train.model <- function(train.data) {
  train.control <- trainControl(
    method = "cv",
    number = 10,
    savePredictions = TRUE
  )

  train(
    shot_made_flag ~ .,
    data = prep.data(train.data),
    trControl=train.control,
    method="ranger"
  )
}

recursive.feature.elimination <- function(data) {
  # see: http://machinelearningmastery.com/feature-selection-with-the-caret-r-package/

  writeLines("\n\nStarting Feature Selection\n\n")

  prepped <- prep.data(data)

  control <- rfeControl(functions=rfFuncs, method="cv", number=10)

  results <- rfe(
    prepped[,!(colnames(prepped) %in% c('TargetClass'))],
    prepped$TargetClass,
    sizes = c(1:(ncol(prepped) - 1)),
    rfeControl = control
  )

  print(results)

  print(predictors(results))
}

sandbox <- function(data) {
  writeLines("\n\nSandbox Mode!!!\n\n")
  print(summary(data))
  # recursive.feature.eli mination(data)
  # model <- train.model(data)
  # evaluate.model(model, data)
}

production <- function(train.data, test.data) {
  writeLines("\n\nProduction Mode !!!\n\n")

  data.test  <- prep.data(test.data)
  model      <- train.model(train.data)

  evaluate.model(model, train.data)

  predictions <- predict(model, data.test)

  output.file <- as.data.frame(as.matrix(predictions))

  # clean up output file

  writeLines('\n\nOutput is ready at production.csv\n\n')
  write.csv(output.file, file = 'production.csv', row.names = F)
}

# run code
data       <- read.csv('data.csv', header = T)
data.train <- data[!is.na(data['shot_made_flag']), ]
data.test  <- data[is.na(data['shot_made_flag']), ]

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 1 && args[1] == "production") {
  production(data.train, data.test)
} else {
  sandbox(data.train)
}
