library(tidyverse)
library(rvest)
library(lubridate)

get_year_page <- function(year) {
  "http://www.ecb.europa.eu/press/key/date/%s/html/index.en.html" %>%
    sprintf(year) %>%
    read_html()
}

get_date <- . %>%
  html_nodes("dt") %>%
  html_text() %>%
  dmy()

get_title <- . %>%
  html_nodes("dd > span.doc-title") %>%
  html_text()

get_subtitle <- . %>%
  html_nodes("div.doc-subtitle") %>%
  html_text()

get_url <- . %>%
  html_nodes("dd > span.doc-title > a") %>%
  html_attr("href") %>%
  {paste0("http://www.ecb.europa.eu", .)}

get_metadata <- function(page) {
  tibble(
    date     = get_date(page),
    title    = get_title(page),
    subtitle = get_subtitle(page),
    url      = get_url(page)
  ) %>%
    separate(title, c("speaker", "title"), ":", extra = "merge") %>%
    mutate_if(is.character, str_squish)
}

get_year <- . %>%
  get_year_page() %>%
  get_metadata()

get_text <- . %>%
  html_nodes("article > p") %>%
  html_text() %>%
  paste(collapse = "\n")

w_msg <- function(f) {
  function(...) {
    dots <- list(...)
    message("Processing: ", dots[[1]])
    f(...)
  }
}

w_delay <- function(f, delay = 0.5) {
  function(...) {
    Sys.sleep(delay)
  f(...)
  }
}

politely_get_year <- w_delay(w_msg(get_year))

## IO
ecb_speeches <- map_df(1999:year(Sys.Date()), politely_get_year)

ecb <- ecb_speeches %>%
  head() %>%
  mutate(page = map(url, read_html),
         text = map_chr(page, get_text))
