library(tidyverse)
library(rvest)

clean_price <- . %>%
  str_squish() %>%
  str_replace(",", ".") %>%
  str_replace("(\\d+)\\.(\\d+\\.\\d+)", "\\1,\\2") %>%
  str_extract("^[\\d.,]+") %>%
  parse_number()

get_categories <- function() {
  "https://www.ikea.com/de/catalog/allproducts/alphabetical/" %>%
    read_html() %>%
    html_nodes("#allProductsContainer li a") %>%
    {tibble(
      product_category = html_text(., TRUE),
      uri = paste0("https://www.ikea.com", html_attr(., "href"))
    )}
}

get_product_details <- . %>%
  {tibble(
    product_title = html_nodes(., ".productTitle:not(:empty)"),
    product_desc = html_nodes(., ".productDesp:not(:empty)"),
    price = html_nodes(., ".price.regularPrice:not(:empty), .prodPrice:not(:empty)")
  )} %>%
  mutate_all(html_text) %>%
  mutate(price = clean_price(price))

## IO
categories <- get_categories() %>%
  mutate(details_page = imap(uri, ~{message(.y); read_html(.x)}))

products <- categories %>%
  mutate(details = imap(details_page, ~{message(.y); get_product_details(.x)})) %>%
  unnest(details) %>%
  select(-uri)

products %>%
  group_by(product_category) %>%
  summarise(mean = mean(price),
            median = median(price)) %>%
  arrange(desc(median))
