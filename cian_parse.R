cian_parse <- function(id = 1:159) {

        path = paste('~/Documents/code/cian-data-analisys/cian_2/cian_', formatC(1:159,flag='0'),'.csv', sep='')
        data <- c()
        for(i in id) {
                conn <- file(path[i],'r')
                data_set <- read.csv(conn, sep=';')
                close(conn)
                data <- rbind(data, data_set)
        }

        data
}

calc_cian <- function(id = 1:159) {
  data3 <- list()
  
  for(i in id){
    name <- levels(data$метро)[i]
    price_q10 <- as.numeric(quantile(data$цена[data$метро == name], probs = seq(0, 1, 0.1))[2])
    price_min <- min(data$цена[data$метро == name])
    price_max <- max(data$цена[data$метро == name])
    price_mean <- mean(data$цена[data$метро == name])
    price_median <- median(data$цена[data$метро == name])
    count <- nrow(data[which(data$метро == name),])
    data3 <- rbind(data3, c(name, price_min, price_q10, price_median, price_mean, price_max, count))
  }
  data3
}

data <- cian(id = 1:159)
result <- calc_cian(id = 1:159)
write.csv(result, sep=';')
