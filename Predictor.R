setwd('./')
require('caret')
library(doMC)
registerDoMC(cores = 5)

prep.data <- function(data) {
  writeLines("Prepping Data\n")

  #clean the data
  keeps = c(
    "shot_id",
    "shot_made_flag"
    # , "period"
    # , "season"
    # , "playoffs"
    , "shot_distance"
    # , "shot_zone_range"
    , "shot_zone_basic"
    # , "shot_zone_area"
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
  predictions <- predict(model, test.data)
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
    shot_made_flag ~ . -shot_id,
    data = train.data,
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

  control <- rfeControl(functions=rfFuncs, method="cv", number=10)

  results <- rfe(
    data[,!(colnames(data) %in% c('shot_made_flag', 'shot_id'))],
    data$shot_made_flag,
    sizes = c(1:(ncol(data) - 2)),
    rfeControl = control
  )

  print(results)
  print(predictors(results))
}

sandbox <- function(data, cmd) {
  writeLines("Sandbox Mode!!!\n")

  sampleIndices <- sample(1:nrow(data), 1000)
  prepped <- prep.data(data[sampleIndices,])

  if (cmd == "rfe") {
    recursive.feature.elimination(prepped)
  } else if (cmd == "varimp") {
    model <- train.model(prepped)
    evaluate.feature.importance(model)
  } else if (cmd == "eval"){
    model <- train.model(prepped)
    evaluate.model(model, prepped)
  } else {
    writeLines("invalid command provided. see README for options.\n")
  }

}

production <- function(data) {
  writeLines("Production Mode !!!\n")

  data       <- prep.data(data)
  train.data <- data[!is.na(data['shot_made_flag']), ]
  test.data  <- data[is.na(data['shot_made_flag']), ]
  model      <- train.model(train.data)

  evaluate.model(model, train.data)

  predictions <- predict(model, test.data)

  output.file <- as.data.frame(as.matrix(predictions))
  output.file$shot_id <- test.data$shot_id
  levels(output.file$shot_made_flag) <- c(0, 1)

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
    production(data)
  } else {
    sandbox(data.train, args[1])
  }
}
