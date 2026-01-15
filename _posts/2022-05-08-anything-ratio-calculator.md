---
layout: post
title:  "Anything Ratio Calculator"
tags: tool dev
---
View the calculator at [https://locofocos.com/anything-ratio-calc/](https://locofocos.com/anything-ratio-calc/)

This calculator allows you to input arbitrary ratios (like for a cooking recipe, a home improvement project, whatever) and then scale the recipe up and down. 

It's helpful because you can change any resulting value. For example, suppose you have a cake recipe that needs 4 cups of flour, but you only have 3.5 cups of flour. This will scale all the other ingredients accordingly.

It's a single-page application built with React and basic HTML elements. The deployment is literally just serving up a static HTML and JS file with modern-ish JS syntax (may the odds be ever in your favor, IE 10 users). It uses React hooks because that's how I like expressing the logic. If this paradigm interests you, you may be interested in commit [3e3fe18](https://github.com/locofocos/anything-ratio-calc/commit/3e3fe1858caae8a57af40c73dad49875de07d97e) as a barebones template.
