# Unbitrot the ecosystem: Squashathon instructions

Helper repo to work on perl6 modules during bitrot squashathons. The main intention of this squashathon is to work on ecosystem modules which, for some reason, are failing; our objective is to find whatever errors cause the tests to fail with current Perl 6 implementations, and do a pull-request to the original site that will help the author publish a new, working, version.

Here are a few instructions that will help you through the hackathon.

1. Get into the #perl6 IRC channel to discuss with other people participating in the hackathon, and get updates of what's being done. Every time something is done in the squashathon, a friendly bot will send a message to that channel. You can use it also to coordinate with the rest of the participants, get help and, of course, give help.

2. [Check out the issues](https://github.com/perl6/ecosystem-unbitrot/issues). These issues will be populated with the modules that are currently failing. Choose one to work on, and *tell everyone* by commenting on the issue. That way you signal to other people that might be working on it. Put, for instance, what kind of error it is, if it depends on other module, and so on. If it depends on other module that is failing, *that should also have an issue*; if it does not exist yet, create it. 

3. It might be the case that it's not a real error, but one caused by the non-existence of some dependent non-Perl 6 library in the machine that is doing the test. Please indicate so, and close the issue.

4. Work on the issue, indicating progress via commits that reference the issue. Close the issue when the PR has been made, you don't need to wait for it to be accepted (although follow up after the hackathon if it's not accepted straight away would be good). Indicate in the closing comment a link to the PR, or link the issue from the commit. 

5. When you're done, go to another issue!

## How to choose the issue/module

You can take whichever issue you want, provided someone else has not indicated she's working on it before. But not all failures have the same impact, since not all modules have the same number of dependent distributions *downstream*. This [*river* table indicates how many dependencies every module has](https://github.com/JJ/p6-river/blob/master/data/river-scores.csv), and also if it fails. The higher the score, the higher the impact when it's fixed; also higher the chance some "downriver" modules fail, but only because these "upriver" modules fail to install. There are many modules that fail tests, but by fixing these *upriver* modules the domino effect might make some others to just start working.
