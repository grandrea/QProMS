# QProMS

QProMS is a Shiny app and R package for quantitative proteomics analysis. The current `package` branch provides a guided workflow for dataset import, experimental design setup, preprocessing, exploratory analysis, ranking, optional differential analysis, network and enrichment analysis, report generation, and session restore.

This README reflects the UI currently implemented in the `package` branch.

## Run QProMS locally

### From this repository

Open the project in R and restore the environment:

```r
renv::restore(rebuild = TRUE)
```

Then launch the app from the repo root:

```r
shiny::runApp()
```

### As an installed package

If QProMS is installed as an R package, launch it with:

```r
library(qproms)
run_qproms()
```

`run_qproms()` is defined in [R/run_qproms.R](/C:/Users/andrea.graziadei/Documents/SSU_develop/QProMS/R/run_qproms.R).

## App structure

The current top-level navigation is:

- `Home`
- `Design`
- `Preprocessing`
- `PCA`
- `Correlation`
- `Rank`
- `Network`
- `ORA`
- `GSEA`
- `Export`
- `Settings`
- `Help`

Two additional pages, `Volcano` and `Heatmap`, are inserted dynamically after a valid analysis is initialized and statistical analysis is available. They are not permanent top-level tabs in the default navbar.

## Getting started

The `Home` page offers three entry points:

1. Upload a new intensity table.
2. Restore a previously saved QProMS session from a `.rds` file.
3. Load one of the bundled example datasets.

From there, a typical analysis follows this order:

1. Load data from `Home`.
2. Review table detection and build the experimental design in `Design`.
3. Run filtering, normalization, and imputation in `Preprocessing`.
4. Explore the data with `PCA`, `Correlation`, and `Rank`.
5. If statistics are available, inspect `Volcano` and `Heatmap`.
6. Continue to `Network`, `ORA`, and `GSEA`.
7. Export tables, reports, or a saved session from `Export`.

## Supported input tables

QProMS can automatically identify these input formats:

- MaxQuant
- FragPipe
- DIA-NN
- Spectronaut
- ProteomeDiscoverer
- AlphaPept

If automatic identification does not succeed, QProMS falls back to a manual setup flow for external tables. In that case, you can:

- choose the gene/protein annotation column,
- provide a regex or keyword to filter candidate intensity columns,
- manually select the numeric intensity columns,
- choose whether intensities should be log-transformed,
- select the organism.

The current organism choices are:

- human
- mouse
- drosophila
- budding yeast
- E. coli

For detailed upload requirements, see the in-app `Help` page and the metadata definitions in [app/static/inputs_type_lists.R](/C:/Users/andrea.graziadei/Documents/SSU_develop/QProMS/app/static/inputs_type_lists.R).

## Current workflow pages

### Home

The landing page provides:

- file upload for a new analysis,
- restore from a saved `QProMS_analysis_<date>.rds` file,
- bundled example datasets,
- shortcuts to `Settings` and `Help`.

### Design

The `Design` page is the current replacement for the older upload flow described in previous README versions. It walks through:

1. input table preview,
2. table check and automatic/manual parsing,
3. experimental design editing,
4. experimental design validation,
5. workflow initialization.

After validation, QProMS builds the design table, prepares the analysis state, and moves the user into the downstream workflow.

### Preprocessing

The `Preprocessing` page includes data wrangling and quality control. The current UI exposes:

- valid-value filtering,
- peptide-based filtering where applicable,
- contaminant/reverse/site filtering where applicable,
- normalization settings,
- imputation settings,
- QC views for counts, distributions, coverage, intersections, CV, missing data, imputed distributions, and processed tables.

### PCA

The `PCA` page currently provides:

- 2D PCA visualization,
- 3D PCA visualization.

### Correlation

The `Correlation` page provides:

- a correlation heatmap,
- scatter plots,
- a data table,
- selection of Pearson, Kendall, or Spearman correlation.

### Rank

The `Rank` page provides:

- protein rank visualization,
- interactive highlighting from the table,
- ranking by sample or merged condition,
- top or bottom selection by percentage.

### Volcano

`Volcano` appears only when statistical analysis is available. The page provides:

- contrast selection,
- Welch, Student, or moderated `limma` t-test,
- paired analysis toggle,
- fold-change and adjusted p-value thresholding,
- volcano or MA plot display,
- profile plots and result table.

### Heatmap

`Heatmap` also appears only when statistical analysis is available. The page provides:

- ANOVA-based selection,
- clustering controls,
- Z-score toggle,
- cluster profile view,
- protein profile view,
- interactive results table.

### Network

The `Network` page builds interaction networks from:

- `Rank`,
- `Volcano`,
- `Heatmap`.

Current inputs and options include:

- String and/or CORUM as data sources,
- score threshold,
- force or circular layout,
- node name visibility,
- optional filtering to selected nodes.

When statistics are not available, the network input strategy is restricted to rank-based selection.

### ORA

The `ORA` page performs over-representation analysis from:

- `Rank`,
- `Volcano`,
- `Heatmap`,
- manual gene selection.

The current UI supports:

- Gene Ontology, KEGG, and WikiPathways,
- GO ontology selection,
- simplify threshold for GO,
- optional background restriction,
- adjustable alpha and multiple-testing correction,
- bar plot and table outputs.

### GSEA

The `GSEA` page supports gene set enrichment analysis using:

- intensity-based ranking,
- fold-change ranking,
- `-log10(p-value)` ranking.

The current UI supports:

- Gene Ontology, KEGG, and WikiPathways,
- GO ontology selection,
- simplify threshold for GO,
- alpha and multiple-testing correction,
- bar plots,
- enrichment plots,
- result tables.

### Export

The `Export` page is the current location for all outputs. It provides:

- download of processed result tables in `.xlsx`, `.csv`, or `.tsv`,
- optional inclusion of metadata columns in selected exports,
- HTML report generation with full or custom section selection,
- save of the full analysis session as `.rds`.

Saved sessions are written as files named like `QProMS_analysis_<date>.rds` and can be restored from `Home`.

### Settings

The `Settings` page controls:

- color palette,
- plot text size,
- plot export format (`svg` or `png`/canvas mode).

### Help

The `Help` page is an upload guide for supported software and required columns. It is the best place in the UI to verify what QProMS expects from each table format.

## Defaults and behavior

The current defaults are defined in [app/logic/R6Class_QProMS.R](/C:/Users/andrea.graziadei/Documents/SSU_develop/QProMS/app/logic/R6Class_QProMS.R). Important defaults include:

- log2 transform enabled by default,
- normalization method: `None`,
- imputation method: `mixed`,
- correlation method: `pearson`,
- rank selection defaults to top 10%,
- statistical defaults: Welch test, `BH` adjustment, fold change cutoff `1`,
- ORA defaults: database `GO`, ontology `BP`,
- GSEA defaults: database `GO`, ontology `BP`,
- plot format: `svg`,
- palette: `D`.

Several pages use an explicit `PROCESS` button. In the current app, parameter changes are applied when the user triggers processing for that page.

## Session persistence

QProMS currently uses `.rds` files for session persistence. The intended workflow is:

1. run an analysis,
2. save the session from `Export`,
3. reopen it later from `Home` using `Restore analysis session`.

Older README references to restoring analyses from generated YAML files are no longer valid for the current UI.

## Notes for contributors

- Use the `package` branch as the documentation source of truth for the current app.
- Treat the files under `app/` as the primary implementation source; `inst/app` contains packaging copies.
- If the UI changes, update this README alongside the corresponding Shiny modules and R6 defaults.
