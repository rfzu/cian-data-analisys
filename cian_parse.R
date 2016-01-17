cian_parse <- function(id = 1:283) {
  
  path = paste('~/Documents/code/cian-data-analisys/cian_3/cian_', formatC(1:283,flag='0'),'.csv', sep='')
  data <- c()
  for(i in id) {
    if (file.exists(path[i])) {
      conn <- file(path[i],'r')
      data_set <- read.csv(conn, sep=';')
      close(conn)
      data <- rbind(data, data_set)
    }
  }
  
  data
}

calc_cian <- function(id = 1:283) {
  data3 <- list()
  
  for(i in id){
    name <- levels(data$метро)[i]
    if(is.na(name)) {}
    else {
      price_q10 <- as.numeric(quantile(data$цена[data$метро == name], probs = seq(0, 1, 0.1))[2])
      price_min <- min(data$цена[data$метро == name])
      price_max <- max(data$цена[data$метро == name])
      price_mean <- mean(data$цена[data$метро == name])
      price_median <- median(data$цена[data$метро == name])
      count <- nrow(data[which(data$метро == name),])
      data3 <- rbind(data3, c(name, price_min, price_q10, price_median, price_mean, price_max, count))
    }
  }
  data3
}

data <- cian_parse(id = 1:283)
data$price_per_m <- data$цена / data$площадь
result <- calc_cian(id = 1:283)
write.csv(result, sep=';', file= 'result.csv')