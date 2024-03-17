# Bot for announcing events at suno pi toki pona

This bot announces what event is happening right now using Discord webhooks.
It automatically refreshes its information every 10 seconds, to make sure it's never outdated.

You will need to have ruby and bundler installed, together with any dependencies needed to build
gems.

In order to run it, copy `config.sample.yml` to `config.yml`, modify it to fit your needs and
run the following commands:

```
bundler install
bundler exec bin/ilo-suno
```
