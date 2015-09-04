wd <- '~/Desktop/beach29/walk_to_beach/'
interval <- 1
setwd('~/Desktop')
dir.create('keeps')

setwd(wd)
jpgs <- dir()[which(grepl('JPG', dir()))]
inds <- 1:length(jpgs)
keep_inds <- which(inds %% interval == 0)
keep_jpgs <- jpgs[keep_inds]

for (i in 1:length(keep_jpgs)){
  new_name <- i
  while(nchar(new_name) <= 5){
    new_name <- paste0(0, new_name)
  }
  the_file <- keep_jpgs[i]
  file.copy(from = paste0(wd, the_file),
            to = paste0('~/Desktop/keeps/', new_name, '.jpg'))
}

# MAKE JPEG
setwd('~/Desktop')
setwd('keeps')

#ffmpeg -start_number 000001 -i %6d.jpg beach_run.mp4

