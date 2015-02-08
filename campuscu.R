setwd('/home/joebrew/Desktop')
df <- read.csv('campuscu.csv')

df$date <- as.Date(df$date, format = "%m/%d/%Y")
df$balance <- as.numeric(gsub("[$]|,", "", df$balance))

head(df)

plot(x = df$date,
     y = df$balance,
     xaxt = "n",
     xlab = NA,
     ylab = "Savings",
     ylim = c(0, max(df$balance, na.rm = TRUE) * 1.05),
     col = adjustcolor("black", alpha.f = 0.6))

abline(h = seq(0, 50000, 1000),
       col = adjustcolor("black", alpha.f = 0.2))

date_labels <- as.Date(c(paste0("2014-",1:12, "-01"),
                         paste0("2015-",1:12, "-01")), format = "%Y-%m-%d")

abline(v = date_labels,
       col = adjustcolor("black", alpha.f = 0.2))
axis(side = 1,
     at = date_labels,
     labels = format(date_labels, format = "%B"),
     las = 3,
     cex.axis = 0.8)

fit <- lm(balance ~ date,
          data = df)
abline(fit, 
       col = adjustcolor("darkred", alpha.f = 0.6),
       lwd = 2)


new_data <- data.frame(date = seq(Sys.Date(), Sys.Date()+ 365, 1))
new_data$balance <- predict(fit,
                            newdata = new_data)