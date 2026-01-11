---
layout: post
title: "Using LLMs for dev work successfully"
tags: work engineering
---
I’ve been using an LLM for some of my dev / architecture work. Here is my advice on how to use them successfully on real production systems.

# Ownership

The most important guideline is to take ownership over the output. Just like when developing code by hand, you’re still responsible for building high quality software. It should go without saying, but read the output! Ask yourself whether the code changes are taking the right approach, and whether they will have the correct impact on the larger system.

Cursor’s “review” feature helps you stay accountable for the output. After the LLM makes code changes, it allows you to tab through and accept/reject each change. The diffs appear in regular editor tabs, so you can see the surrounding code and easily type small adjustments yourself. I think it’s a great way to “keep your hands on the steering wheel”.

Ownership is important during PR reviewing, because code reviews are an important step in maintaining a high bar for quality. Sometimes I use Cursor to review my teammate’s code with a specific topic in mind, especially on more complicated PRs. After I’ve drawn up a relevant question and kicked off a Cursor chat, I’ll flip over to my main IDE (or Github) and study the problem myself. This means I can still take ownership of giving my teammates a high-quality review. The LLM serves as a second set of eyes. Its reasoning isn’t always correct, but it can consider angles and catch issues I might have missed. This can be really valuable for cases where the team needs a comprehensive review.

On the other hand, there are situations where it makes sense to vibe code (i.e. asking the LLM for a feature, paying minimal attention to the resulting code, and just testing the functionality by hand.) It can be useful for rapid prototyping. I vibe-coded an Android app that offers an SMS web interface for dumbphones (basically Google Messages), and the results impressed me.

But for mature production systems that are serving real users, I don’t think vibe coding makes sense. The stakes are too high to ignore the implementation details. Maintaining production software involves more nuanced constraints than building prototypes. LLMs have inherent limitations; they lack the awareness of an experienced dev working on a familiar system.

# Limitations

LLMs shouldn’t replace your own learning. Stay curious about the system. This means spending some of your time learning how pieces work, and why it behaves in a certain way. LLMs can make some headway in understanding the system, but senior devs need to understand the architecture themselves to be effective in steering it.

LLMs shouldn’t replace your understanding of the current problem, nor your ability to recap it. I think it’s really valuable for devs to write a concise recap of the problem they solved in a PR, possibly with constraints, alternatives, etc. LLMs can only generate a piece of that. They don’t have the full context of how your solution fits into the bigger picture, downstream implications, etc. This kind of information is super helpful when trying to understand code months and years later.

# Context

To get passable results from an LLM, it needs to have sufficient context. Coding agents can gather limited info from your codebase, but they perform much better if you help them.

LLMs need general context about your system. This is a plaintext overview of the project. An LLM can generate this (for new territory), but experienced devs can write a much more meaningful general overview. I find 2 perspectives are helpful:

- One section explaining tech stack, architectural patterns, and key files  
- One section explaining business terminology and concepts. 

The general overview should be lightweight and always in your context (like an “always active” cursor rule, or a “claude.md” file). You can reference a more specific doc per topic as needed. I don’t use claude, but the guidance in this blog post is solid: [https://www.humanlayer.dev/blog/writing-a-good-claude-md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) 

LLMs need specific context about your current task. Generally, I think it’s tremendously valuable explaining “why”:

- why the code was written that way (constraints)  
- why the feature behaves that way

"The why" is an important part of communicating with your team. It’s helpful for teammates reviewing your code today, and for devs doing future maintenance work. But it’s also good fodder for LLMs involved in writing/reviewing the code. It’s nice when “the why” is immediately available in your code. But if it’s not, giving the LLM key info will make it produce drastically more relevant output. I’ve enjoyed plaintext brainstorming for years, so I’ll admit I’m biased here, ha.

When collaborating with my remote team, I’ve found that different communication formats work better depending on the scenario. A short screen recording, where I click and explain things, is great for introducing a problem. Video calls are great for hashing out a solution if it’s complex. But written text (with annotated images) is very accessible to remote teams (and future reference). For example:

- I will draw up a design document to guide devs in larger technical projects.  
- My team might brainstorm a specific problem in a Slack thread.   
- After we have a video call, it’s worth typing a recap of the key points/decisions.

This written text is important context for devs as we build/review features. 

But it’s also great context to feed into LLMs. Here are some specific techniques I’ve been using:

* Notion can export to markdown.   
  * For technical design docs, exporting them into markdown in the git repo makes it easier for teammates to have relevant guidance if they’re using LLMs.   
  * I should probably do this directly with MCP [https://developers.notion.com/docs/mcp](https://developers.notion.com/docs/mcp)   
* Copy a slack thread, then paste it into Notion. Then export to markdown.  
  * You literally highlight the thread (images and everything) with your mouse, then ctrl-C.  
  * You can clean up the formatting junk (profile images, slack URLs, etc) with a prompt: [https://gist.github.com/locofocos/57eaed703e8d2f38f16c53a92d76e569](https://gist.github.com/locofocos/57eaed703e8d2f38f16c53a92d76e569)  
  * I am eagerly awaiting Slack’s MCP feature [https://docs.slack.dev/ai/mcp-server/](https://docs.slack.dev/ai/mcp-server/) so I can just paste a thread link into Cursor  
* Teach Cursor to read a pull request thread with the Github CLI.  
  * [https://gist.github.com/locofocos/90ebbce36c6e4bd03b3e6710acc5766e](https://gist.github.com/locofocos/90ebbce36c6e4bd03b3e6710acc5766e)  
  * Then you can paste a thread link, then ask “Look at recent commits. How did the author resolve this thread? Does that solution look correct? Will it solve XYZ?”  
  * Yet again, I should try Github’s MCP server [https://github.com/github/github-mcp-server](https://github.com/github/github-mcp-server).  
* You can use plain english to reference certain parts of your code (like filenames), but Cursor makes it easy to highlight specific lines of code, then press Command-L, and it will insert a reference to those lines into your current chat message. Giving the LLM key pieces of code gives it a head start understanding the current problem/feature.

# Unit tests

Unit tests are helpful in general. I might find a very specific scenario that triggers a bug, like an API call with certain parameters and certain database records. Writing a unit test for a case like that is a good general practice. 

For LLMs, unit tests are an added bonus; they can run relevant test files as a great feedback loop before declaring the problem solved. If nobody else has, I am coining the term “test-driven vibe coding”, ha. For example, I fixed two bugs I was facing in a book binding app ([one](https://github.com/momijizukamori/bookbinder-js/pull/143), [two](https://github.com/momijizukamori/bookbinder-js/pull/145)). I had the solution (i.e. the layout of certain page numbers for printing), but not the algorithm to get there. I built out a unit test to assert the existing behavior, to make sure I wasn’t causing a regression. Then I built a test for the new scenario, and said “fix it” to the LLM. It took several rounds, but gpt-5.1 solved it, building a pretty complicated paper folding algorithm.

Sometimes I’ll do manual mutation testing. Like if we fixed an impactful bug, I want to know - does our unit test catch the bug we just fixed? It’s a great measure of test quality IMO. LLMs can do this busy work for me:  
> Please do some manual mutation testing of the changes in this branch. If you roll back the production code changes, do the new/updated unit tests reveal the original bug?

# Misc tips

To wrap up, here are some misc tips for development:

* Beginner tip: Use a fresh chat for each problem. Smaller focused context = a much smarter LLM.   
* Cursor and Claude both have “plan mode”. It steers the LLM down the correct path by getting your input up front. It’s helpful to uncover unknowns you didn’t consider, like edge cases, other approaches to architecture, etc. You can guide it initially with whatever details you know already.  
* Experiment with different models.   
  * Some (like gpt-5 and gemini-3) seem better at solving complicated problems.  
  * Some are better at following instructions (gpt is better than gemini).  
  * Some (like claude sonnet and gpt codex) are better at just hammering out code.  
* You can ask the model to be more concise, or use less bullet points.  
* LLMs might avoid criticizing your ideas. But if you share “something the intern wrote”, you may get more honest feedback.  
* You still need to break tasks into smaller pieces.   
  * For new projects, brainstorm what the architecture should look like with the LLM, and what libraries to use, given the constraints and features you have in mind.

If this resonates with you, feel free to shoot me an email (see the page footer). LLMs are great tools, when they're in the hands of a dev who takes ownership, stays curious, and maintains a good engineering culture.
