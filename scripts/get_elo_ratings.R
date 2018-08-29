library(tidyverse)
library(scales)
library(glue)
library(lubridate)

delay <- function(f, delay_fun) {
  force(f)
  function(...) {
    Sys.sleep(delay_fun(1))
    f(...)
  }
}

delayed_download <- delay(download.file, partial(runif, min = 1, max = 4))

nms <- c(
  "empty","rank","team","rating","highest_rank","highest_rating",
  "average_rank","average_rating","lowest_rank","lowest_rating",
  "3m_rank","3m_rating","6m_rank","6m_rating","12m_rank","12_rating",
  "24m_rank","24m_rating","60m_rank","60m_rating","120m_rank","120m_rating",
  "matches_total","matches_home","matches_away","matches_neutral",
  "matches_wins","matches_losses","matches_draws","goals_for",
  "goals_against","unknown1","unknown2"
)

## IO
data_raw <- "data-raw"
years <- 1909:2018

glue("https://www.eloratings.net/{years}.tsv") %>%
  walk(~delayed_download(., file.path(data_raw, basename(.))))

df <- dir(data_raw, full.names = TRUE) %>%
  set_names(.) %>%
  imap_dfr(~read_tsv(., FALSE, cols(.default = col_character()), na = "-"), .id = "year") %>%
  mutate(year = str_extract(year, "\\d+")) %>%
  set_names(c("year", nms)) %>%
  select(year, team, everything(), -empty, -unknown1, -unknown2) %>%
  mutate_all(.funs = funs(str_replace(., "[+−]", ""))) %>%
  mutate_at(vars(-team), as.numeric) %>%
  mutate(team = recode(team, WG = "DE"))

write_rds(df, "dfs.rds")
