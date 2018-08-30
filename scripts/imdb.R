library(tidyverse)
library(rvest)

get_id <- . %>%
  html_nodes(".titleColumn a") %>%
  html_attr("href") %>%
  str_extract("tt\\d+")

get_page <- function(type) {
  page <- read_html(paste0("https://www.imdb.com/chart/", type))

  page %>%
    html_table(TRUE, TRUE, TRUE) %>%
    {.[[1]][, 2:3]} %>%
    set_names(c("title", "rating")) %>%
    mutate(title        = str_trim(str_extract(title, "(?<=\\\n).*(?=\\\n)")),
           movie_rating = type,
           id           = get_id(page)) %>%
    slice(1:100)
}

df <- map_dfr(c("bottom", "top"), get_page)
