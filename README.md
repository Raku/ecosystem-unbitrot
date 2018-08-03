# Unbitrot the ecosystem: Squashathon instructions

Helper repo to work on perl6 modules during [bitrot squashathons](https://twitter.com/zoffix/status/1022879125923672066). The main intention of this squashathon is to work on ecosystem modules which, for some reason, are failing; our objective is to find whatever errors cause the tests to fail with current Perl 6 implementations, and do a pull-request to the original site that will help the author publish a new, working, version.

Here are a few instructions that will help you through the hackathon.

1. Get into the [#perl6 IRC channel](https://perl6.org/irc) to discuss with other people participating in the hackathon, and get updates of what's being done. Every time something is done in the squashathon, a friendly bot will send a message to that channel. You can use it also to coordinate with the rest of the participants, get help and, of course, give help.

2. [Check out the issues](https://github.com/perl6/ecosystem-unbitrot/issues). These issues are populated before the squashathon with the modules that are currently failing. Choose one to work on, and follow the instructions presented in that issue.

3. When you're done, go to another issue!

## How to choose the issue/module

You can take whichever issue you want, provided someone else has not indicated she's working on it before. But not all failures have the same impact, since not all modules have the same number of dependent distributions *downstream*. This [*river* table indicates how many dependencies every module has](https://github.com/JJ/p6-river/blob/master/data/river-scores.csv), and also if it fails. The higher the score, the higher the impact when it's fixed; also higher the chance some "downriver" modules fail, but only because these "upriver" modules fail to install. There are many modules that fail tests, but by fixing these *upriver* modules the domino effect might make some others to just start working.
