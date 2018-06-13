---
layout: post
title:  "Sensible Git Command Line Graphs"
tags: git ruby
---
There are many reasons for wanting to visualize the git graph. It helps verify that a given branch is in compliance with the team's branching standards (like rebasing before making a code review or pull request). It's handy when collaborating with other developers in the same git repository. We try to avoid branching off other issue branches, but sometimes it happens when the team needs to work together on similar features. In those situations where your work depends on a colleague's work, visualizing the graph is practically necessary.

## Existing tools for visualizing git graphs
- *git plus some alias you found on StackOverflow*- Works well, but not with large number of branches (my workaround below).

- *Github network graph*- Generally my go-to choice when I'm on someone else's computer. Not everyone has a license though. It also won't be helpful for visualizing before you push (like if you want to verify you've performed a merge/rebase correctly).

- *IntelliJ Version Control pane*- Worth looking into. It's cumbersome to grab commit hashes, and launching it will take a moment if you're jumping between repos, so I rarely use it for this.

- *[GitUp](http://gitup.co)*- Looks great if you have a Mac; I don't.

- *gitk*- Included in your git installation. UI comes straight from 1999, but the info is there if you can digest it.

## Problems with existing tools
Whatever your taste, one of the tools mentioned above should work well. Try them out and use each when it makes sense. But I can almost guarantee that you'll become overwhelmed trying to visualize a large number of branches.

## Visualizing a few branches via CLI
Set up a concise git log format of your choice. My favorite is slightly adapted from [https://coderwall.com/p/euwpig/a-better-git-log](https://coderwall.com/p/euwpig/a-better-git-log):
```
git config --global format.pretty format:"%C(bold cyan)%h%Creset %C(cyan)<%an>%Creset %Cgreen(%cr)%Creset%C(yellow)%d%Creset %<(80,trunc)%s"
```
Then the command for viewing the graph:
```
git log --graph --all
```
Nobody wants to press that many buttons, so set up an alias in your .gitconfig file:
```
[alias]
  lg = log --graph --all
```
so then you can just run `git lg`.

Example running this on a repo with many branches ([https://github.com/vuejs/vue](https://github.com/vuejs/vue)):

![Visualizing branches using git lg]({{ "assets/git_lg.PNG" | absolute_url }})

Notice what happens when multiple branches have concurrent development. What branch does the yellow line belong to? How far will I need to scroll to see what branch it was based off of, and off which commit from that parent branch?

![Visualizing concurrent branches using git lg]({{ "assets/git_lg_confusing.PNG" | absolute_url }})

## Visualizing many branches via CLI
When visualizing a few branches, we have the luxury of viewing every commit. This becomes overwhelming when the repo has a large number of branches. Granted, we could explicitly specify a few branches like `git log --graph master mybranch anotherbranch` instead of using `--all`, but sometimes you want to see them *all*, even if each branch has numerous commits.

#### Setup
1. Install ruby for running my script.
2. Copy this script into a convenient location, like `C:\DEV\graph_helper.rb`
{% highlight ruby  %}
{% include_relative /snippets/graph_helper.rb %}
{% endhighlight %}
Word of warning- the script runs in O(n^2) time, based on the number of branches. There's probably a more efficient algorithm, but I haven't investigated this yet.

{:start="3"}
3. Setup an alias to run the script in the current repo:
```
# .gitconfig snippet
[alias]
  ...
  logfix = !ruby /c/DEV/graph_helper.rb
```
4. Setup an alias for the actual graph command:
```
# .gitconfig snippet
[alias]
  ...
  lgs = log --graph --all --simplify-by-decoration
```

#### Usage
1. Run `git logfix` to prepare the temporary branches necessary for displaying the graph.
1. Run `git lgs` to show the simplified/condenses git graph.

Example running this on a repo with many branches ([https://github.com/vuejs/vue](https://github.com/vuejs/vue)):

![Visualizing branches using git lgs]({{ "assets/git_lgs.PNG" | absolute_url }})

This is showing almost every branch currently in existence, all inside a single terminal window. Nice, right?

#### How it works
Git has a built in feature to [simplify history](https://git-scm.com/docs/git-log#_history_simplification). However, it discards all commits that don't have a branch attached to them. This would cause many of the graph edges to disappear. By creating temporary branches at all of the merge-bases, we ensure that `--simplify-by-decoration` shows the most concise version of the graph possible.
