# H&M Transaction Data Analysis: Customer Insights and Product Trends

**Project Write-Up**  
This document presents an exploratory analysis of H&M’s public retail transaction extract. It is organized to align with the case study framework: **Ask, Prepare, Process, Analyze, Share, and Act**.

---

## Abstract

This project analyzes purchasing behavior using the **H&M Personalized Fashion Recommendations** competition data published on Kaggle by H&M Group. The objective is to support marketing, merchandising, and channel strategy with **evidence on product and price patterns**, **in-store versus online mix over time**, and **customer engagement attributes** available in the extract. The work uses **article**, **customer**, and **transaction** tables in **R** for analysis and visualization. Findings are reported at **line-item granularity** (with explicit limitations: no campaign attribution, margins, returns, or raw geography). Outputs include **documented code**, **summary statistics and charts**, and a **monitoring-oriented metric set** for ongoing decision support.

---

## 1. Introduction and Business Context

H&M is a global fashion retailer operating across physical stores and digital channels. In competitive retail and e-commerce environments, leadership increasingly relies on **transaction-level evidence** to align **assortment**, **pricing**, **channel investment**, and **customer engagement** initiatives.

This capstone adopts a **consulting-style framing**: the analytical question is how to use H&M’s **shared competition dataset**—rather than internal enterprise systems—to characterize **what customers buy**, **at what price points**, **through which channels**, and **what the customer master file suggests about club and communication preferences**. The **Chief Marketing Officer** and adjacent stakeholders (merchandising, marketing operations) are the notional consumers of the results; the deliverable is **decision-support insight**, not a production recommendation engine.

**Scope.** The analysis is **exploratory**. It produces reproducible summaries and visualizations. Building and deploying a **personalized recommender** lies outside scope.

**Success Criteria.** The engagement is successful if stakeholders receive (1) **defensible descriptions** of product and price behavior, (2) **time-based views** of demand and revenue-style totals at line-item level, (3) a clear view of **online versus in-store share** over time, and (4) a concise set of **metrics to monitor**, each tied to calculations performed in this repository.

---

## 2. Problem Framing (Ask)

### 2.1 Business Task

The central task is to quantify patterns in **category mix**, **paid prices**, **sales channel**, and **customer attributes** (club status, fashion-news preferences, age), and to communicate **limitations** where fields are missing, hashed, or not representative of true geography.

### 2.2 Key Analytical Dimensions

| Dimension | Focus |
|-----------|--------|
| Product and price | Category structure (`index_name`, `product_group_name`, product types), central tendency and dispersion of price |
| Channel | Share of activity in-store (`sales_channel_id` = 1) versus online (= 2) over the calendar |
| Customer engagement | Club membership, opt-in to fashion news (after recoding sparse categories), age distribution, spend aggregated to customer |
| Data governance | Hashed identifiers, dominant placeholder postal code, absence of promotion and margin fields—conclusions remain bounded accordingly |

### 2.3 Data Requirements

**Appropriate inputs** are the competition’s **transaction file** (one row per purchased article line), **article master** (product hierarchy and attributes), and **customer table** (demographics and club fields), linked by `article_id` and `customer_id`.

**Source.** [H&M Personalized Fashion Recommendations on Kaggle](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data).

### 2.4 Stakeholders and Audience

| Role | Interest |
|------|-----------|
| Executive marketing leadership | Credible trends for channel and engagement narrative |
| Merchandising / product | Category mix and price bands |
| Marketing / CRM | Club and opt-in signals (interpreted under privacy constraints) |
| Analytics delivery | Reproducibility, transparent scope, alignment between narrative and code |

**Primary Audience** for the storyline: business review or capstone presentation (**insights first**, supporting charts second). **Secondary Audience:** instructors or technical reviewers evaluating methodology via this document and the linked scripts.

### 2.5 Metrics Computed in Scope

| Theme | Measures | Use |
|-------|----------|-----|
| Demand | Monthly line-item count; sum of prices (revenue-style); mean line price | Trend in activity and ticket size at line level |
| Channel | Monthly share of line items by channel | Digital versus store evolution |
| Product | Article counts and mean paid price by hierarchy | Assortment and positioning |
| Customer file | Club status, recoded fashion-news frequency, age | Engagement context |
| Customer spend | Total price per customer; approximate shopping occasions (distinct purchase date × channel) | Relate demographics and club to spend |

Metrics such as **order-level AOV** (without an explicit order key), **campaign ROI**, **SKU quantity sold** (no quantity column in the standard extract), and **true regional sales** are **not** claimed from this dataset alone.

### 2.6 How Results Inform Decisions

The analysis supports **prioritization discussions** on assortment and price architecture, **channel mix** based on observed share trends, **realistic expectations** for what the customer file can support for targeting narratives, and a **baseline KPI set** until richer systems data (promotions, margins, returns, fulfillment) becomes available.

---

## 3. Data Sources and Preparation (Prepare)

### 3.1 Location and Organization

Primary files (obtained from the Kaggle competition bundle and stored locally under `data/` when running the project):

- `articles.csv` — product metadata  
- `customers.csv` — customer attributes  
- `transactions_train.csv` — dated purchase lines with price and channel  

Relationships: transactions join to articles on `article_id` and to customers on `customer_id`.

The full Kaggle download also includes an **`images/`** tree (and often **`images.zip`**) of product photos for the competition’s recommendation / computer-vision track. **This repository’s R script does not read those files**; analysis uses the CSVs only. You may still use a curated subset of images in a **slide deck** or future work; they are **large**, so they are listed in **`.gitignore`** for typical GitHub workflows.

### 3.2 Credibility, Bias, and Limitations

The extract is **published by H&M Group for a public competition**. It is **appropriate for academic and portfolio analysis** under Kaggle’s competition terms. It is **not** a substitute for full internal operational data. **Temporal coverage** should be validated against the observed date range in `t_dat`; broad claims about specific external shocks (for example pandemic effects) require empirical support in the charts.

**Bias and Interpretation.** Online and in-store behavior in the extract reflect **the sample and time window**, not necessarily the full global business. **Postal codes are hashed**; a highly frequent value behaves as a **missing or default bucket**, not a single real market.

### 3.3 Privacy, Licensing, and Accessibility

Identifiers are **hashed**. Reporting stays at **aggregated or non-identifying** levels suitable for public artifacts. **Licensing** is governed by the **Kaggle competition rules** and dataset documentation. This write-up and the repository serve as the **primary narrative and methodology record** for stakeholders who do not execute the code themselves.

### 3.4 Integrity Checks (Summary)

The analytical workflow includes **duplicate checks** on customers, **validation of join keys**, **inspection of missing values** (for example age), **type consistency** for identifiers (character versus numeric), and **exploratory plots** to detect outliers and structural anomalies (for example price by category).

---

## 4. Methodology (Process and Analyze)

### 4.1 Tools

| Tool | Role |
|------|------|
| **R** (`H-M_Case-Study/H-M_Case-Study.R`) | Cleaning, transformation, aggregation, and visualization (dplyr, ggplot2, related packages) |
| **Git** | Version control for code and documentation |

### 4.2 Processing and Documentation

Transformations are **documented in script comments** and include, among others: **consistent ID types**, **derived grouping** for basket-like structure where applicable, **price scaling** consistent with community-documented Kaggle practice, **recoding** of sparse fashion-news categories, and **date parsing** for time series. Cleaning steps are **repeatable** from the source CSVs.

### 4.3 Analytical Approach

Data are organized in a **tidy, relational** form: one row per transaction line with linked dimensions. Analysis proceeds by **aggregation** (counts, means, sums by category, channel, and time) and **visual comparison** (distributions, boxplots, line charts, channel share over time). **RFM** scores (quintile-based **R**ecency, **F**requency, **M**onetary on scaled line prices) and **named segments** from the original team notebook (for example best **545**, loyal **54x**, at-risk, new, occasional) support **priority-customer** views. **Share** takes the form of this report, **exported figures** from the R workflow, and optionally a **slide deck** aligned with Section 5.

---

## 5. Findings (Analyze)

### 5.1 Purchasing Trends Over Time

**Assortment.** Ladieswear represents the largest share of articles in the catalog by index; Sport represents the smallest. Garment-group structure shows strong representation of jersey-oriented categories for women’s and children’s indices.

**Price Dynamics.** For product groups with the highest average paid prices (for example footwear and full-body garments), **mean price by month** exhibits month-to-month movement; visualizations include uncertainty-style bands around those means for context.

**Volume and Revenue-Style Trends.** Aggregating all lines by calendar month yields series for **total line-item count**, **sum of prices** (revenue-style at line level), and **average line price**. These series are the primary evidence for **seasonality or trend** in overall purchasing activity.

### 5.2 Channel and Engagement Signals

**Channel.** Each row carries `sales_channel_id` (in-store versus online). **Monthly share of line items by channel** indicates how digital activity evolves relative to stores within the extract—the strongest internal signal for “where growth appears” absent external channel definitions.

**Segments.** Combining **club member status**, **age**, and **fashion news** frequency (after consolidating non-substantive values) with **customer-level spend** highlights differences between **ACTIVE** members and opt-in groups (**Regularly** / **Monthly** news) versus the broader base.

### 5.3 Product Categories and Customer Profiles

**Categories.** Mean paid price differs materially by **index** and **product group** (for example higher means in Ladieswear indexes and footwear; lower in categories such as stationery). **Boxplots** by product group—and within accessories by product type—show **dispersion and outliers** (for example bags).

**Customers.** The age distribution concentrates in the **low twenties**; **ACTIVE** club status is common. **Postal code** concentration on a single value indicates a **data-quality pattern** rather than a true geographic market; **regional strategy conclusions are not supported** from this field.

**Spend and Club Status.** Merging **lifetime spend** (sum of line prices) to **club_member_status**, with appropriate scale transforms for skew, supports comparison of **spend distributions** across status categories.

### 5.4 RFM Segmentation and Deep Dive (Best Customers)

**Method.** **Recency** is days from each customer’s last purchase to the day after the global max transaction date; **frequency** is the count of **distinct purchase dates**; **monetary** is **sum of scaled line-item prices**. **R**, **F**, and **M** are **quintile scores** (character digits 1–5), with **R = 5** denoting the **most recent** purchasers—consistent with the course notebook’s `qcut` labeling. **RFM_Segment** is the three-digit concatenation (for example `545`).

**Named Segments** follow the team definitions: **best** (`545`), **loyal** (pattern `54x`), **big spender** (high **M**, low **R** and **F**), **at-risk** (low **R**, high **F** and **M**), **new** (`511`, `512`), and **occasional** (mid **R** with **F** in {2, 3}). Segment **sizes** print when the R script runs.

**Deep Dive on the Best Segment (`545`).** Plots compare **product group** mix, **in-store versus online** share of line items (including versus **all customers**), and **age density** versus the full customer file—evidence for marketing and CRM prioritization, not a live campaign list.

---

## 6. Recommendations, Monitoring, and Next Steps (Act and Share)

### 6.1 Recommended Metrics to Track

| Area | Metric | Rationale |
|------|--------|-----------|
| Sales health | Monthly revenue-style total, line-item count, mean line price | Core demand and ticket-size indicators at extractable granularity |
| Channel | Online versus in-store share of line items over time | Digital mix and store reliance |
| Product | Revenue-style totals and line-item counts by product group / index | Assortment performance (no separate SKU quantity column in standard files) |
| Customer | Active club rate, fashion-news opt-in mix, age distribution | Engagement and base composition |
| Loyalty (approximate) | Revenue per customer; distinct purchase dates × channel as a coarse activity proxy | Depth of relationship where order IDs are not native |
| RFM / segments | **R**, **F**, **M** quintiles; segment counts; best-segment product and channel mix | Prioritization and messaging tests for high-value and at-risk cohorts |

These indicators should be **recomputed on a consistent definition** after major campaigns or assortment changes so comparisons remain valid.

### 6.2 Communication of Results

Deliverables for this project include: **this written report** (README), **reproducible R code**, **graphics** produced in the R pipeline, and **oral or slide-based presentation** suitable for a non-technical executive audience, with technical detail deferred to the appendix and scripts. For slides, **charts** under `output/figures/` are the primary visuals; optional **product photos** from the Kaggle `images/` bundle can illustrate categories or example articles if you curate a small set.

### 6.3 Suggested Extensions (Additional Data and Analysis)

Future phases would benefit from **promotion and campaign identifiers**, **margin and cost**, **returns and stockouts**, **true geographic or store attributes**, and **stable order identifiers** for order-level AOV and funnel metrics—none of which are fully represented in the competition tables as used here.

---

## 7. Repository Structure

| Path | Contents |
|------|----------|
| `README.md` | This write-up (methodology, findings, run instructions) |
| `.gitignore` | Excludes large/local-only assets and R session files (see below) |
| `H-M_Case-Study/H-M_Case-Study.R` | End-to-end analysis and visualizations |
| `DSCI599/` | Optional reference copy of the original team Jupyter notebook (not required to run the R analysis) |
| `data/` | Competition CSVs (download from Kaggle if not present; often kept out of Git due to size) |
| `output/README.md` | Note on where figures are written |
| `output/figures/` | PNG exports for capstone and RFM charts (generated when you run the R script; `.gitkeep` preserves the folder in Git) |

**Dataset reference:** [Kaggle — H&M Personalized Fashion Recommendations](https://www.kaggle.com/competitions/h-and-m-personalized-fashion-recommendations/data)

### Git, File Size, and What Stays Local

- **`data/*.csv`** — The transaction file in particular is **very large**. For GitHub, keep CSVs **local** and document the Kaggle link; uncomment the `data/` lines in **`.gitignore`** if you want Git to stop tracking them (or never add them).
- **`images/`**, **`images.zip`** — Kaggle product photos; **not** used by `H-M_Case-Study.R`; **gitignored** by default because of size.
- **R session noise** — **`.gitignore`** excludes `.RData`, `.RDataTmp`, `.Rhistory`, `.Rapp.history`, `Rplots.pdf`, `*.Rout`, and RStudio user folders. None of these are needed to reproduce the analysis.
- **`output/figures/*.png`** — You can **commit** a subset for a portfolio view on GitHub, or **regenerate** only locally; both patterns are common.
- **`H-M_Case-Study/R Console.txt`** — Ignored as a scratch log, not a source file.

### Running the Analysis

1. Place `articles.csv`, `customers.csv`, and `transactions_train.csv` in **`data/`** (from the Kaggle bundle).
2. Install R packages used in the script (for example **tidyverse**, **lubridate**, **gridExtra**, **scales**).
3. Set the R **working directory to the repository root** (the folder that contains `data/` and `H-M_Case-Study/`). In RStudio: *Session → Set Working Directory → To Project Directory* when the project is opened at the repo root, or run the script from a shell:
   ```bash
   cd /path/to/H-M
   Rscript H-M_Case-Study/H-M_Case-Study.R
   ```
4. If you source the script from a session whose working directory is **`H-M_Case-Study/`**, the script moves up one level automatically; if `data/` is still not found, set the working directory to the repo root manually.
5. After a successful run, portfolio-ready figures appear under **`output/figures/`**, including **trends** (`monthly_revenue.png`, `monthly_line_items.png`, `channel_share.png`, `club_status_revenue.png`) and **RFM / segmentation** (marginal score plots: `rfm_r_f_m_bars.png`, `rfm_score_distribution.png`; segment grids: `rfm_segments_age_hist_grid.png`, `rfm_segments_generation_facets.png`, `rfm_segments_dow_facets.png`; earlier RFM exports: `rfm_segment_top20.png`, `rfm_best_product_groups.png`, `rfm_best_channel_share.png`, `rfm_best_vs_all_channel.png`, `rfm_best_vs_all_age_density.png`; **Step 4** parity: `rfm_best_vs_all_index_group_pies.png`, `rfm_best_garment_by_index_stacked.png`, `rfm_best_vs_all_ladieswear_sections.png`, `rfm_best_seasonality_month.png`, `rfm_best_price_by_age_group.png`, `rfm_best_heatmap_dow_by_age.png`, `rfm_best_heatmap_prod_by_age.png`, `rfm_best_heatmap_graphical_by_age.png`, `rfm_best_heatmap_colour_by_age.png`). Earlier exploratory plots in the script still render in the graphics device but are not saved to disk by default.

---

## Appendix: Field Reference

### A.1 Articles

| Field | Description |
|-------|-------------|
| `article_id` | Unique article identifier |
| `product_code`, `prod_name` | Product identifier and name (distinct concepts) |
| `product_type_no`, `product_type_name` | Product type identifier and name |
| `product_group_name` | Broader product grouping |
| `graphical_appearance_no`, `graphical_appearance_name` | Graphic style identifier and name |
| `colour_group_code`, `colour_group_name` | Colour group identifier and name |
| `perceived_colour_value_id`, `perceived_colour_value_name`, `perceived_colour_master_id`, `perceived_colour_master_name` | Additional colour attributes |
| `department_no`, `department_name` | Department identifier and name |
| `index_code`, `index_name` | Commercial index identifier and name |
| `index_group_no`, `index_group_name` | Index group identifier and name |
| `section_no`, `section_name` | Section identifier and name |
| `garment_group_no`, `garment_group_name` | Garment group identifier and name |
| `detail_desc` | Text description of the article |

### A.2 Customers

| Field | Description |
|-------|-------------|
| `customer_id` | Unique customer identifier |
| `FN` | Flag (1 or missing) |
| `Active` | Activity flag (1 or missing) |
| `club_member_status` | Club enrollment status |
| `fashion_news_frequency` | Stated frequency of fashion communications |
| `age` | Customer age |
| `postal_code` | Hashed / tokenized postal field in the competition data |

### A.3 Transactions

| Field | Description |
|-------|-------------|
| `t_dat` | Purchase date |
| `customer_id` | Customer key (links to customers) |
| `article_id` | Article key (links to articles) |
| `price` | Line-item price (scaled per project methodology; see R script) |
| `sales_channel_id` | 1 = in-store, 2 = online |
