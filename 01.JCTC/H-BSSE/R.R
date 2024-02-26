#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(scales)

data <- read.csv("data.csv", sep=";", header=T)
ref <- read.csv("ref.csv", sep=";", header=T) %>%
  rename(Value_ref=Value)

tab <- data %>%
  left_join(ref) %>%
  mutate(div = Value / Value_ref)

p <- tab %>%
  ggplot(aes(x=Distance, y=div, color=as.factor(Alpha))) +
    geom_line() +
    geom_line(data=tab %>% filter(Alpha == P), color="black") +
    facet_grid(Basis~P) +
    scale_x_continuous("Distance, Å", breaks=seq(0,7,1)) +
    scale_y_log10(expression(frac(integral(abs(xi[ref]^alpha*(r)-xi[dist]^alpha*(r))*dr),integral(abs(xi[ref]^alpha*(r))*dr))), breaks=10**seq(-13,6,1)) +
    scale_color_discrete(expression(alpha)) +
    theme_bw() +
    theme(legend.position="bottom") +
    guides(color=guide_legend(nrow=3)) +
    coord_cartesian(xlim=c(0.3,7), ylim=c(1e-11, 2e-5), expand=FALSE)

ggsave("H-BSSE.png", p, units="cm", width=21.0, height=29.7, dpi=1000)

p2 <- tab %>%
  ggplot(aes(x=Distance, y=div, color=Alpha,
             group=paste0(Alpha,P,Basis))) +
    geom_line() +
    geom_line(data=. %>% filter(Alpha == P, P==1), color="black", linewidth=1.1) +
    facet_grid(~Basis) +
    scale_x_continuous("Distance, Å", breaks=seq(0,7,1)) +
    scale_y_log10(expression(frac(integral(abs(xi[ref]^alpha*(r)-xi[dist]^alpha*(r))*dr),integral(abs(xi[ref]^alpha*(r))*dr))), breaks=10**seq(-13,6,1)) +
    scale_color_gradientn(expression(alpha*" in "*xi^alpha), colours=c("red","green","blue"), values=c(rescale(c(-1.5,0,1), to=c(0, 1)))) +
    coord_cartesian(xlim=c(0.3,7), ylim=c(1e-11, 2e-5), expand=FALSE) +
    theme_bw() +
    theme(legend.position="bottom") +
    guides(color = guide_colorbar(title.vjust = 0.9))

ggsave("H-BSSE-2.png", p2, units="cm", width=18, height=10, dpi=2000)
