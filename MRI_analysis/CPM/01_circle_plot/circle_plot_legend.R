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

lobes_labels <- c(
  "1" = "Prefrontal",
  "2" = "MotorStrip",
  "3" = "Insula",
  "4" = "Parietal",
  "5" = "Temporal",
  "6" = "Occipital",
  "7" = "Limbic",
  "8" = "Cerebellum",
  "9" = "Subcortical",
  "10" = "Brainstem"
)

legend_colors <- lobes_color_map[as.character(1:10)]

par(mar = c(0, 0, 0, 0))
plot(1, type = "n", xlim = c(0, 3), ylim = c(0, 20), axes = FALSE, xlab = "", ylab = "", main = "")

for (i in 1:10) {
  rect(0, 10 - i + 0.2, 0.2, 10 - i + 0.8, col = legend_colors[i], border = "black")
  text(0.25, 10 - i + 0.5, labels = lobes_labels[as.character(i)], adj = 0, cex = 0.9)
}
