# H&M Fashion Retail Data Analysis: Customer Insights and Product Trends

## Project Overview
H&M, founded in 1947, is a multinational fashion retailer that offers affordable clothing, accessories, and homeware. 

This project conducts an exploratory data analysis (EDA) on H&M's transactional data, aiming to uncover insights into customer purchasing behavior, product popularity, and sales trends. The goal is to provide a well-rounded view of the data, which can support data-driven decisions in marketing, inventory planning, and customer engagement.

## Data Structure & Initial Checks
The datasets are sourced from the [H&M Personalized Fashion Recommendations competition on Kaggle](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data), including:
- **Articles**: Detailed metadata for each article_id available for purchase.
- **Customers**: Metadata for each customer_id in dataset.
- **Transactions**: Consists of the purchases of each customer for each data, as well as additional information. 

### Articles data description:

| Field                       | Description                                                              |
|-----------------------------|--------------------------------------------------------------------------|
| `article_id`                | A unique identifier for each article                                    |
| `product_code`, `prod_name` | Unique identifier and name for each product (not the same)              |
| `product_type_no`, `product_type_name` | Group identifier and name for each product type               |
| `product_group_name` | Name of the broader group of the product|
| `graphical_appearance_no`, `graphical_appearance_name` | Graphics group identifier and name       |
| `colour_group_code`, `colour_group_name` | Color group identifier and name                           |
| `perceived_colour_value_id`, `perceived_colour_value_name`, `perceived_colour_master_id`, `perceived_colour_master_name` | Additional color information      |
| `department_no`, `department_name` | Unique identifier and name for each department                |
| `index_code`, `index_name`  | Unique identifier and name for each index                               |
| `index_group_no`, `index_group_name` | Group identifier and name for indices                       |
| `section_no`, `section_name` | Unique identifier and name for each section                            |
| `garment_group_no`, `garment_group_name` | Unique identifier and name for each garment group        |
| `detail_desc`               | Detailed description of the article                                     |


### Customers data description:

| Field                     | Description                                                              |
|---------------------------|--------------------------------------------------------------------------|
| `customer_id`             | A unique identifier for each customer                                   |
| `FN`                      | Flag indicator: 1 or missing                                            |
| `Active`                  | Flag indicating active status: 1 or missing                             |
| `club_member_status`      | Status of customer in the club                                          |
| `fashion_news_frequency`  | Frequency at which H&M may send news to the customer                    |
| `age`                     | Current age of the customer                                             |
| `postal_code`             | Customer's postal code                                                  |

### Transactions field description:

| Field                | Description                                                                 |
|----------------------|-----------------------------------------------------------------------------|
| `t_dat`              | Purchase date                                                              |
| `customer_id`        | Unique identifier for each customer (linked to `customer_id` in Customers) |
| `article_id`         | Unique identifier for each article (linked to `article_id` in Articles)    |
| `price`              | Purchase price                                                             |
| `sales_channel_id`   | Sales channel: 1 = In-store, 2 = Online                                    |

## Executive Summary
### 1. What are the key purchasing trends amongst customers, and how do they change over time?
### 2. Where are we experiencing the most growth in sales and customer engagement, and which segments contribute to this growth?
### 3. How are different customer segments and product categories performing, and what drives higher engagement and revenue?
### 4. What key metrics should we track to assess sales performance and customer loyalty effectively?
