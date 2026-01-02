library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(tibble)
library(echarts4r)
library(trelliscope)
library(rbioapi)
library(org.Hs.eg.db)
library(clusterProfiler)

box::use(app/logic/R6Class_QProMS)
box::reload(R6Class_QProMS)
box::use(app/static/inputs_type_lists)
box::use(app/static/contaminants)

r6 <- R6Class_QProMS$QProMS$new()
# r6$loading_data(input_path = "app/static/proteinGroups.txt", input_name = "test")
r6$loading_data(input_path = "/Users/bedin.fabio/Documents/dataset_qproms/combined_protein.tsv", input_name = "test")
# a <- r6$loading_parameters(input_path = "/Users/bedin.fabio/Desktop/QProMS_parameters_2024-09-04.yaml", r6)
msg <- r6$identify_table_type()
r6$create_summary_table()
r6$make_expdesign("MaxLFQ Intensity")
a <- tibble(
  "condition" = c("xl", "xl", "xl", "non", "non", "non"),
  "key" = c(
    "XL_1 MaxLFQ Intensity",
    "XL_2 MaxLFQ Intensity",
    "XL_3 MaxLFQ Intensity",
    "nonXL_1 MaxLFQ Intensity",
    "nonXL_2 MaxLFQ Intensity",
    "nonXL_3 MaxLFQ Intensity"
  )
)
r6$validate_expdesign(a)
r6$add_replicate_and_label(a)
r6$preprocessing()
r6$protein_rank_target <- r6$expdesign$label[1]
r6$shiny_wrap_workflow()
r6$plot_pca(FALSE)
r6$organism <- "human"
r6$contrasts <- "xl_vs_non"
r6$stat_uni_test(test = "xl_vs_non", fc = 1, alpha = 0.05, p_adj_method = "BH", paired_test = FALSE, test_type = "welch")
# a <- r6$plot_volcano(tests = "xl_vs_non", gene_names_marked = NULL, TRUE, TRUE)
# trelliscope::view_trelliscope(a)
# r6$clusters_number <- 3
# r6$stat_anova(alpha = 0.05, p_adj_method = "BH")
# r6$make_nodes(list_from = "univariate", focus = "xl_vs_non", "down")
# r6$organism <- "human"
# r6$make_edges("string")
# r6$plot_heatmap(order_by_expdesing = FALSE)

r6$go_ora(
  list_from = "univariate",
  database = "WikiPathways",
  focus = c("xl_vs_non_up", "xl_vs_non_down"),
  ontology = r6$go_ora_term,
  simplify_thr = r6$go_ora_simplify_thr,
  alpha = r6$go_ora_alpha,
  p_adj_method = r6$go_ora_p_adj_method,
  background = r6$go_ora_background
)


r6$print_ora_table(arranged_with = "fold_enrichment")
r6$ora_table
r6$plot_ora_single(focus = "xl_vs_non_down", arrange = "fold_enrichment", show_category = 10)

names(r6)
get(class(r6))
names(get(class())$public_fields)
r6$public_fields()

names(r6$public_fields)

R6_extract_values <- function(r6class){
  tmp <- sapply(r6class, class)
  slots <- tmp[ !tmp %in% c("environment", "function")]
  res <- list()
  for (i in names(slots)) {
    if ("R6" %in% class(r6class[[i]])) {
      res[[i]]  <- R6_extract_values(r6class[[i]])
    }else{
      res[[i]] <- r6class[[i]]
    }
  }
  return(res)
}
R6_extract_values(r6)

extract_params_values <- function(r6class) {
  tmp <- sapply(r6class, class)
  slots <- tmp[!tmp %in% c("environment", "function")]
  imap(slots, ~ {
    if ("R6" %in% class(r6class[[.y]])) {
      R6_extract_values(r6class[[.y]])
    } else {
      r6class[[.y]]
    }
  })
}

a <- extract_params_values(r6)

tmp <- sapply(r6, class)
tmp <- map(tmp, pluck, 1)
tmp <- tmp[!tmp %in% c("environment", "function", "tbl_df", "data.table", "hclust", "matrix")]
tmp$raw_data <- r6$raw_data
imap(slots, ~ {
  if ("R6" %in% class(r6class[[.y]])) {
    R6_extract_values(r6class[[.y]])
  } else {
    r6class[[.y]]
  }
})
aa <- r6$save_params_as_list(r6)

aa$pdb_database <- "pippo"

r6$loading_parameters(r6, parameters_list = aa)

r6$pdb_database

a <- c("Prepocessing", "PCA", "Correlation", "Rank", "Volcano", "Heatmap", "Network", "ORA", "GSEA")
b <- c("PCA", "Correlation", "Rank", "Volcano", "Heatmap")

check_terms <- function(input_vector) {
  
  
  return(result_list)
}

check_terms(b)
