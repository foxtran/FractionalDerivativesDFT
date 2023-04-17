#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(reshape2)

alpha_show_tab <- data.frame(Alpha=c(-2.0,-1.0,-0.5,0.0,0.0,0.5,1.0), p = c(0,0,0,0,1,1,1), Alpha_show=c("-2","-1","-0.5","0- or rho","0+","0.5","1 or tau"))

tab <- read.csv("STO-GTO.csv", header=T, sep=";")

p <- tab %>%
  filter(r != 0) %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  mutate(Ratio = GTO / STO) %>%
  ggplot(aes(x=r, y=Ratio, color=Alpha_show)) +
  geom_line() +
  theme_bw() +
  scale_y_continuous("Ratio (R)") +
  scale_x_log10("R, Angstrom", breaks = c(1e-2, 1e-1, 1e0, 1e1, 1e2), labels=c(expression(10^-2), expression(10^-1), 1, expression(10^1), expression(10^2))) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 2)) +
  theme(legend.position="bottom")

ggsave("GTO-div-STO.png", p, units="cm", height=8, width=9, dpi=300)

tab <- tab %>%
  melt(id=c("p","Alpha","r"))

p <- tab %>%
  ggplot(aes(x=r, y=value, color=as.factor(variable))) +
  geom_line() +
  theme_bw() +
  scale_x_continuous("R, Angstrom") +
  scale_color_manual("Orbital types", labels=c("Slater", "Gaussian"), values=c("blue", "red")) +
  theme(legend.position="bottom")

ggsave("STO-GTO.png", p, units="cm", height=10, width=8, dpi=300)

p <- tab %>%
  ggplot(aes(x=r, y=value, color=as.factor(variable))) +
  geom_line() +
  theme_bw() +
  scale_y_log10() +
  scale_x_log10("R, Angstrom") +
  scale_color_manual("Orbital types", labels=c("Slater", "Gaussian"), values=c("blue", "red")) +
  theme(legend.position="bottom")

ggsave("STO-GTO_logscaled.png", p, units="cm", height=10, width=8, dpi=300)
