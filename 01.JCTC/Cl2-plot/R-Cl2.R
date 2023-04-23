#!/usr/bin/Rscript

library(tidyr)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

tab <- read.csv("Cl2_data.csv", header=T, sep=";")

tab_rho <- tab %>%
  filter(p == 0) %>%
  filter(Alpha == 0) %>%
  select(-p, -Alpha) %>%
  rename(rho = Value)

tab <- tab %>%
  left_join(tab_rho) %>%
  mutate(Value_unif = 3./2. * (3.*pi^2)^(2./3.*Alpha)/(3.+2.*Alpha) * rho^(1+2./3.*Alpha))

alpha_show_tab <- data.frame(Alpha=c(-2.0,-1.0,-0.5,0.0,0.0,0.5,1.0), p = c(0,0,0,0,1,1,1), Alpha_show=c("-2","-1","-0.5","0- or rho","0+","0.5","1 or tau"))

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  group_by(Alpha, p) %>%
  mutate(Value = Value / max(Value)) %>%
  ggplot(aes(x=Z, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_continuous(expression(frac(xi^alpha*(R),"max"~xi^alpha*(R))), breaks=seq(0,1,0.2)) +
    facet_wrap(~Basis) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 2))

scale_fig=1.5
ggsave("Cl2-frac-normed.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show, levels=c("0- or rho","1 or tau","-0.5","0.5","-1","0+","-2"))) %>%
  group_by(Alpha, p) %>%
  ggplot(aes(x=Z, y=Value, color=Alpha_show)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_log10(expression(xi^alpha*(R))) +
    facet_wrap(~Basis) +
    scale_color_manual(name=expression(alpha),
                       values=c('#e41a1c','#377eb8','#4daf4a','#984ea3','#ff7f00','#a65628','#f781bf'),
                       labels=c(expression(0^bold("−") %==% rho / 2),expression(1^bold("−") %==% tau),expression(-1/2),expression(1/2),expression(-1),expression(0^bold("+")),expression(-2))) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 2))

scale_fig=1.5
ggsave("Cl2-frac-logscaled.png", p, units="cm", width=8*scale_fig, height=7*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(xi^1^bold("−") %==% tau),
                                    expression(xi^0.5),
                                    expression(xi^0^bold("+")),
                                    expression(xi^0^bold("−") %==% rho / 2),
                                    expression(xi^-0.5),
                                    expression(xi^-1),
                                    expression(xi^-2)))) %>%  group_by(Alpha, p) %>%
  group_by(Alpha, p) %>%
  ggplot(aes(x=Z, y=Value, color=Basis)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_log10(expression(xi^alpha*(R))) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    scale_color_manual(values=c('#e41a1c','#377eb8','#4daf4a','#984ea3')) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-basis-frac-logscaled.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)

tab_ref <- tab %>%
  filter(Basis == "ACCT") %>%
  select(-Basis, -Value_unif, -rho) %>%
  rename(Value_ref = Value)

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  filter(Basis != "ACCT") %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  left_join(tab_ref) %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(xi^1^bold("−") %==% tau),
                                    expression(xi^0.5),
                                    expression(xi^0^bold("+")),
                                    expression(xi^0^bold("−") %==% rho / 2),
                                    expression(xi^-0.5),
                                    expression(xi^-1),
                                    expression(xi^-2)))) %>%
  group_by(Alpha, p) %>%
  mutate(dValue = abs(Value - Value_ref)) %>%
  ggplot(aes(x=Z, y=dValue, color=Basis)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_log10(expression("|"*xi^alpha*(R)-xi[ACCT]^alpha*(R)*"|")) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    scale_color_manual(values=c('#e41a1c','#377eb8','#4daf4a','#984ea3')) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-basis-frac-diff-logscaled.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-2.0,-1.0,-0.5,0.0,0.5,1.0)) %>%
  filter(Basis != "ACCT") %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  left_join(tab_ref) %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(xi^1^bold("−") %==% tau),
                                    expression(xi^0.5),
                                    expression(xi^0^bold("+")),
                                    expression(xi^0^bold("−") %==% rho / 2),
                                    expression(xi^-0.5),
                                    expression(xi^-1),
                                    expression(xi^-2)))) %>%
  group_by(Alpha, p) %>%
  mutate(dValue = abs(Value - Value_ref)/Value_ref) %>%
  ggplot(aes(x=Z, y=dValue, color=Basis)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_log10(expression(frac("|"*xi^alpha*(R)-xi[ACCT]^alpha*(R)*"|",xi[ACCT]^alpha*(R)))) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    scale_color_manual(values=c('#e41a1c','#377eb8','#4daf4a','#984ea3')) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-basis-frac-reldiff-logscaled.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(xi^1^bold("−") %==% tau),
                                    expression(xi^0.5),
                                    expression(xi^0^bold("+")),
                                    expression(xi^0^bold("−") %==% rho / 2),
                                    expression(xi^-0.5),
                                    expression(xi^-1),
                                    expression(xi^-2)))) %>%  group_by(Alpha, p) %>%
  mutate(ka = Value_unif / Value) %>%
  filter(Basis == "UGBS") %>%
  ggplot(aes(x=Z, y=ka)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_log10(expression(frac(xi[unif]^alpha*(R),xi^alpha*(R)))) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-frac-runif-logscaled.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)


p <- tab %>%
  filter(Alpha %in% c(-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(1^bold("−") %==% tau),
                                    expression(1/2),
                                    expression(0^bold("+")),
                                    expression(0^bold("−") %==% rho / 2),
                                    expression(-1/2),
                                    expression(-1),
                                    expression(-2)))) %>%  group_by(Alpha, p) %>%
  mutate(ka = Value_unif / Value) %>%
  filter(Basis == "UGBS") %>%
  ggplot(aes(x=Z, y=ka)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_continuous(expression(frac(xi[unif]^alpha*(R),xi^alpha*(R)))) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-frac-runif-values.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)

p <- tab %>%
  filter(Alpha %in% c(-1.0,-0.5,0.0,0.5,1.0)) %>%
  left_join(alpha_show_tab) %>%
  drop_na() %>%
  mutate(Alpha = as.factor(Alpha),
         p  = as.factor(p),
         Alpha_show=factor(Alpha_show,
                           levels=c("1 or tau",
                                    "0.5",
                                    "0+",
                                    "0- or rho",
                                    "-0.5",
                                    "-1",
                                    "-2"),
                           labels=c(expression(xi^1^bold("−") %==% tau),
                                    expression(xi^0.5),
                                    expression(xi^0^bold("+")),
                                    expression(xi^0^bold("−") %==% rho / 2),
                                    expression(xi^-0.5),
                                    expression(xi^-1),
                                    expression(xi^-2)))) %>%
  group_by(Alpha, p) %>%
  mutate(ka = Value_unif / Value) %>%
  mutate(wa = (ka-1)/(ka+1)) %>%
  filter(Basis == "UGBS") %>%
  ggplot(aes(x=Z, y=wa)) +
    geom_line() +
    theme_bw() +
    scale_x_continuous("R, Angstrom", breaks=seq(-4,4,2)) +
    scale_y_continuous(expression(omega^alpha*(R))) +
    facet_wrap(~Alpha_show, labeller = label_parsed, ncol=7) +
    theme(legend.position="bottom") +
    guides(color = guide_legend(nrow = 1))

scale_fig=1
ggsave("Cl2-frac-runifw-values.png", p, units="cm", width=18*scale_fig, height=6*scale_fig,dpi=1000)
