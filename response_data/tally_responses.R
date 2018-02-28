
library(tidyverse)

# read all of the response data
fls <- list.files(".", pattern = "\\.csv$")
resp_dat <- map(fls, read_csv) %>% bind_rows()

# tally the item selections
item_cnts <- resp_dat %>% count(item) %>% arrange(desc(n))

# tally the users (make sure everyone only submitted data 1x)
name_cnts <- resp_dat %>% count(name)

# save the data as an rds
saveRDS(item_cnts, "item_counts.rds")
