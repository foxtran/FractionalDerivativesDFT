#!/usr/bin/Rscript

library(tidyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

tab <- read.csv("Xe_R_out.log", header=T, sep=";")

#p <- tab %>%
#  mutate(Alpha = as.factor(Alpha),
#         Beta  = as.factor(Beta)) %>%
#  group_by(Alpha, Beta) %>%
#  mutate(Value = Value / max(Value)) %>%
#  ggplot(aes(x=R, y=Value, color=Alpha)) +
#    geom_line() +
#    theme_bw() +
#    scale_x_continuous("R, Angstrom", breaks=seq(0,10,1), limits=c(0,3)) +
#    scale_y_continuous(expression(frac(xi(R),max~xi)), breaks=seq(0,1,0.2))
#
#ggsave("Xe-fig.png", p, units="cm", width=12, height=8)

alpha_show_tab <- data.frame(Alpha=c(-2.0,-1.0,-0.5,0.0,0.0,0.5,1.0), p = c(0,0,0,0,1,1,1), Alpha_show=c("-2","-1","-0.5","0- or rho","0+","0.5","1 or tau"))

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  group_by(Alpha, p) %>%
  mutate(Value = Value * R * R) %>%
  mutate(Value = Value / max(Value)) %>%
  ggplot(aes(x=R, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,0.5), limits=c(0,3)) +
    scale_y_continuous(expression(frac(xi^alpha*(R)*R^2,max~xi^alpha*(R)*R^2)), breaks=seq(0,1,0.2)) +
    #facet_wrap(~p) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 2))

scale_fig=1.5
ggsave("Xe-figR2.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-2.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  group_by(Alpha, p) %>%
  mutate(Value = Value) %>%
  ggplot(aes(x=R, y=Value)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,15,1), limits=c(0,5)) +
    scale_y_continuous(expression(xi^-2*(R)), breaks=seq(0,20,1))
#    scale_color_manual(name=expression(alpha),
#                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
#                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1 %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
#    theme(legend.position="bottom") +
#    guides(color = guide_legend(nrow = 2))

scale_fig=1.5
ggsave("Xe-2-fig.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)
