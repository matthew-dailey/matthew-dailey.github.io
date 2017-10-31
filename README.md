## matthew-dailey.github.io

This project is my personal blog hosted on GitHub Pages running Jekyll, which itself is pretty neat!

[matthew-dailey.github.io](https://matthew-dailey.github.io/)

## Building

Normally, `jekyll serve` works just fine.

If there are errors about missing dependencies, `bundle exec jekyll serve` should work better.

### Building within Docker

If you have `docker-compose` installed, it's pretty easy.
Then you can skip installing ruby/gem/bundler/jekyll.

To run the container in the foreground:

```
# need --service-ports to expose the ports in docker-compose.yml
docker-compose run --service-ports site jekyll serve
```

To run the container in the background:

```
# builds out the 'site' container based on docker-compose.yml
docker-compose create

# Starts up the 'site' container in the background
# Site should be up at localhost:4000 in 10-30 seconds
docker-compose start site
```

## Creating new posts

```
$ ./new-post.sh "This is a post title"
Created ./_posts/2017-10-06-this-is-a-post-title.markdown
 
$ cat ./_posts/2017-10-06-this-is-a-post-title.markdown
---
layout: post
title:  "This is a post title"
date:   2017-10-06 22:00:00
tags:
---
```

## Licenses

Code for this project is [licensed](LICENSE) under the MIT License.
This also includes code snippets within any blog posts.

The blog posts themselves are [licensed](_posts/LICENSE) under the CC-BY-SA 4.0 International License.
This **only** includes files within the `_posts` directory.

This project uses the [blueface](https://github.com/tnguyen/blueface) theme, also MIT Licensed.
