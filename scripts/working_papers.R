library(tidyverse)
library(rvest)

get_title <- . %>%
  html_nodes("dl dd > .doc-title") %>%
  html_text()

get_url <- . %>%
  html_nodes("dl dd > .doc-title a") %>%
  html_attr("href")

get_authors <- . %>%
  html_nodes(".authors.ecb-small") %>%
  map(~html_nodes(., "a"))

get_date <- . %>%
  html_nodes("dt") %>%
  html_text()

get_id <- . %>%
  html_nodes("dt") %>%
  html_attr("id") %>%
  str_replace("paper-", "")

# IO
page <- read_html("http://www.ecb.europa.eu/pub/research/working-papers/html/all-papers.en.html")

papers <- page %>%
  {data_frame(
    id     = get_id(.),
    date   = get_date(.),
    author = get_authors(.),
    title  = get_title(.),
    url    = get_url(.)
  )}

papers <- papers %>%
  mutate(
    date        = str_replace(date, id, ""),
    date        = str_replace(date, "No. ", ""),
    date        = as.Date(date, "%d %b %Y"),
    author_name = map(author, html_text),
    author_url  = map(author, ~html_attr(., "href"))
  ) %>%
  select(-author) %>%
  unnest()

df <- papers %>%
  select(id, author = author_url) %>%
  mutate(author = str_replace_all(author, "^.*/|\\..*$", ""))

tbl <- table(df)
adj_mat <- t(tbl) %*% tbl
ta <- rowSums(adj_mat) %>% order(decreasing = TRUE) %>% head(30)

net <- graph_from_adjacency_matrix(adj_mat[ta, ta], "undirected", TRUE, FALSE)

ggraph(net) +
  geom_edge_link(aes(width = weight), alpha = 0.5) +
  geom_node_point(size = 8, colour = "steelblue", alpha = 0.5) +
  geom_node_text(aes(label = name)) +
  ggforce::theme_no_axes()
