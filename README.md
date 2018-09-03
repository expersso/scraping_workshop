# Getting Data from the Web: Scraping for Economists

Material for the [web scraping
workshop](http://www.eea-esem-congresses.org/index.php?sezn=7&page=137) at the
2018 Annual Congress of the European Economic Association.

| What most tutorials are like | What this tutorial will be like | 
| ------------- |-------------| 
| ![](https://pbs.twimg.com/media/Bs13i6LCcAAvwCf.jpg) | ![asdsa](https://media0.giphy.com/media/q7UpJegIZjsk0/480w_s.jpg) |

## Key takeaways

1. The standard workflow:
    * Read the page with `read_html`.
    * Use the inspector tool to find the relevant nodes.
    * Write a CSS selector query (using e.g. 
    [CSS Selector Cheat Sheet](https://www.w3schools.com/cssref/css_selectors.asp)
    to remind you of the syntax).
    * Fetch the nodes using `html_nodes(page, css_query)`.
    * Extract the data using `html_text(nodes, trim = TRUE)`.
    * If you want to extract an attribute of a node instead of just the text,
    use `html_attr(node, attribute)`, e.g. `html_attr(node, "href")` to extract
    the  `href` from an anchor (\<a\>) node.

2. If you're lucky enough to have the data in a \<table\> node, try `html_table(page)`.
    * Remember that this returns a list of dataframes, even if there's only one
    table on the page.

3. If your data is spread across multiple pages, write a function that extracts
the data for one page, then map that function over all the other pages. For example, 

```r
get_data_for_specific_year <- function(year) { ... }
years <- 2010:2016
all_data <- map_dfr(years, get_data_for_specific_year)
```

4. Before you start scraping, kick the tires of the website a bit first.
    * Remember how we changed the `per_page` query to 600 instead of the
    25, 50, 100 options available on the webpage.

5. Make sure to look for a "Terms of Use" page on the website before you start scraping.
    * Cavalierly scraping a website that explicitly forbids it can be a very bad idea.

6. Use the `robotstxt` package as a programmatic way to see what parts of a
website are off-limits.

7. When working with modern and more sophisticated websites you may often have to
use the more low-level `httr` package rather than `rvest`.
    * If you see data in the browser, but it doesn't show up in R, the website is
      probably using Javascript to generate that data.
    * If this is the case, try to look around in the "Network" tab of the
      Inspector Tool to see if you can find the data there.
    * Then use the `GET` function to send your own GET request, and the `content`
      function to extract the content of the response.
    * The GET function (and the other httr functions corresponding to the http
      verbs like UPDATE, DELETE, etc) is very general, so you can modify your
      request using e.g. `user_agent`, `add_headers`, etc.

8. [CSS Diner](https://flukeout.github.io/) is the single best resource I've
found for learning the syntax of CSS selectors. Highly recommended!

9. I didn't spend much time explaining how `lapply` and `map` really work, and
how these functions allow you to avoid writing explicit loops. In my view, these
functions (and their siblings in the `purrr` package) are some of the most
powerful functions in the entire R language, so I would strongly advise you to
spend some time trying to understand and get comfortable using them. The
[Functionals](http://adv-r.had.co.nz/Functionals.html) chapter in [Advanced
R](http://adv-r.had.co.nz/) is the best resource I know for learning these.

10. We didn't have time to talk about web forms (such as how to scrape a website
that first requires you to log in). The short answer for how to do this is to
use the `html_forms` function in `rvest`. You can take a look at [this
page](https://scrapethissite.com/pages/advanced/?gotcha=login) for an exercise,
and see my solution at the bottom of the `scripts/scrapethis.R` file in the
Github repo.
