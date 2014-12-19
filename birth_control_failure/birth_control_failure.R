# Manually write in data from http://nyti.ms/WYwNaX
condom <- c(2, 4, 6, 8, 10, 11, 13, 15, 17, 18) / 100 # (assuming perfect use)
pill <- c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3) / 100 # (assuming perfect use)
year <- 1:10
df <- data.frame(year, pill, condom)

# Probability of BOTH failing
df$both <- df$pill * df$condom

# Plot it
my_col <- c("blue", "red", "darkgreen")
my_lty <- 3:1
my_pch <- 15:17
my_vars <- c("condom", "pill", "both")

plot(x = df$year,
     y = df$condom,
     type = "n",
     xlab = "Year",
     ylab = "Probability of failure",
     ylim = c(0, max(df$condom)))

for (i in 1:3){
  lines(df$year, df[,my_vars[i]],
        col = my_col[i],
        lty = my_lty[i])
  points(df$year, df[,my_vars[i]],
         col = my_col[i],
         pch = my_pch[i])
}

abline(h = seq(0,1, 0.05),
       col = adjustcolor("black", alpha.f = 0.2))

legend("topleft",
       col = my_col,
       lty = my_lty,
       pch = my_pch,
       legend = my_vars)
