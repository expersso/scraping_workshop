library(tidyverse)
library(rvest)
library(httr)
library(stringr)
library(lubridate)

w_msg <- function(f) {
  function(...) {
    dots <- list(...)
    message("Processing: ", dots[[1]])
    f(...)
  }
}

get_bday <- . %>%
  html_nodes("span.bday") %>%
  html_text(TRUE) %>%
  str_replace("^(\\d{4})$", "\\1-01-01") %>%
  str_replace("^(\\d{4}-\\d{2})$", "\\1-01")

# IO
laureates <- read_html("https://en.wikipedia.org/wiki/List_of_Nobel_laureates")

tbl <- laureates %>%
  html_table(TRUE, TRUE, TRUE) %>%
  .[[1]] %>%
  head(-1) %>%
  gather(discipline, name, -Year) %>%
  mutate(name = map(name, ~str_split(., ";")[[1]]),) %>%
  unnest() %>%
  mutate(name = str_replace(str_trim(name), "\\[.\\]", "")) %>%
  tbl_df()

links <- laureates %>%
  html_nodes("table.wikitable a") %>%
  head(-6) %>%
  tail(-6) %>%
  {tibble(
    name = str_trim(html_text(.)),
    uri = paste0("https://en.wikipedia.org", html_attr(., "href"))
  )}

nobel <- left_join(tbl, links) %>%
  mutate(Year = as.numeric(str_replace(Year, "\\[.*\\]", ""))) %>%
  mutate(details_page = map(uri, safely(w_msg(read_html))))

df <- nobel %>%
  mutate(details = map(details_page, "result")) %>%
  filter(!map_lgl(details, is.null)) %>%
  mutate(bday = map(details, get_bday)) %>%
  filter(lengths(bday) == 1) %>%
  mutate(bday = as.Date(flatten_chr(bday)),
         age  = Year - year(bday))

df %>%
  filter(discipline != "Peace", age > 0) %>%
  ggplot(aes(x = Year, y = age, color = discipline)) +
  geom_point(show.legend = FALSE) +
  geom_smooth(show.legend = FALSE) +
  facet_wrap(~discipline)
