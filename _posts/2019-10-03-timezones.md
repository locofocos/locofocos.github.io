---
layout: post
title:  "Timezones are hard"
tags: engineering
published: true
---
Timezones are hard. I learned a lot about handling them in a recent project at work. I was given the task of designing and implementing a React frontend application to show a list of events. As the project unfolded, I learned that timezones, in the right context, can present more edge cases than anyone would think during early design phases. Thankfully, there are ways to manage the complexity and weird cases that pop up, and I hope this blog will be a useful primer for anyone else going through a similar undertaking.

# Just use that ISO format

There's this great thing people will tell you to use at first, called ISO-8601. It's a universal, standardized way of presenting a specific date and time, in a specific timezone. _Side note, I've already said something incorrect- did you catch it?_ The current time as I'm writing this is `2019-10-03T21:48:00-05:00`. Or maybe it's minus 6 at the end; I always have to check the correct value (depending on daylight savings time) whenever I'm writing a unit test case, and that feels like a chore here.

Using ISO-8601 for all your datetimes might solve your issue. There are libraries for displaying it in a friendly format, according to the rules that your user's browser/device would dictate for their locale. A person on the US east coast would see it as "March 10th, 7 pm", and a person on the US west coast would see it as "March 10th, 4 pm". If you can get away with that, your job might be easy.

But what if the datetime isn't some free-floating measurement, and it's actually tied to some event? Then, you're likely going to want to show the time "on the ground"- the time someone would see on a clock if they were on the ground at the place where the event is happening. This isn't too bad- just store the correct UTC offset (the `-05:00` at the end of the string) that the location will be using when the event occurs.

But what if your application _really_ needs to display the timezone abbreviation, like "5 pm CST" or "7 pm PDT"? You have the time in ISO-8601, what more could you possibly need?

# What more could you possibly need?

A lot more. You also need the "timezone", and a fancy library someone else wrote for handling it. The incorrect thing I wrote above was that ISO-8601 presents a timezone. ISO-8601 doesn't contain timezone, but merely a UTC offset. If every place within a given UTC offset followed the same rules around daylight savings time and timezone abbreviations, we could probably convert from `-05:00` to "central daylight time".

But they don't. Places like Arizona don't even use daylight savings time. If I gave you a UTC offset of `-07:00`, you couldn't tell me if it belongs to Arizona in the summer (MST) or California in the winter (PDT). This means that if you only have an ISO-8601 datetime, which is the default for what most common datetime columns in databases store (and what you get from Ruby on Rails timestamps), then you _cannot_ provide timezone abbreviations (like `CST`) reliably. You could probably hack together 10-20 lines of code that fudges it correctly for 90% of users in the USA, but that's no way to build production-grade software.

You need the timezone.

# Timezone format

But in what format? You need the timezone formatted in... the name of the nearest big city whose timezone rules you want to follow. What?! Surely, something like "US/Central" would be more appropriate, right? Wrong; those are deprecated, though you can probably get by with them for now.

The most popular (in my barely-qualified opinion) means of defining timezones comes from the "tz" database. This Wikipedia article has a great list to reference: <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>. My timezone is listed as "America/Chicago". You might have seen these listed on a map when you installed a new operating system. It turns out picking from a small handful of cities isn't sloppiness, but actually a very precise approach!

Each of those timezones defines all sorts of nuances around UTC offsets, when/if the UTC offset shifts for daylight savings time, and even such niceties as which years that city chose _not_ to observe daylight savings time. Having a timezone, as specified by the tz database, plus an ISO-8601 timestamp, really seems to be the holy grail for datetimes. Just add another string field to your data model with the timestamp field.

# Do I really need ISO-8601 and timezone?

For most cases, probably not. Just build backend services to send an ISO-8601 string with whatever UTC offset it happens to spit out, and let some client-side library display it as appropriate. Or let the user specify their timezone and do it server-side, whatever. What I've described is the approach that's needed if you _must_ display timezones or time abbreviations, like CST or "Pacific Daylight Time". If you can get by with "5 pm UTC-5", then you don't need the timezone. Or even "5 pm local time", likewise the ISO timestamp is enough.

# How to

If, by the time you read this blog post, the tech community hasn't built a better universal platform than a web browser + Javascript, you're probably building an application with Javascript. So just handle things with a library called Moment JS, possibly with the Moment Timezone addition. If you can get by doing things server side, then use whatever library is convenient, like the ActiveSupport::TimeZone class in Rails. Just know that you don't have the luxury of poking at the user's browser to guess their timezone, like Moment JS does, unless you make the browser pass it to the server.

# The idea of "today"

You might also face this challenging question: what does "today" even mean? "Today" is tough to define when the browser and events are in different time zones. We often think of today with reference to our current location. If we use that mentality to answer "is this today" with an event from another timezone, we start to run into issues. We could have an event displaying "Nov 4" and and event displaying "Nov 5" that both fall under "Today", if you consider the ISO timestamp with reference to our current location.

If you're really think about edge cases, there are events happening "yesterday" but still in the future. Suppose the browser's date is May 4th. There can be events still in the future which happen on May 3rd (ground time), in a different timezone. Presumably you still need to display them, since they happen in the future. But do you present those in a group labeled "Yesterday"?  You can even run into issues where an event belongs under both "Tomorrow" and "Nov 7", and nobody wants to deal with seemingly indeterminate functionality or requirements.

Suppose a user in the US sees an event happening in India, and begins to think
> for me, Today means XYZ, but for a user in India, Today means....

This attempt at interpreting "today" in another timezone may lead them to wrong assumptions. There's no way we can make "Today" make sense for every situation people describe.

## A solution to the insanity

The easy approach here is simply avoid the concept of "today" and "tomorrow", if your events can (and often do) span vastly different timezones. If your events will usually be in the user's timezone, the sensible approach I have identified is this: The browser's current date is considered "Today". For me as I write this, that means any event falling under "October 3", as interpreted "on the ground", falls under a "Today" group. For most cases, nothing weird is going on. 100% of the time, the dates (Nov 4th, Oct 10th, etc) will fall under the same group. The compromise here is that if users think _really_ hard about "what does today actually mean" and try to unroll/convert timezones in their head, they might come to some weird conclusion. This means you should always display the date ("on the ground", as always) on the visual for each event. You can't just label each group of events with the date, if you're using the concept of "Today".

# Conclusion

Learn to love ISO-8601. Convince your non-technical folks not to display timezone abbreviations. If they still want to display "CST" or similar, just send them this blog post along with a bigger work estimate :grin:.
