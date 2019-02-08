# Unbitrot the ecosystem: Squashathon instructions

Helper repo to work on perl6 modules during [bitrot squashathons](https://twitter.com/zoffix/status/1022879125923672066). The main intention of this squashathon is to work on ecosystem modules which, for some reason, are failing; our objective is to find whatever errors cause the tests to fail with current Perl 6 implementations, and do a pull-request to the original site that will help the author publish a new, working, version.

Here are a few instructions that will help you through the hackathon.

1. Get into the [#perl6 IRC channel](https://perl6.org/irc) to discuss with other people participating in the hackathon, and get updates of what's being done. Every time something is done in the squashathon, a friendly bot will send a message to that channel. You can use it also to coordinate with the rest of the participants, get help and, of course, give help.

2. [Check out the issues](https://github.com/perl6/ecosystem-unbitrot/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+-label%3A%22PR+sent%22+-label%3A%22deprecated+module%22+-label%3A%22native+dependency%22). These issues are populated before the squashathon with the modules that are currently failing. Choose one to work on, and follow the instructions presented in that issue. The list includes false positives, so it is OK to use `works for me` label often.

3. When you're done, go to another issue!


## Tips if you can't get the module to fail

Before assuming the module works fine for you:

#### Check you've set all env vars that enable module's extra tests

Some modules have optional tests that only run when some env var is set (e.g. `NETWORK_TESTING` or `ONLINE_TESTING`). The test suite's messages will usually tell you about this, but you need to run it in verbose mode:

    $ prove -e "perl6 -Ilib" -vr t/
    [...]
    ok 4 - # SKIP NETWORK_TESTING was not set
    [...]

Set the env var and re-try the test:

    $ NETWORK_TESTING=1 prove -e "perl6 -Ilib" -vr t/

#### Check you've all the optional modules

Same as above, except a module may be looking for optional modules:

    $ prove -e "perl6 -Ilib" -vr t/
    [...]
    ok 1 - # SKIP 'Compress::Zlib' not installed won't test
    [...]

Install the optional module and re-try the test:

    $ zef install Compress::Zlib
    [...]
    $ prove -e "perl6 -Ilib" -vr t/

**Check you didn't have some of the prerequisites installed**

A module missing from `requires` will cause an install failure, but it won't be noticable for you if you already have that missing module installed. You can uninstall modules with `zef uninstall Foo`
