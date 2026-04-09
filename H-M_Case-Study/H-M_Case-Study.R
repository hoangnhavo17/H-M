# Expect working directory = repository root (folders data/, output/, H-M_Case-Study/).
# If you source this file from inside H-M_Case-Study/, the next line moves up to the repo root.
if (basename(getwd()) == "H-M_Case-Study") {
  setwd(dirname(getwd()))
}
if (!dir.exists("data")) {
  stop("Missing data/ folder. Place Kaggle CSVs in data/ or set working directory to the H-M repo root.")
}
dir.create("output/figures", showWarnings = FALSE, recursive = TRUE)

# Install dependencies once, then comment out for routine runs.
# install.packages(c("dplyr", "tidyverse", "ggplot2", "lubridate", "gridExtra"))
library(dplyr)
library(tidyverse)
library(forcats)
library(ggplot2)
library(scales)
library(lubridate)
library(gridExtra)

articles <- read.csv('data/articles.csv')
customers <- read.csv("data/customers.csv")
transactions <- read.csv("data/transactions_train.csv")

# Replaced customer IDs with numeric values to anonymize data and standardize for analysis.
customer_ids <- unique(customers$customer_id)
customer_id_number <- setNames(seq_along(customer_ids), customer_ids)
pp_customers <- customers %>% mutate(customer_id = customer_id_number[as.character(customer_id)])
pp_transactions <- transactions %>% mutate(customer_id = customer_id_number[as.character(customer_id)])
head(pp_customers)
head(pp_transactions)

# Generated unique order IDs to group transactions for consistent analysis.
pp_transactions <- pp_transactions %>% group_by(t_dat, customer_id, sales_channel_id) %>% mutate(order_id = cur_group_id()) %>% ungroup()
head(pp_transactions)

# Converted IDs to characters to prevent numeric operations and preserve data integrity.
articles$article_id <- as.character(articles$article_id)

pp_customers$customer_id <- as.character(pp_customers$customer_id)

pp_transactions$customer_id <- as.character(pp_transactions$customer_id)
pp_transactions$article_id <- as.character(pp_transactions$article_id)
pp_transactions$order_id <- as.character(pp_transactions$order_id)

# Ladieswear account for the largest portion of articles while sportwear accounts for the least.
articles %>%
  count(index_name) %>%
  mutate(index_name = fct_reorder(index_name, n)) %>%  # Reorder `index_name` by `n`
  ggplot(aes(x = index_name, y = n)) +
  geom_bar(stat = "identity", fill = "#cc071e", alpha = 0.6, width = 0.4) +
  coord_flip() +
  labs(
    x = NULL,  # Remove x-axis label
    y = "Count",
    title = "Count of Articles by Index Name"
  ) +
  theme_bw()

# Garments grouped by index: Jersey fancy is the most frequent garment, especially for women and children.
articles %>%
	count(garment_group_name, index_group_name) %>%
	mutate(garment_group_name = fct_reorder(garment_group_name, n)) %>%
	ggplot(aes(
		x=n,
		y=garment_group_name,
		fill=index_group_name
	)) +
	geom_bar(stat="identity", position="stack") +
	labs(
		x="Count by Garment Group",
		y="Garment Group",
		fill="Index Group Name",
		title="Garment Group Counts Stacked by Index Group"
	) +
	theme_bw()

# Among the index groups, Ladieswear and Baby/Children have subgroups.
articles %>%
	group_by(index_group_name, index_name) %>%
	summarize(article_count = n())

# Product group and product type pairs: Accessories have the most variety but trousers are the most numerous.
articles %>%
	group_by(product_group_name, product_type_name) %>%
	summarize(article_count = n()) %>%
	print(n=132)

# There are no duplciates in customers dataset
duplicate_count <- nrow(customers) - n_distinct(customers$customer_id)
duplicate_count

# There is an abnormal amount of customers linked to one postal code, which means it might be an encoded NaN address such as a distribution center or pickup spot.
postal_data <- customers %>%
	group_by(postal_code) %>%
	summarise(customer_count = n()) %>%
	arrange(desc(customer_count))
postal_data

# Customers at this postal code vary by age, club_member_status, and customer_ids.
max_postal_code <- postal_data %>%
	slice(1) %>%
	pull(postal_code)
max_postal_code

customers %>%
	filter(postal_code == max_postal_code) %>%
	head(5)

# The most common age is about 20 - 22
age_data <- ggplot(customers, aes(x = age)) +
  geom_histogram(bins=100, fill = "red", color = "black", alpha = 0.7)
  
age_data <- ggplot_build(age_data)$data[[1]]

max_bin <- age_data %>%
	arrange(desc(count)) %>%
	slice(1)
  
ggplot(customers, aes(x = age)) +
  geom_histogram(bins=100, fill = "red", color = "black", alpha = 0.7) + 
  geom_rect(aes(xmin = max_bin$xmin, xmax = max_bin$xmax, ymin = 0, ymax = max_bin$count),
            fill = "gold", alpha = 0.3) +  # Highlight the max bin with a transparent red color
  labs(x = "Distribution of the customers age", y = "Count") +
  theme_bw()
paste(max_bin$xmin, "-", max_bin$xmax)

# Most customers have an active club status, with some who begin to activate it. Only a tiny part of customers have left the club.
ggplot(customers, aes(x=club_member_status)) + 
	geom_bar(fill="red", color="black", alpha=0.7) +
	labs(
		x = "Distribution of Club Member Status",
		y = "Count"
	) +
	theme_bw()
	
# There are three types for NO DATA. Values are united as 'None'.
customers <- customers %>% mutate(fashion_news_frequency = ifelse(fashion_news_frequency %in% c("Regularly", "Monthly"), fashion_news_frequency, "None"))
unique(customers$fashion_news_frequency)

# Customers prefer not to get any news from the brand.
news_data <- customers %>%
	group_by(fashion_news_frequency) %>%
	summarize(customer_count = n())
ggplot(news_data, aes(x="", y=customer_count, fill=fashion_news_frequency)) +
	geom_bar(stat="identity", width=1, color="black") +
	coord_polar(theta="y") +
	labs(title="Distribution of Fashion News Frequency", x=NULL, y=NULL) +
	scale_fill_brewer(palette="Pastel1") +
	theme_void()
	
# Price scaling - ref: https://www.kaggle.com/c/h-and-m-personalized-fashion-recommendations/discussion/310496
transactions <- transactions %>% mutate(price = price * 590)
head(transactions)

summary(transactions$price)

# Price outliers
ggplot(transactions, aes(x=price)) + 
	geom_boxplot(fill="red", color="black", alpha=0.7) +
	labs(
		x = "Price Outliers",
		y = "Price"
	) + 
	theme_bw()

# Garment Upper/Lower/Full body, Shoes, and Accessories have massive price variance.
# Extra article fields support RFM deep dives (aligned with DSCI599 notebook Step 4).
articles_for_merge <- articles[c(
  "article_id", "prod_name", "product_type_name", "product_group_name", "index_name",
  "index_group_name", "section_name", "garment_group_name", "graphical_appearance_name",
  "colour_group_name", "perceived_colour_master_name"
)]
merged_data <- merge(transactions, articles_for_merge, by = "article_id", all.x = TRUE)
head(merged_data)

ggplot(merged_data, aes(x=price, y=product_group_name)) + 
	geom_boxplot(fill="red", color="black", alpha=0.7) + 
	labs(
		x = "Price Outliers",
		y = "Index Names",
		title = "Boxplot of Price by Product Group"
	) +
	theme_bw()

# Among accessories, bags have the largest outliers, which is expected. Scarves and other accessories also have high variance.
accessories_data <- merged_data %>%
	filter(product_group_name == "Accessories")
	
ggplot(accessories_data, aes(x=price, y=product_type_name)) + 
	geom_boxplot(fill="red", color="black", alpha=0.7) + 
	labs(
		x = "Price Outliers",
		y = "Index Names",
		title = "Boxplot of Price by Product Type for Accessories"
	) +
	theme_bw()

# Ladieswear have the highest mean price among Indexes while children generally have the lowest.
articles_index <- merged_data %>%
	group_by(index_name) %>%
	summarize(mean_price = mean(price, na.rm=TRUE)) %>%
	arrange(desc(mean_price))
	
ggplot(articles_index, aes(x=mean_price, y=index_name)) +
	geom_bar(stat="identity", fill="red", alpha=0.8) +
	labs(
		x = "Price by Index",
		y = "Index"
	) +
	theme_bw()
	
# Shoes have the highest mean price among Product Groups while Stationery have the lowest.
articles_index <- merged_data %>%
	group_by(product_group_name) %>%
	summarize(mean_price = mean(price, na.rm=TRUE))
	
ggplot(articles_index, aes(x=mean_price, y=fct_reorder(product_group_name, mean_price))) +
	geom_bar(stat="identity", fill="red", alpha=0.8) +
	labs(
		x = "Price by Product Group",
		y = "Index"
	) +
	theme_bw()

# Mean price change for top 5 product groups by mean price
merged_data$t_dat <- as.Date(merged_data$t_dat)

articles_index <- merged_data %>%
	group_by(product_group_name, month = floor_date(t_dat, "month")) %>%
	summarize(mean_price = mean(price, na.rm = TRUE))

product_list <- articles_index %>%
	group_by(product_group_name) %>%
	summarize(mean_price_all_time = mean(mean_price, na.rm=TRUE)) %>%
	arrange(desc(mean_price_all_time)) %>%
	slice_head(n=5)
	
plot_list <- list()
	
for (product in product_list$product_group_name){
	product_data <- articles_index %>%
		filter(product_group_name == product)
	
	p <- ggplot(product_data, aes(x=month, y=mean_price)) + 
		geom_line(color="red", linewidth=1.2) +
		geom_ribbon(aes(ymin=mean_price-2*sd(mean_price), ymax=mean_price+2*sd(mean_price)),
			fill="red", alpha=0.1) +
		labs(x="Month", y=paste("Mean Price for", product), title = paste("Price Over Time for", product)) +
		theme_bw()
		
	plot_list[[product]] <- p
	}
	
grid.arrange(grobs = plot_list, ncol = 2, nrow = 3)

# ---- RFM analysis and segment deep dives (aligned with DSCI599 Jupyter workflow) ----
# Uses scaled prices and original customer_id. Recency = days from last purchase to day after max date;
# Frequency = distinct purchase dates per customer; Monetary = sum of line-item prices.
snapshot_date <- max(as.Date(transactions$t_dat), na.rm = TRUE) + 1

rfm_df <- transactions %>%
  mutate(t_dat = as.Date(t_dat)) %>%
  group_by(customer_id) %>%
  summarize(
    Recency = as.numeric(snapshot_date - max(t_dat, na.rm = TRUE)),
    Frequency = n_distinct(t_dat),
    Monetary = sum(price, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(Recency), Recency >= 0, !is.na(Monetary)) %>%
  mutate(
    # Lowest recency (most recent) -> R=5, same as pandas qcut(..., labels=c('5','4','3','2','1'))
    R = as.character(6 - ntile(Recency, 5)),
    F = as.character(ntile(Frequency, 5)),
    M = as.character(ntile(Monetary, 5)),
    RFM_Segment = paste0(R, F, M),
    RFM_Score = as.integer(R) + as.integer(F) + as.integer(M)
  )

# Segment definitions (team notebook)
best_ids <- rfm_df %>% filter(RFM_Segment == "545") %>% pull(customer_id)
loyal_ids <- rfm_df %>% filter(stringr::str_detect(RFM_Segment, "^54.$")) %>% pull(customer_id)
big_spender_ids <- rfm_df %>%
  filter(M == "5", R %in% c("1", "2"), F %in% c("1", "2")) %>%
  pull(customer_id)
at_risk_ids <- rfm_df %>%
  filter(R %in% c("1", "2"), F == "4", M == "5") %>%
  pull(customer_id)
new_ids <- rfm_df %>% filter(RFM_Segment %in% c("511", "512")) %>% pull(customer_id)
occasional_ids <- rfm_df %>%
  filter(R == "3", F %in% c("2", "3"), M %in% as.character(1:5)) %>%
  pull(customer_id)

segment_counts <- tibble::tibble(
  segment = c("Best (545)", "Loyal (54x)", "Big spender", "At-risk", "New (511-512)", "Occasional"),
  customers = c(
    length(unique(best_ids)),
    length(unique(loyal_ids)),
    length(unique(big_spender_ids)),
    length(unique(at_risk_ids)),
    length(unique(new_ids)),
    length(unique(occasional_ids))
  )
)
print(segment_counts)

# RFM segment frequency (top 20 for readability)
rfm_seg_top <- rfm_df %>%
  count(RFM_Segment, name = "n") %>%
  arrange(desc(n)) %>%
  slice_head(n = 20)

p_rfm_seg <- ggplot(rfm_seg_top, aes(x = reorder(RFM_Segment, n), y = n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  coord_flip() +
  labs(
    title = "Top 20 RFM segment codes (customer count)",
    subtitle = "R,F,M quintiles: R=5 most recent; higher F and M = more active / more spend",
    x = "RFM_Segment (R+F+M)",
    y = "Customers"
  ) +
  theme_bw()
print(p_rfm_seg)
ggsave("output/figures/rfm_segment_top20.png", p_rfm_seg, width = 9, height = 7, dpi = 150)

# Deep dive: best customers (545) — product group mix (merged_data already has Date t_dat)
best_tx <- merged_data %>% filter(customer_id %in% best_ids)

p_best_pg <- best_tx %>%
  filter(!is.na(product_group_name)) %>%
  count(product_group_name, sort = TRUE) %>%
  slice_head(n = 12) %>%
  ggplot(aes(x = reorder(product_group_name, n), y = n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  coord_flip() +
  labs(
    title = "Best RFM segment (545): line items by product group",
    x = NULL,
    y = "Line items"
  ) +
  theme_bw()
print(p_best_pg)
ggsave("output/figures/rfm_best_product_groups.png", p_best_pg, width = 9, height = 6, dpi = 150)

# Best segment: online vs in-store share (line items)
best_ch <- best_tx %>%
  mutate(channel = if_else(sales_channel_id == 1L, "In-store", "Online")) %>%
  count(channel) %>%
  mutate(pct = n / sum(n))

p_best_ch <- ggplot(best_ch, aes(x = "", y = pct, fill = channel)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  scale_fill_manual(values = c("In-store" = "#999999", "Online" = "#cc071e")) +
  labs(
    title = "Best customers (545): share of line items by channel",
    fill = NULL
  ) +
  theme_void()
print(p_best_ch)
ggsave("output/figures/rfm_best_channel_share.png", p_best_ch, width = 6, height = 5, dpi = 150)

# Best vs population: channel share comparison
pop_ch <- merged_data %>%
  mutate(channel = if_else(sales_channel_id == 1L, "In-store", "Online")) %>%
  count(channel) %>%
  mutate(pct = n / sum(n), cohort = "All customers")

best_ch_cmp <- best_tx %>%
  mutate(channel = if_else(sales_channel_id == 1L, "In-store", "Online")) %>%
  count(channel) %>%
  mutate(pct = n / sum(n), cohort = "Best (545)")

ch_cmp <- bind_rows(best_ch_cmp, pop_ch)

p_ch_cmp <- ggplot(ch_cmp, aes(x = cohort, y = pct, fill = channel)) +
  geom_col(position = "fill", alpha = 0.9) +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = c("In-store" = "#999999", "Online" = "#cc071e")) +
  labs(
    title = "Channel mix: best RFM segment vs all customers",
    x = NULL,
    y = "Share of line items",
    fill = NULL
  ) +
  theme_bw()
print(p_ch_cmp)
ggsave("output/figures/rfm_best_vs_all_channel.png", p_ch_cmp, width = 7, height = 4.5, dpi = 150)

# Best segment: age distribution vs all customers (where age present)
rfm_age_best <- customers %>%
  semi_join(tibble(customer_id = best_ids), by = "customer_id") %>%
  transmute(cohort = "Best (545)", age = as.numeric(age))

rfm_age_all <- customers %>%
  transmute(cohort = "All customers", age = as.numeric(age))

age_cmp <- bind_rows(rfm_age_best, rfm_age_all) %>% filter(!is.na(age))

p_age_cmp <- ggplot(age_cmp, aes(x = age, fill = cohort)) +
  geom_density(alpha = 0.35, color = NA) +
  scale_fill_manual(values = c("All customers" = "gray40", "Best (545)" = "#cc071e")) +
  labs(
    title = "Age distribution: best RFM segment vs all customers",
    x = "Age",
    y = "Density",
    fill = NULL
  ) +
  theme_bw()
print(p_age_cmp)
ggsave("output/figures/rfm_best_vs_all_age_density.png", p_age_cmp, width = 9, height = 4.5, dpi = 150)

# ---- RFM / segment visuals and Step 4 deep dives (DSCI599 notebook parity) ----
# Generation buckets match notebook gen_label(); "Millenial" spelling kept for heatmap ordering.
gen_label <- function(age) {
  case_when(
    is.na(age) ~ NA_character_,
    age <= 10 ~ "Gen Alpha",
    age > 10 & age <= 29 ~ "Gen Z",
    age > 29 & age <= 44 ~ "Millenial",
    age > 44 & age <= 59 ~ "Gen X",
    age > 59 & age <= 74 ~ "Baby Boomers",
    age > 74 & age <= 89 ~ "Silent Gen",
    age > 89 & age <= 104 ~ "Greatest Gen",
    TRUE ~ NA_character_
  )
}

age_group_order <- c("Gen Z", "Millenial", "Gen X", "Baby Boomers", "Silent Gen", "Greatest Gen")
day_order <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

merged_demo <- merged_data %>%
  left_join(
    customers %>%
      transmute(
        customer_id,
        age_num = suppressWarnings(as.numeric(age)),
        age_group = gen_label(age_num)
      ),
    by = "customer_id"
  ) %>%
  mutate(
    dow = factor(weekdays(t_dat, abbreviate = FALSE), levels = day_order)
  )

# R, F, M marginal counts (three panels)
rfm_dim_counts <- bind_rows(
  rfm_df %>% count(R, name = "n") %>% mutate(dim = "R", score = R),
  rfm_df %>% count(F, name = "n") %>% mutate(dim = "F", score = F),
  rfm_df %>% count(M, name = "n") %>% mutate(dim = "M", score = M)
) %>%
  mutate(score = factor(score, levels = as.character(1:5)))

p_rfm_dims <- ggplot(rfm_dim_counts, aes(score, n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  facet_wrap(~dim, nrow = 1, scales = "free_x") +
  labs(
    title = "R, F, and M score distributions",
    x = "Score (1–5)",
    y = "Customers"
  ) +
  theme_bw()
print(p_rfm_dims)
ggsave("output/figures/rfm_r_f_m_bars.png", p_rfm_dims, width = 12, height = 4, dpi = 150)

p_rfm_score_dist <- rfm_df %>%
  count(RFM_Score) %>%
  ggplot(aes(factor(RFM_Score), n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  labs(
    title = "RFM score distribution (R + F + M)",
    x = "RFM_Score",
    y = "Customers"
  ) +
  theme_bw()
print(p_rfm_score_dist)
ggsave("output/figures/rfm_score_distribution.png", p_rfm_score_dist, width = 8, height = 4, dpi = 150)

# Six-panel age histograms (one per segment)
seg_age_hist <- function(ids, title) {
  d <- customers %>%
    filter(customer_id %in% unique(ids)) %>%
    transmute(age = suppressWarnings(as.numeric(age))) %>%
    filter(!is.na(age))
  if (nrow(d) < 2) {
    return(
      ggplot() +
        annotate("text", x = 0.5, y = 0.5, label = "Insufficient age data") +
        coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
        labs(title = title) +
        theme_void()
    )
  }
  med <- median(d$age, na.rm = TRUE)
  ggplot(d, aes(age)) +
    geom_histogram(bins = 20, fill = "#cc071e", color = "gray25", alpha = 0.8) +
    geom_vline(xintercept = med, linetype = "dashed", color = "blue", linewidth = 0.6) +
    labs(title = title, x = "Age", y = "Customers", subtitle = paste0("Median = ", round(med, 2))) +
    theme_bw()
}

g_age_seg <- grid.arrange(
  seg_age_hist(best_ids, "Best (545)"),
  seg_age_hist(loyal_ids, "Loyal (54x)"),
  seg_age_hist(big_spender_ids, "Big spender"),
  seg_age_hist(at_risk_ids, "At-risk"),
  seg_age_hist(new_ids, "New (511–512)"),
  seg_age_hist(occasional_ids, "Occasional"),
  ncol = 3,
  nrow = 2
)
print(g_age_seg)
png("output/figures/rfm_segments_age_hist_grid.png", width = 14, height = 9, units = "in", res = 150)
print(g_age_seg)
dev.off()

# Generation mix by segment (transaction-weighted), faceted “pie” stacks
gen_by_seg <- bind_rows(
  merged_demo %>% filter(customer_id %in% best_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "Best (545)"),
  merged_demo %>% filter(customer_id %in% loyal_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "Loyal (54x)"),
  merged_demo %>% filter(customer_id %in% big_spender_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "Big spender"),
  merged_demo %>% filter(customer_id %in% at_risk_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "At-risk"),
  merged_demo %>% filter(customer_id %in% new_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "New (511–512)"),
  merged_demo %>% filter(customer_id %in% occasional_ids, !is.na(age_group)) %>%
    count(age_group, name = "n") %>% mutate(segment = "Occasional")
) %>%
  mutate(
    segment = factor(
      segment,
      levels = c("Best (545)", "Loyal (54x)", "Big spender", "At-risk", "New (511–512)", "Occasional")
    )
  )

p_gen_seg <- ggplot(gen_by_seg, aes(x = "", y = n, fill = age_group)) +
  geom_col(width = 1, color = "white", linewidth = 0.2) +
  coord_polar(theta = "y") +
  facet_wrap(~segment, nrow = 3, ncol = 2) +
  labs(title = "Generation mix by RFM segment (line items)", fill = NULL) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))
print(p_gen_seg)
ggsave("output/figures/rfm_segments_generation_facets.png", p_gen_seg, width = 10, height = 12, dpi = 150)

# Day-of-week line-item counts by segment
dow_by_seg <- bind_rows(
  merged_demo %>% filter(customer_id %in% best_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "Best (545)"),
  merged_demo %>% filter(customer_id %in% loyal_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "Loyal (54x)"),
  merged_demo %>% filter(customer_id %in% big_spender_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "Big spender"),
  merged_demo %>% filter(customer_id %in% at_risk_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "At-risk"),
  merged_demo %>% filter(customer_id %in% new_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "New (511–512)"),
  merged_demo %>% filter(customer_id %in% occasional_ids, !is.na(dow)) %>%
    count(dow, name = "n") %>% mutate(segment = "Occasional")
) %>%
  mutate(
    segment = factor(
      segment,
      levels = c("Best (545)", "Loyal (54x)", "Big spender", "At-risk", "New (511–512)", "Occasional")
    ),
    dow = factor(dow, levels = day_order)
  )

p_dow_seg <- ggplot(dow_by_seg, aes(dow, n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  facet_wrap(~segment, scales = "free_y", ncol = 2) +
  labs(
    title = "Day-of-week distribution of line items by RFM segment",
    x = NULL,
    y = "Line items"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p_dow_seg)
ggsave("output/figures/rfm_segments_dow_facets.png", p_dow_seg, width = 10, height = 10, dpi = 150)

# Step 4.1 — index group: best (545) vs all (pie-style bars)
ig_best <- merged_demo %>%
  filter(customer_id %in% best_ids, !is.na(index_group_name)) %>%
  count(index_group_name, name = "n")
ig_all <- merged_demo %>%
  filter(!is.na(index_group_name)) %>%
  count(index_group_name, name = "n")

p_ig_best <- ggplot(ig_best, aes(x = "", y = n, fill = index_group_name)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Index group — best (545)") +
  theme_void()

p_ig_all <- ggplot(ig_all, aes(x = "", y = n, fill = index_group_name)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  labs(title = "Index group — all customers") +
  theme_void()

g_ig_cmp <- grid.arrange(p_ig_best, p_ig_all, ncol = 2)
print(g_ig_cmp)
png("output/figures/rfm_best_vs_all_index_group_pies.png", width = 12, height = 6, units = "in", res = 150)
print(g_ig_cmp)
dev.off()

# Garment group × index group (stacked), best segment
p_garment_stack <- merged_demo %>%
  filter(customer_id %in% best_ids, !is.na(garment_group_name), !is.na(index_group_name)) %>%
  count(garment_group_name, index_group_name) %>%
  ggplot(aes(y = reorder(garment_group_name, n), x = n, fill = index_group_name)) +
  geom_col(position = "stack", alpha = 0.9) +
  labs(
    title = "Best (545): garment counts by index group",
    x = "Line items",
    y = "Garment group",
    fill = "Index group"
  ) +
  theme_bw()
print(p_garment_stack)
ggsave("output/figures/rfm_best_garment_by_index_stacked.png", p_garment_stack, width = 12, height = 9, dpi = 150)

# Ladieswear: top sections — best vs population
lad_best_sec <- merged_demo %>%
  filter(customer_id %in% best_ids, index_group_name == "Ladieswear", !is.na(section_name)) %>%
  count(section_name, sort = TRUE) %>%
  slice_head(n = 10) %>%
  mutate(section_name = fct_reorder(section_name, n))

lad_all_sec <- merged_demo %>%
  filter(index_group_name == "Ladieswear", !is.na(section_name)) %>%
  count(section_name, sort = TRUE) %>%
  slice_head(n = 10) %>%
  mutate(section_name = fct_reorder(section_name, n))

p_lad_best <- ggplot(lad_best_sec, aes(x = n, y = section_name)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  labs(title = "Ladieswear sections — best (545)", x = "Line items", y = NULL) +
  theme_bw()

p_lad_all <- ggplot(lad_all_sec, aes(x = n, y = section_name)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  labs(title = "Ladieswear sections — all", x = "Line items", y = NULL) +
  theme_bw()

g_lad <- grid.arrange(p_lad_best, p_lad_all, nrow = 2)
print(g_lad)
png("output/figures/rfm_best_vs_all_ladieswear_sections.png", width = 10, height = 10, units = "in", res = 150)
print(g_lad)
dev.off()

# Step 4.2 — seasonality and channel (best segment)
p_mv_month <- merged_demo %>%
  filter(customer_id %in% best_ids) %>%
  mutate(mo = month(t_dat, label = TRUE, abbr = TRUE)) %>%
  count(mo) %>%
  ggplot(aes(mo, n)) +
  geom_col(fill = "#cc071e", alpha = 0.85) +
  labs(
    title = "Best (545): purchases by calendar month",
    x = "Month",
    y = "Line items"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p_mv_month)
ggsave("output/figures/rfm_best_seasonality_month.png", p_mv_month, width = 9, height = 4.5, dpi = 150)

mv <- merged_demo %>% filter(customer_id %in% best_ids)

# Step 4.3 — price by age group (best segment; outliers hidden like seaborn showfliers=False)
q99_price <- quantile(mv$price, 0.99, na.rm = TRUE)
p_mv_price_age <- mv %>%
  filter(age_group %in% age_group_order) %>%
  mutate(age_group = factor(age_group, levels = age_group_order)) %>%
  ggplot(aes(age_group, price)) +
  geom_boxplot(outlier.shape = NA, fill = "#cc071e", alpha = 0.35, color = "gray30") +
  coord_cartesian(ylim = c(0, q99_price)) +
  labs(
    title = "Best (545): price by generation (y-axis trimmed at 99th pct)",
    x = NULL,
    y = "Price"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))
print(p_mv_price_age)
ggsave("output/figures/rfm_best_price_by_age_group.png", p_mv_price_age, width = 9, height = 4.5, dpi = 150)

# Heatmaps: share within age_group (best segment)
heatmap_age_item <- function(df_mv, col_nm, plot_title, top_n = 10) {
  x <- df_mv %>%
    filter(!is.na(.data[[col_nm]]), !is.na(age_group)) %>%
    rename(item = all_of(col_nm))
  top_items <- x %>%
    count(item, sort = TRUE) %>%
    slice_head(n = top_n) %>%
    pull(item)
  plot_dat <- x %>%
    filter(item %in% top_items) %>%
    count(age_group, item) %>%
    group_by(age_group) %>%
    mutate(p = n / sum(n)) %>%
    ungroup() %>%
    mutate(
      age_group = factor(age_group, levels = intersect(age_group_order, unique(age_group))),
      item = factor(item, levels = rev(top_items))
    )
  ggplot(plot_dat, aes(item, age_group, fill = p)) +
    geom_tile(color = "white") +
    geom_text(aes(label = scales::percent(p, accuracy = 0.1)), size = 2.4, color = "gray10") +
    scale_fill_gradient(low = "white", high = "#cc071e", labels = percent_format(accuracy = 1)) +
    labs(title = plot_title, x = NULL, y = NULL, fill = "Share\nwithin age") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

p_hm_dow <- mv %>%
  filter(!is.na(age_group), !is.na(dow), age_group %in% age_group_order) %>%
  count(age_group, dow) %>%
  group_by(age_group) %>%
  mutate(p = n / sum(n)) %>%
  ungroup() %>%
  mutate(
    age_group = factor(age_group, levels = age_group_order),
    dow = factor(dow, levels = day_order)
  ) %>%
  ggplot(aes(dow, age_group, fill = p)) +
  geom_tile(color = "white") +
  geom_text(aes(label = scales::percent(p, accuracy = 0.1)), size = 2.8, color = "gray10") +
  scale_fill_gradient(low = "white", high = "#cc071e", labels = percent_format(accuracy = 1)) +
  labs(
    title = "Best (545): day of week share within generation",
    x = NULL,
    y = NULL,
    fill = "Share"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
print(p_hm_dow)
ggsave("output/figures/rfm_best_heatmap_dow_by_age.png", p_hm_dow, width = 9, height = 5, dpi = 150)

p_hm_prod <- heatmap_age_item(mv, "prod_name", "Best (545): top products by generation")
print(p_hm_prod)
ggsave("output/figures/rfm_best_heatmap_prod_by_age.png", p_hm_prod, width = 10, height = 5, dpi = 150)

p_hm_graph <- heatmap_age_item(
  mv, "graphical_appearance_name",
  "Best (545): graphical appearance by generation"
)
print(p_hm_graph)
ggsave("output/figures/rfm_best_heatmap_graphical_by_age.png", p_hm_graph, width = 10, height = 5, dpi = 150)

p_hm_col <- heatmap_age_item(
  mv, "colour_group_name",
  "Best (545): colour group by generation"
)
print(p_hm_col)
ggsave("output/figures/rfm_best_heatmap_colour_by_age.png", p_hm_col, width = 10, height = 5, dpi = 150)

# ---- Capstone extensions: trends, channels, segments (README executive summary) ----
# Monthly volume, revenue, and average order value (line-item price)
tx_by_month <- merged_data %>%
  mutate(month = floor_date(t_dat, "month")) %>%
  group_by(month) %>%
  summarise(
    line_items = n(),
    revenue = sum(price, na.rm = TRUE),
    aov = mean(price, na.rm = TRUE),
    .groups = "drop"
  )

p_monthly_revenue <- ggplot(tx_by_month, aes(x = month, y = revenue)) +
  geom_line(color = "#cc071e", linewidth = 1) +
  geom_point(color = "#cc071e", size = 0.8) +
  labs(
    title = "Monthly revenue (sum of line-item prices)",
    x = "Month",
    y = "Revenue"
  ) +
  theme_bw()
print(p_monthly_revenue)
ggsave("output/figures/monthly_revenue.png", p_monthly_revenue, width = 9, height = 4.5, dpi = 150)

p_monthly_lines <- ggplot(tx_by_month, aes(x = month, y = line_items)) +
  geom_line(color = "#cc071e", linewidth = 1) +
  labs(
    title = "Monthly purchase line items (transaction rows)",
    x = "Month",
    y = "Count"
  ) +
  theme_bw()
print(p_monthly_lines)
ggsave("output/figures/monthly_line_items.png", p_monthly_lines, width = 9, height = 4.5, dpi = 150)

# Online (2) vs in-store (1): share of line items by month
channel_month <- merged_data %>%
  mutate(
    month = floor_date(t_dat, "month"),
    channel = if_else(sales_channel_id == 1, "In-store", "Online")
  ) %>%
  count(month, channel) %>%
  group_by(month) %>%
  mutate(pct = n / sum(n)) %>%
  ungroup()

p_channel_share <- ggplot(channel_month, aes(x = month, y = pct, fill = channel)) +
  geom_area(position = "stack", alpha = 0.85) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("In-store" = "#999999", "Online" = "#cc071e")) +
  labs(
    title = "Share of line items by sales channel over time",
    x = "Month",
    y = "Share",
    fill = NULL
  ) +
  theme_bw()
print(p_channel_share)
ggsave("output/figures/channel_share.png", p_channel_share, width = 9, height = 4.5, dpi = 150)

# Customer demographics vs spend (requires original customer_id on transactions)
cust_spend <- merged_data %>%
  group_by(customer_id) %>%
  summarise(
    revenue = sum(price, na.rm = TRUE),
    orders_approx = n_distinct(interaction(t_dat, sales_channel_id, drop = TRUE)),
    .groups = "drop"
  )

demo_spend <- customers %>%
  left_join(cust_spend, by = "customer_id") %>%
  mutate(
    revenue = replace_na(revenue, 0),
    club_member_status = fct_lump_n(fct_infreq(club_member_status), n = 4)
  )

p_club_spend <- ggplot(demo_spend, aes(x = club_member_status, y = revenue)) +
  geom_boxplot(outlier.alpha = 0.2, fill = "#cc071e", alpha = 0.5) +
  scale_y_log10(labels = scales::label_number()) +
  labs(
    title = "Customer lifetime revenue by club status (log scale)",
    x = "Club member status",
    y = "Total revenue (log10)"
  ) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))
print(p_club_spend)
ggsave("output/figures/club_status_revenue.png", p_club_spend, width = 9, height = 4.5, dpi = 150)
