setwd('./')
require('caret')
library(doMC)
registerDoMC(cores = 5)

prep.data <- function(data) {
  #clean the data
  keeps = c(
    "shot_made_flag"
    # , "period"
    , "season"
    # , "playoffs"
    , "shot_distance"
    # , "shot_zone_range"
    , "shot_zone_basic"
    , "shot_zone_area"
    # , "shot_type"
    , "combined_shot_type"
    , "away"
  )

  # casting
  data$shot_made_flag <- as.factor(data$shot_made_flag)
  levels(data$shot_made_flag) <- c("Miss", "Make")

  data$playoffs <- as.factor(data$playoffs)
  levels(data$playoffs) <- c(F, T)

  data$shot_distance <- log10(data$shot_distance + 1)

  # engineer features
  data$away <- grepl('@', data$matchup)

  # filter to necessary columns
  data <- data[,(colnames(data) %in% keeps)]

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
    method="rf"
  )
}

evaluate.feature.importance <- function(model) {
  # estimate variable importance
  importance <- varImp(model, scale=T)
  # summarize importance
  print(importance)
  # plot importance
  plot(importance)
}

recursive.feature.elimination <- function(data) {
  # see: http://machinelearningmastery.com/feature-selection-with-the-caret-r-package/

  writeLines("\n\nStarting Feature Selection\n\n")

  prepped <- prep.data(data)

  control <- rfeControl(functions=rfFuncs, method="cv", number=10)

  results <- rfe(
    prepped[,!(colnames(prepped) %in% c('shot_made_flag'))],
    prepped$shot_made_flag,
    sizes = c(1:(ncol(prepped) - 1)),
    rfeControl = control
  )

  print(results)

  print(predictors(results))
}

sandbox <- function(data) {
  writeLines("\n\nSandbox Mode!!!\n\n")

  sampleIndices <- sample(1:nrow(data), 1000)
  data <- data[sampleIndices,]

  recursive.feature.elimination(data)

  # evaluate.feature.importance(model)

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

# useful for R Studio
prepped <- prep.data(data.train)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 1) {
  if (args[1] == "production") {
    production(data.train, data.test)
  } else {
    sandbox(data.train)
  }
}
