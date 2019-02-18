library(tidyverse)
library(rvest)
library(httr)

# Countries
countries <-
  "https://scrapethissite.com/pages/simple/" %>%
  read_html() %>%
  {data_frame(
      name       = html_nodes(., ".country-name"),
      capital    = html_nodes(., ".country-capital"),
      population = html_nodes(., ".country-population"),
      area       = html_nodes(., ".country-area")
    )} %>%
  mutate_all(html_text, TRUE) %>%
  mutate_at(3:4, as.numeric)

# Countries 2
page <- read_html("https://scrapethissite.com/pages/simple/")

c("name", "capital", "population", "area") %>%
  set_names(.) %>%
  map_dfc(~html_text(html_nodes(page, paste0(".country-", .x)), TRUE)) %>%
  mutate_at(3:4, as.numeric)

# Hockey teams
hockey <- "https://scrapethissite.com/pages/forms/?per_page=1000" %>%
  read_html() %>%
  html_table(TRUE, TRUE, TRUE) %>%
  .[[1]]

# Films
get_year <- function(year) {
  paste0("https://scrapethissite.com/pages/ajax-javascript/?ajax=true&year=", year) %>%
  GET() %>%
  content() %>%
  map_dfr(as_data_frame) %>%
  mutate(title = str_trim(title))
}

map_dfr(2010:2015, get_year)

# Headers
parse_response <- . %>%
  content() %>%
  html_nodes(".container") %>%
  .[2] %>%
  html_text(TRUE) %>%
  str_squish()

GET("https://scrapethissite.com/pages/advanced/?gotcha=headers") %>%
  parse_response()

GET("https://scrapethissite.com/pages/advanced/?gotcha=headers",
    user_agent("Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0"),
    add_headers("Accept" = "text/html")) %>%
  parse_response()

# Login
s <- html_session("https://scrapethissite.com/pages/advanced/?gotcha=login")
form <- html_form(s)[[1]] %>%
  set_values(user = "username", pass = "password") %>%
  update_list(url = "")
s <- submit_form(s, form)

parse_response(s$response)

# Login with CSRF
s <- html_session("https://scrapethissite.com/pages/advanced/?gotcha=csrf")

csrf_val <- s %>%
  html_nodes("input[type='hidden']") %>%
  html_attr("value")

form <- html_form(s)[[1]] %>%
  set_values(user = "username", pass = "password", csrf = csrf_val) %>%
  update_list(url = "")
s <- submit_form(s, form)

parse_response(s$response)
