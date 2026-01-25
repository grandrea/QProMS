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
library(UpSetR)

box::use(app/logic/R6Class_QProMS)
box::reload(R6Class_QProMS)
box::use(app/static/inputs_type_lists)
box::use(app/static/contaminants)

r6 <- R6Class_QProMS$QProMS$new()
# r6$loading_data(input_path = "app/static/proteinGroups.txt", input_name = "test")
r6$loading_data(input_path = "/Users/bedin.fabio/Documents/dataset_qproms/Proteome_Discoverer.txt", input_name = "test")
# a <- r6$loading_parameters(input_path = "/Users/bedin.fabio/Desktop/QProMS_parameters_2024-09-04.yaml", r6)
msg <- r6$identify_table_type()
r6$create_summary_table()
r6$organism <- "human"
r6$make_expdesign(intensity_type = "Abundance:")
# a <- tibble(
#   "condition" = c("xl", "xl", "xl", "non", "non", "non"),
#   "key" = c(
#     "XL_1 MaxLFQ Intensity",
#     "XL_2 MaxLFQ Intensity",
#     "XL_3 MaxLFQ Intensity",
#     "nonXL_1 MaxLFQ Intensity",
#     "nonXL_2 MaxLFQ Intensity",
#     "nonXL_3 MaxLFQ Intensity"
#   )
# )
a <- tibble(
  "condition" = c(
    "control",
    "control",
    "control",
    "treated",
    "treated",
    "treated"
  ),
  "key" = c(
    "Abundance: F1: Control, Control, 1",
    "Abundance: F2: Control, Control, 2",
    "Abundance: F3: Control, Control, 3",
    "Abundance: F4: Sample, Treated, 4",
    "Abundance: F5: Sample, Treated, 5",
    "Abundance: F6: Sample, Treated, 6"
  )
)
r6$validate_expdesign(a)
r6$add_replicate_and_label(a)
r6$preprocessing()
r6$protein_rank_target <- r6$expdesign$label[1]
r6$shiny_wrap_workflow()
r6$plot_pca(FALSE)
r6$contrasts <- "treated_vs_control"
r6$stat_uni_test(test = "treated_vs_control", fc = 1, alpha = 1, p_adj_method = "BH", paired_test = FALSE, test_type = "welch")
a <- r6$plot_volcano(tests = "treated_vs_control", gene_names_marked = NULL, TRUE, TRUE)
# trelliscope::view_trelliscope(a)
# r6$clusters_number <- 3
# r6$stat_anova(alpha = 0.05, p_adj_method = "BH")
# r6$make_nodes(list_from = "univariate", focus = "xl_vs_non", "down")
# r6$organism <- "human"
# r6$make_edges("string")
# r6$plot_heatmap(order_by_expdesing = FALSE)
