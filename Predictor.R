setwd('./')
require('caret')
library(doMC)
registerDoMC(cores = 5)

prep.data <- function(data) {
  writeLines("Prepping Data\n")

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
  writeLines("Evaluating Model\n")
  predictions <- predict(model, prep.data(test.data))
  print(confusionMatrix(model))
  print(model$results)
}

train.model <- function(train.data) {
  writeLines("Training Model\n")
  train.control <- trainControl(
    method = "cv",
    number = 10,
    savePredictions = TRUE
  )

  train(
    shot_made_flag ~ .,
    data = prep.data(train.data),
    trControl = train.control,
    method="rf"
  )
}

evaluate.feature.importance <- function(model) {
  writeLines("Evaluating Feature Importance\n")
  importance <- varImp(model, scale=T)
  print(importance)
}

# see: http://machinelearningmastery.com/feature-selection-with-the-caret-r-package/
recursive.feature.elimination <- function(data) {
  writeLines("Starting Feature Selection\n")

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

sandbox <- function(data, cmd) {
  writeLines("Sandbox Mode!!!\n")

  sampleIndices <- sample(1:nrow(data), 1000)
  data <- data[sampleIndices,]

  if (cmd == "rfe") {
    recursive.feature.elimination(data)
  } else if (cmd == "varimp") {
    model <- train.model(data)
    evaluate.feature.importance(model)
  } else if (cmd == "eval"){
    model <- train.model(data)
    evaluate.model(model, data)
  } else {
    writeLines("invalid command provided. see README for options.\n")
  }

}

production <- function(train.data, test.data) {
  writeLines("Production Mode !!!\n")

  data.test  <- prep.data(test.data)
  model      <- train.model(train.data)

  evaluate.model(model, train.data)

  predictions <- predict(model, data.test)

  output.file <- as.data.frame(as.matrix(predictions))

  # clean up output file

  writeLines('\nOutput is ready at production.csv\n')
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
    sandbox(data.train, args[1])
  }
}
