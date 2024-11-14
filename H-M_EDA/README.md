# H&M Fashion Retail Data Analysis: Customer Insights and Product Trends

## Project Overview
H&M, founded in 1947, is a multinational fashion retailer that offers affordable clothing, accessories, and homeware. 

This project conducts an exploratory data analysis (EDA) on H&M's transactional data, aiming to uncover insights into customer purchasing behavior, product popularity, and sales trends. The goal is to provide a well-rounded view of the data, which can support data-driven decisions in marketing, inventory planning, and customer engagement.

## Data Structure & Initial Checks
The datasets are sourced from the [H&M Personalized Fashion Recommendations competition on Kaggle](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data), including:
- **Articles**: Detailed product information, including categories and descriptions.
- **Customers**: Demographic data on individual customers.
- **Transactions**: Records of customer purchases.

### Articles data description:

| Field                       | Description                                                              |
|-----------------------------|--------------------------------------------------------------------------|
| `article_id`                | A unique identifier for each article                                    |
| `product_code`, `prod_name` | Unique identifier and name for each product (not the same)              |
| `product_type`, `product_type_name` | Group identifier and name for each product type               |
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

* customer_id : A unique identifier of every customer
* FN : 1 or missed
* Active : 1 or missed
* club_member_status : Status in club
* fashion_news_frequency : How often H&M may send news to customer
* age : The current age
* postal_code : Postal code of customer

### Transactions field description:

* t_dat : Purchase date
* day_of_week: Purchase day of week (Monday: 1, Tue: 2, …, Sun: 7) (This is a new field we added on top of the orignal dataset)
* customer_id : A unique identifier of every customer (in customers table)
* article_id : A unique identifier of every article (in articles table)
* price : Purchase price
* sales_channel_id : 1 or 2 (1 is store and 2 is online, ref: https://www.kaggle.com/c/h-and-m-personalized-fashion-recommendations/discussion/305952#1684481) => It is transformed into sales_channel field with 1 is In-store and 2 is Online

## Executive Summary
### 1. What are the key purchasing trends amongst customers, and how do they change over time?
### 2. Where are we experiencing the most growth in sales and customer engagement, and which segments contribute to this growth?
### 3. How are different customer segments and product categories performing, and what drives higher engagement and revenue?
### 4. What key metrics should we track to assess sales performance and customer loyalty effectively?
