---
title: Will Someone Be Sitting In Your Seat On The Plane?
author: ''
date: '2016-02-21'
slug: will-someone-be-sitting-in-your-seat-on-the-plane
aliases: ["/r/will-someone-be-sitting-in-your-seat-on-the-plane/"]
categories:
  - r
tags:
  - r
  - riddler
subtitle: "Expanding on the Riddler's Problem"
summary: ''
authors: []
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---







[This week's Riddler puzzle on FiveThirtyEight](http://fivethirtyeight.com/features/will-someone-be-sitting-in-your-seat-on-the-plane/) features the following questions:

> There’s an airplane with 100 seats, and there are 100 ticketed passengers each with an assigned seat. They line up to board in some random order. However, the first person to board is the worst person alive, and just sits in a random seat, without even looking at his boarding pass. Each subsequent passenger sits in his or her own assigned seat if it’s empty, but sits in a random open seat if the assigned seat is occupied. What is the probability that you, the hundredth passenger to board, finds your seat unoccupied?

Coincidentally, I had seen "the lost boarding pass" problem described and solved using R on [David Robinson's blog](http://varianceexplained.org/r/boarding-pass-simulation/). In short, the answer is 50%. In asking for special extensions to the problem, I decided to evaluate if the probability remains constant across plane size. In fact, it does.

An [Airbus A380](https://en.wikipedia.org/wiki/Airbus_A380) has a maximum passenger capacity of 538 seats, which I rounded up to 600 for my maximum plane size. As seen below, it doesn't matter the size of the plane - the probability of the last passenger sitting in his assigned seat is always 1/2.



<img src="/post/2016-02-21-will-someone-be-sitting-in-your-seat-on-the-plane_files/figure-html/plot1-1.png" width="672" />

In fact, as long as you are not one of the last passengers to board the airplane, you have an extremely high probability of sitting in your correct seat.



<img src="/post/2016-02-21-will-someone-be-sitting-in-your-seat-on-the-plane_files/figure-html/plot2-1.png" width="672" />

We can in fact be a bit more precise. As long as you are not one of the last 10 passengers to board the plane, regardless of the size of the plane, you have a greater than 90% chance of sitting in your correct seat.

<img src="/post/2016-02-21-will-someone-be-sitting-in-your-seat-on-the-plane_files/figure-html/plot3-1.png" width="672" />
