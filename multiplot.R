###### LIBRARIES

library(data.table)
library(gtools)
library(ggplot2)
library(hrbrthemes)
library(ggpubr)
library(cowplot)



###### DATA

dat <- readRDS("example_data.rds")

summary(dat)



###### FUNCTIONS

# core plotting function to create one individual plot
single.plot <- function(response, params) {
  if (length(params) >= 2) {
    p <- ggplot(dat, aes_string(y = response, x = params[1], group = params[2], color = params[2], fill = params[2]))
  } else {
    p <- ggplot(dat, aes_string(y = response, x = params[1]))
  }
  p <- p +
    ## barplots with error whiskers
    stat_summary(fun.data = mean_se, geom = "errorbar", aes(width=0.25), position = position_dodge(0.95)) +
    stat_summary(fun = mean, geom = "bar", position = position_dodge(0.95))
    ## optionally, line-connected scatter plots
    #stat_summary(fun = mean, geom = "point") +
    #stat_summary(fun = mean, geom = "line")
  if (length(params) == 3) {
    p <- p + facet_wrap(. ~ get(params[3]))
  }
  p <- p + theme_ipsum_rc() + theme(legend.position = "bottom")
  print(p)
}

single.plot(response = "`Absorption of light`", params = c("Group"))
single.plot(response = "`Absorption of light`", params = c("Group", "Frozen"))
single.plot(response = "`Absorption of light`", params = c("Group", "Frozen", "Length"))



# combine every possible combination of parameter levels
multiplot <- function(response, vars) {
  permuts <- permutations(n = length(vars), r = length(vars), v = vars)
  
  apply(permuts, 1, FUN = function(perm) single.plot(response = response, params = perm))
}



# outputs
ggarrange(plotlist = multiplot("`Number of colonies`", c("Group", "Frozen", "Length")))
cowplot::plot_grid(ncol = 2, plotlist = multiplot("`Number of colonies`", c("Group", "Frozen", "Length")))
