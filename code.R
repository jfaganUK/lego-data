# setwd("~/Developer/lego-data")

library(ggplot2)
library(ggthemes)
library(png)
library(gridExtra)
library(grid)
library(cowplot)

#==========================================================
# Initialize data
#==========================================================
sets = read.csv("sets.csv")
themes = read.csv("themes.csv")
inventories = read.csv("inventories.csv")
inventory_parts = read.csv("inventory_parts.csv")
parts = read.csv("parts.csv")
part_categories = read.csv("part_categories.csv")
colors = read.csv("colors.csv")
elements = read.csv("elements.csv")

# Traverse themes tree to get root theme for each set
sets$theme_name = ""
theme_names = c()
for (theme_id in sets$theme_id) {
  theme_subset = subset(themes, themes$id == theme_id)
  while(!is.na(theme_subset$parent_id)) {
    theme_subset = subset(themes, themes$id == theme_subset$parent_id)
  }
  theme_names = c(theme_names,theme_subset$name)
}
sets$theme_name = theme_names
sets$theme_name[which(sets$theme_name == "Universal Building Set")] = "UBS"
sets$theme_name[which(sets$theme_name == "Educational and Dacta")] = "E&D"
sets$theme_name[which(sets$theme_name == "Super Heroes Marvel")] = "Marvel"
sets$theme_name[which(sets$theme_name == "Super Heroes DC")] = "DC"
sets$theme_name[which(sets$theme_name == "Collectible Minifigures")] = "Minifigures"
sets$theme_name[which(sets$theme_name == "Legoland Parks")] = "Legoland"

sets$theme_name[which(sets$theme_name == "DC Super Hero Girls")] = "DC"
sets$theme_name[which(sets$theme_name == "Disney Princess")] = "Disney"
sets$theme_name[which(sets$theme_name == "Disney's Mickey Mouse")] = "Disney"
sets$theme_name[which(sets$theme_name == "Super Heroes DC")] = "DC"

# Some aggregations
sets$count = 1

#==========================================================
# Aggregations
#==========================================================

#--------------------------------------
# Aggregate by Theme
#--------------------------------------
num_sets_for_theme = aggregate(
  sets$count,
  by = list(
    theme_name = sets$theme_name
  ),
  sum
)
num_sets_for_theme = num_sets_for_theme[order(-num_sets_for_theme$x), ]

num_parts_for_theme = aggregate(
  sets$num_parts,
  by = list(
    theme_name = sets$theme_name
  ),
  sum
)
num_parts_for_theme = num_parts_for_theme[order(-num_parts_for_theme$x), ]

top_themes = intersect(
  num_sets_for_theme$theme_name[1:40],
  num_parts_for_theme$theme_name[1:40]
)
top_themes

#--------------------------------------
# Aggregate by Year
#--------------------------------------
num_sets_for_year = aggregate(
  sets$count,
  by = list(
    year = sets$year
  ),
  sum
)

num_parts_for_year = aggregate(
  sets$num_parts,
  by = list(
    year = sets$year
  ),
  sum
)

#--------------------------------------
# Aggregate by Year and Theme
#--------------------------------------
num_sets_for_year_and_theme = aggregate(
  sets$count,
  by = list(
    theme_name = sets$theme_name,
    year = sets$year
  ),
  sum
)

num_parts_for_year_and_theme = aggregate(
  sets$num_parts,
  by = list(
    theme_name = sets$theme_name,
    year = sets$year
  ),
  sum
)

#--------------------------------------
# Merge themes, count, parts
#--------------------------------------

merged_theme_count_parts = merge(
  num_sets_for_theme,
  num_parts_for_theme,
  by = "theme_name"
)

colnames(merged_theme_count_parts) = c(
  "theme_name",
  "num_sets",
  "num_parts"
)

merged_theme_count_parts$parts_per_set = merged_theme_count_parts$num_parts / merged_theme_count_parts$num_sets

#==========================================================
# Join datasets
#==========================================================

inv_parts_color = merge(
  inventory_parts, 
  colors, 
  by.x = "color_id",
  by.y = "id"
)

inv_parts_color = merge(
  inv_parts_color,
  inventories,
  by.x = "inventory_id",
  by.y = "id"
)

set_inv_parts_color = merge(
  inv_parts_color,
  sets,
  by.x = "set_num",
  by.y = "set_num"
)

#==========================================================
# PLOT
#==========================================================

#--------------------------------------
# Aggregate parts and colors by themes and years
#--------------------------------------

agg_theme_color_parts_count = aggregate(
  set_inv_parts_color$quantity,
  by = list(
    set_inv_parts_color$theme_name,
    set_inv_parts_color$name.x,
    set_inv_parts_color$rgb
  ),
  sum
)
colnames(agg_theme_color_parts_count) = c(
  "theme_name",
  "color_name",
  "rgb",
  "count"
)

agg_year_color_parts_count = aggregate(
  set_inv_parts_color$quantity,
  by = list(
    set_inv_parts_color$year,
    set_inv_parts_color$rgb
  ),
  sum
)
colnames(agg_year_color_parts_count) = c(
  "year",
  "rgb",
  "count"
)

#--------------------------------------
# Determine which themes to plot
#--------------------------------------

parent_themes = subset(themes, is.na(themes$parent_id))
large_themes = subset(num_sets_for_theme, num_sets_for_theme$x >= 50)
large_themes = large_themes[order(large_themes$theme_name), ]
large_themes = large_themes[!large_themes$theme_name == "4 Juniors", ]
large_themes = large_themes[!large_themes$theme_name == "Adventurers", ]
large_themes = large_themes[!large_themes$theme_name == "Belville", ]
large_themes = large_themes[!large_themes$theme_name == "Books", ]
large_themes = large_themes[!large_themes$theme_name == "Bulk Bricks", ]
large_themes = large_themes[!large_themes$theme_name == "Clikits", ]
large_themes = large_themes[!large_themes$theme_name == "Dimensions", ]
large_themes = large_themes[!large_themes$theme_name == "Fabuland", ]
large_themes = large_themes[!large_themes$theme_name == "Freestyle", ]
large_themes = large_themes[!large_themes$theme_name == "Hero Factory", ]
large_themes = large_themes[!large_themes$theme_name == "Juniors", ]
large_themes = large_themes[!large_themes$theme_name == "Mixels", ]
large_themes = large_themes[!large_themes$theme_name == "Other", ]
large_themes = large_themes[!large_themes$theme_name == "Nexo Knights", ]
large_themes = large_themes[!large_themes$theme_name == "Promotional", ]
large_themes = large_themes[!large_themes$theme_name == "Racers", ]
large_themes = large_themes[!large_themes$theme_name == "Scala", ]
large_themes = large_themes[!large_themes$theme_name == "Service Packs", ]
large_themes = large_themes[!large_themes$theme_name == "Seasonal", ]
large_themes = large_themes[!large_themes$theme_name == "E&D", ]
large_themes = large_themes[!large_themes$theme_name == "UBS", ]
large_themes = large_themes[!large_themes$theme_name == "Sports", ]

#--------------------------------------
# Plot pie chart of colors for each theme
#--------------------------------------
plot_one_by_theme = function (input_theme_name) {
  
  num_sets_in_theme = subset(
    num_sets_for_theme,
    num_sets_for_theme$theme_name == input_theme_name
  )$x
  
  temp = subset(
    agg_theme_color_parts_count,
    agg_theme_color_parts_count$theme_name == input_theme_name
  )
  
  temp = temp[order(-temp$count), ]
  temp$ymax = cumsum(temp$count)
  temp$ymin = c(0, head(temp$ymax, n=-1))
  
  ggplot(
    data = temp,
    aes(
      ymax = ymax,
      ymin = ymin,
      xmax = 5,
      xmin = 3.5,
      fill = factor(color_name, levels = color_name)
    )
  ) +
    scale_fill_manual(
      values = paste0("#", temp$rgb)
    ) +
    geom_rect(
      
    ) +
    annotate(
      "text",
      x = 2,
      y = 2,
      label = paste("Sets:\n", num_sets_in_theme, sep = ""),
      family = "mono",
      size = 3
    ) +
    coord_polar(
      theta = "y"
    ) +
    xlim(
      c(2, 5)
    ) +
    labs(
      title = input_theme_name
    ) +
    theme_economist() +
    theme(
      text = element_text(family = "mono"), 
      plot.title = element_text(size = rel(1.25), hjust = 0.5, margin = margin(t = 0)),
      legend.position = "none",
      axis.line = element_blank(),
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(),
      plot.background = element_blank()
    )
}

# we want to use this data for some other visualization idioms
write.csv(num_sets_for_theme, "num_sets_in_theme.csv")
write.csv(agg_theme_color_parts_count, "agg_theme_color_parts_count.csv")

logo_img = readPNG("lego.png")
logo_grob = rasterGrob(logo_img, width = unit(1, "in"))

plots = lapply(large_themes$theme_name, plot_one_by_theme)

grid_plot = grid.arrange(
  grobs = plots,
  ncol = 5, 
  nrow = 6,
  top = logo_grob
)

ggdrawing = ggdraw(grid_plot) + theme(plot.background = element_rect(fill="aliceblue", color = NA))

plot(ggdrawing)

ggsave(
  paste("color_by_theme.png", sep = ""),
  path = "~/Developer/lego-data",
  dpi = 320,
  width = 10,
  height = 12,
  device = "png",
  units = "in"
)


#--------------------------------------
# Plot pie chart of colors for each year
#--------------------------------------

plot_one_by_year = function (year_input) {
  
  num_sets_in_year = subset(
    num_sets_for_year,
    num_sets_for_year$year == year_input
  )$x
  
  temp = subset(
    agg_year_color_parts_count,
    agg_year_color_parts_count$year == year_input
  )
  
  if (nrow(temp) > 0) {
    temp = temp[order(-temp$count), ]
    temp$ymax = cumsum(temp$count)
    temp$ymin = c(0, head(temp$ymax, n=-1))
    
    ggplot(
      data = temp,
      aes(
        ymax = ymax,
        ymin = ymin,
        xmax = 5,
        xmin = 3.5,
        fill = factor(rgb, levels = rgb)
      )
    ) +
      scale_fill_manual(
        values = paste0("#", temp$rgb)
      ) +
      geom_rect(
        
      ) +
      annotate(
        "text",
        x = 2,
        y = 2,
        label = paste("Sets:\n", num_sets_in_year, sep = ""),
        family = "mono",
        size = 3
      ) +
      coord_polar(
        theta = "y"
      ) +
      xlim(
        c(2, 5)
      ) +
      labs(
        title = year_input
      ) +
      theme_economist() +
      theme(
        text = element_text(family = "mono"), 
        plot.title = element_text(size = rel(1.25), hjust = 0.5, margin = margin(t = 0)),
        legend.position = "none",
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        plot.background = element_blank()
      )
  } else {
    num_sets_in_year = 0
    ggplot(
      data = temp,
      aes(
        ymax = 0,
        ymin = 0,
        xmax = 5,
        xmin = 3.5
      )
    ) +
      geom_rect(
        
      ) +
      annotate(
        "text",
        x = 2,
        y = 2,
        label = paste("Sets:\n", format(num_sets_in_year, scientific = F, big.mark = ","), sep = ""),
        family = "mono",
        size = 2.95
      ) +
      coord_polar(
        theta = "y"
      ) +
      xlim(
        c(2, 5)
      ) +
      labs(
        title = year_input
      ) +
      theme_economist() +
      theme(
        text = element_text(family = "mono"), 
        plot.title = element_text(size = rel(1.25), hjust = 0.5, margin = margin(t = 0)),
        legend.position = "none",
        axis.line = element_blank(),
        axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        plot.background = element_blank()
      )
  }
}

write.csv(num_sets_for_year, "num_sets_for_year.csv")
write.csv(agg_year_color_parts_count, "agg_year_color_parts_count.csv")

plots = lapply(min(num_sets_for_year$year):max(num_sets_for_year$year), plot_one_by_year)

logo_img = readPNG("lego.png")
logo_grob = rasterGrob(logo_img, width = unit(2, "in"))

grid_plot = grid.arrange(
  grobs = plots,
  top = logo_grob,
  layout_matrix = rbind(
    c(NA, NA, NA, NA, NA, NA, NA, NA, NA, 1), # 40's
    2  : (2   + 9), # 50's
    12 : (12  + 9), # 60's
    22 : (22  + 9), # 70's
    32 : (32  + 9), # 80's
    42 : (42  + 9), # 90's
    52 : (52  + 9), # 00's
    62 : (62  + 9), # 10's
    c(72, 73, NA, NA, NA, NA, NA, NA, NA, NA) # 20's
  )
)

ggdrawing = ggdraw(grid_plot) + theme(plot.background = element_rect(fill="aliceblue", color = NA))

plot(ggdrawing)

ggsave(
  paste("color_by_year.png", sep = ""),
  path = "~/Developer/lego-data",
  dpi = 320,
  width = 20,
  height = 20,
  device = "png",
  units = "in"
)

#--------------------------------------
# Treemap by parts, top themes
#--------------------------------------
top_themes_num_parts_subset = subset(
  num_parts_for_theme,
  num_parts_for_theme$theme_name %in% top_themes
)

ggplot(
  data = top_themes_num_parts_subset,
) +
  geom_treemap(
    aes(
      area = x, 
      fill = theme_name
    )
  ) +
  geom_treemap_text(
    aes(
      area = x, 
      label = paste(theme_name, "\n", x, sep = "")
    )
  )

#--------------------------------------
# Treemap by sets, top themes
#--------------------------------------

top_themes_num_sets_subset = subset(
  num_sets_for_theme,
  num_sets_for_theme$theme_name %in% top_themes
)

ggplot(
  data = top_themes_num_sets_subset,
) +
  geom_treemap(
    aes(
      area = x, 
      fill = theme_name
    )
  ) +
  geom_treemap_text(
    aes(
      area = x, 
      label = paste(theme_name, "\n", x, sep = "")
    )
  )

#--------------------------------------
# Barplot avg parts per set
#--------------------------------------

merged_theme_count_parts = merged_theme_count_parts[order(merged_theme_count_parts$parts_per_set), ]

ggplot(
  data = merged_theme_count_parts
) +
  geom_bar(
    aes(
      x = factor(theme_name, levels = theme_name),
      y = parts_per_set
    ),
    stat = "identity"
  )







