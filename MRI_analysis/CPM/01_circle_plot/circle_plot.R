suppressPackageStartupMessages({
  library(circlize)
  library(ggplot2)
})

script_dir <- local({
  file_arg <- "--file="
  cmd_args <- commandArgs(trailingOnly = FALSE)
  script_path <- sub(file_arg, "", cmd_args[grepl(file_arg, cmd_args)])
  if (length(script_path) > 0) {
    dirname(normalizePath(script_path))
  } else {
    frame_files <- vapply(sys.frames(), function(frame) {
      if (!is.null(frame$ofile)) frame$ofile else NA_character_
    }, character(1))
    frame_files <- frame_files[!is.na(frame_files)]
    if (length(frame_files) > 0) dirname(normalizePath(frame_files[length(frame_files)])) else getwd()
  }
})

condition_name <- "pol"
edge_sign <- "pos"
degree_threshold <- 5

edge_colors <- c(pos = "#FF2E63", neg = "#1771BF")
if (!edge_sign %in% names(edge_colors)) {
  stop("edge_sign must be 'pos' or 'neg'.")
}

edge_file <- file.path(
  script_dir,
  sprintf("connectivity_threshold_%s_binary_%s.csv", edge_sign, condition_name)
)
node_info_file <- file.path(script_dir, "circle_information.csv")
circle_output_file <- file.path(
  script_dir,
  sprintf("circle_%s_%s_plot.png", edge_sign, condition_name)
)
histogram_output_file <- file.path(
  script_dir,
  sprintf("degree_histogram_%s_%s.png", edge_sign, condition_name)
)
edge_color <- edge_colors[[edge_sign]]

edge_mat <- as.matrix(read.csv(edge_file, header = FALSE))
colnames(edge_mat) <- rownames(edge_mat) <- as.character(seq_len(nrow(edge_mat)))

node_info <- read.csv(node_info_file)
node_info$node <- as.character(node_info$node)

edge_indices <- which(edge_mat != 0 & upper.tri(edge_mat), arr.ind = TRUE)
edge_df <- data.frame(
  from = as.character(edge_indices[, 1]),
  to = as.character(edge_indices[, 2]),
  value = edge_mat[edge_indices]
)

all_edges <- data.frame(node = c(edge_df$from, edge_df$to))
degree_table <- as.data.frame(table(all_edges$node))
colnames(degree_table) <- c("node", "degree")
degree_table$node <- as.character(degree_table$node)
degree_table$degree <- as.numeric(degree_table$degree)

count_df <- as.data.frame(table(degree_table$degree))
colnames(count_df) <- c("degree", "n")
count_df$degree <- as.numeric(as.character(count_df$degree))

degree_plot <- ggplot(count_df, aes(x = degree, y = n)) +
  geom_col(fill = edge_color, color = "black", width = 0.9) +
  geom_text(aes(label = n), vjust = -0.5, size = 7) +
  scale_x_continuous(breaks = sort(unique(count_df$degree))) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(x = "Number of Edges (Degree)", y = "Count of Nodes") +
  theme_minimal(base_size = 10) +
  theme(
    axis.text.x = element_text(size = 17),
    axis.text.y = element_text(size = 17),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.title.x = element_text(size = 20, face = "bold"),
    axis.title.y = element_text(size = 20, face = "bold"),
    axis.line = element_line(color = "black", linewidth = 0.8),
    axis.ticks = element_line(color = "black")
  )

ggsave(
  filename = histogram_output_file,
  plot = degree_plot,
  width = 7,
  height = 4.5,
  dpi = 300,
  units = "in",
  bg = "white"
)

left_nodes <- as.character(1:133)
right_nodes <- as.character(268:134)
ordered_nodes <- c(right_nodes, left_nodes)
node_info <- node_info[match(ordered_nodes, node_info$node), ]

lobes_color_map <- c(
  "1" = "#FF6666",  "11" = "#FF6666",
  "2" = "#FFB347",  "12" = "#FFB347",
  "3" = "#FFF275",  "13" = "#FFF275",
  "4" = "#90EE90",  "14" = "#90EE90",
  "5" = "#6699FF",  "15" = "#6699FF",
  "6" = "#CBA6F7",  "16" = "#CBA6F7",
  "7" = "#66FFFF",  "17" = "#66FFFF",
  "8" = "#B8860B",  "18" = "#B8860B",
  "9" = "#FF8C69",  "19" = "#FF8C69",
  "10" = "#A052D3", "20" = "#A052D3"
)

gap_vals <- c(
  rep(0.45, length(right_nodes) - 1),
  4,
  rep(0.475, length(left_nodes) - 1),
  1
)
stopifnot(length(gap_vals) == length(ordered_nodes))

png(circle_output_file, width = 3000, height = 3000, res = 500)

circos.clear()
circos.par(
  gap.degree = gap_vals,
  start.degree = 270,
  cell.padding = c(0, 0, 0, 0),
  track.margin = c(0.005, 0.005)
)

factors <- factor(ordered_nodes, levels = ordered_nodes)
circos.initialize(factors = factors, xlim = c(0, 1))

circos.track(
  factors = factors,
  ylim = c(0, 1),
  track.height = 0.09,
  bg.border = NA,
  panel.fun = function(x, y) {}
)

for (lobes_id in unique(node_info$lobes_numb)) {
  sectors <- node_info$node[node_info$lobes_numb == lobes_id]
  highlight.sector(
    sectors,
    track.index = 1,
    col = lobes_color_map[as.character(lobes_id)],
    border = NA,
    text = NA
  )
}

circos.track(
  factors = factors,
  ylim = c(0, 1),
  track.height = 0.01,
  bg.border = NA,
  panel.fun = function(x, y) {
    sector.index <- CELL_META$sector.index
    lobes_val <- node_info$lobes_numb[match(sector.index, node_info$node)]
    col_val <- lobes_color_map[as.character(lobes_val)]
    circos.rect(0, 0, 1, 1, col = col_val, border = NA)
  }
)

for (edge_idx in seq_len(nrow(edge_df))) {
  from_deg <- degree_table$degree[degree_table$node == edge_df$from[edge_idx]]
  to_deg <- degree_table$degree[degree_table$node == edge_df$to[edge_idx]]
  lwd_val <- ifelse(from_deg >= degree_threshold | to_deg >= degree_threshold, 3.8, 0.5)

  circos.link(
    sector.index1 = edge_df$from[edge_idx],
    point1 = c(0.5, 0.5),
    sector.index2 = edge_df$to[edge_idx],
    point2 = c(0.5, 0.5),
    col = edge_color,
    lwd = lwd_val
  )
}

circos.clear()
dev.off()
