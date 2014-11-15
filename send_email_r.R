# Attach package
library(sendmailR)

# Point to server
sendmail_options(smtpServer="ASPMX.L.GOOGLE.COM")

# Define 
sendmail(from = "<joebrew@gmail.com>",
         to = "<joebrew@gmail.com>",
         subject = "Test email",
         msg = "Testing testing")
