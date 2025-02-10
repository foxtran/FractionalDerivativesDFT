#!/usr/bin/env Rscript

library(tidyr)
library(dplyr)
library(ggplot2)
library(ggh4x)
library(RColorBrewer)

tab <- read.csv("Xe_R_out.log", header=T, sep=";")

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
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,0.5), limits=c(0,5)) +
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
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  group_by(Alpha, p) %>%
  mutate(Value = Value) %>%
  mutate(Value = Value / max(Value)) %>%
  ggplot(aes(x=R, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,0.5), limits=c(0,5)) +
    scale_y_continuous(expression(frac(xi^alpha*(R),max~xi^alpha*(R))), breaks=seq(0,1,0.2)) +
    #facet_wrap(~p) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 2))

scale_fig=1.5
ggsave("Xe-fig.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show = factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  crossing(Scal = c(0,2)) %>%
  mutate(ScalText = factor(Scal, levels=c(0,2), labels = c( expression(frac(xi^alpha*(R),max~xi^alpha*(R))), expression(frac(xi^alpha*(R)%*%R^2,max~xi^alpha*(R)%*%R^2)) ))) %>%
  group_by(Alpha, p, Scal) %>%
  mutate(Value = Value * R**Scal) %>%
  mutate(Value = Value / max(Value)) %>%
  ggplot(aes(x=R, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,1), limits=c(0,5)) +
    scale_y_continuous("Value", breaks=seq(0,1,0.2)) +
    facet_grid(~ScalText, labeller = label_parsed) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom", strip.background = element_rect(fill="white")) +
    guides(color = guide_legend(nrow = 2))

ggsave("Xe-both.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

tab_rho <- tab %>%
  filter(p == 0) %>%
  filter(Alpha == 0) %>%
  select(-p, -Alpha) %>%
  rename(rho = Value)

tab_xim05 <- tab %>%
  filter(p == 0) %>%
  filter(Alpha == -0.5) %>%
  select(-p, -Alpha) %>%
  rename(xi_m05 = Value)

tab <- tab %>%
  left_join(tab_rho) %>%
  left_join(tab_xim05) %>%
  mutate(Value_unif = 3./2. * (3.*pi^2)^(2./3.*Alpha)/(3.+2.*Alpha) * rho^(1+2./3.*Alpha))

p <- tab %>%
  filter(Alpha %in% c(-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show = factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  crossing(Scal = c(0,2)) %>%
  mutate(ScalText = factor(Scal, levels=c(0,2), labels = c( expression(frac(xi[unif]^alpha*(R),xi^alpha*(R))), expression(frac(xi[unif]^alpha*(R)%*%R^2,xi^alpha*(R)%*%R^2)) ))) %>%
  group_by(Alpha, p, Scal) %>%
  mutate(Value = Value_unif / Value) %>%
  mutate(Value = Value * R**Scal) %>%
  ggplot(aes(x=R, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,1), limits=c(0,5)) +
    scale_y_continuous("Value", limits = c(0,12)) +
    facet_grid(~ScalText, labeller = label_parsed) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom", strip.background = element_rect(fill="white")) +
    guides(color = guide_legend(nrow = 2))

ggsave("Xe-unitless-both.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show = factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"), labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))),
         ) %>%
  crossing(Scal = c(0,2,-1,-2)) %>%
  mutate(ScalText = factor(Scal, levels=c(0,-1,2,-2,-3), labels = c( expression(frac(xi^alpha*(R),max~xi^alpha*(R))),
                                                                     expression(t[xi]^alpha*(R)%==%frac(xi[unif]^alpha*(R),xi^alpha*(R))),
                                                                     expression(frac(xi^alpha*(R)%*%R^2,max~xi^alpha*(R)%*%R^2)),
                                                                     expression(omega[xi]^alpha*(R)%==%frac(t[xi]^alpha*(R) - 1, t[xi]^alpha*(R) + 1)),
                                                                     expression(frac(xi^alpha*(R),(xi^-0.5*(R))^frac(1,2)))
                                                                    ))) %>%
  group_by(Alpha, p, Scal) %>%
  mutate(Value = case_when(Scal == -1 ~ Value_unif / Value, Scal == -2 ~ (Value_unif / Value - 1) / (Value_unif / Value + 1), Scal == -3 ~ Value / (xi_m05)^0.5, Scal == 0 ~ Value, Scal == 2 ~ Value * R**Scal)) %>%
  mutate(Value = case_when(Scal >= 0 ~ Value / max(Value), TRUE ~ Value)) %>%
  ggplot(aes(x=R, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(0,10,1), limits=c(0,5)) +
    scale_y_continuous("Value") +
    facet_wrap(~ScalText, labeller = label_parsed, scales="free_y", ncol=2) +
    ggh4x::facetted_pos_scales(y = list(
      ScalText == levels( 2) ~ scale_y_continuous(breaks = c(-1,4,0.25)),
      ScalText == levels( 0) ~ scale_y_continuous(breaks = c(-1,4,0.25)),
      ScalText == levels(-1) ~ scale_y_continuous(breaks = c(-1,4,0.25)),
      ScalText == levels(-2) ~ scale_y_continuous(breaks = c(-1,5,0.5))
    )) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
#                       labeller = label_parsed) +
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom", strip.background = element_rect(fill="white"), legend.text = element_text(margin = margin(r = 10, l = 4, unit = "pt"))) +
    guides(color = guide_legend(nrow = 2))

scale_fig = 1
ggsave("Xe-triple.png", p, units="cm", width=18*scale_fig, height=16*scale_fig,dpi=1000)
