## matthew-dailey.github.io

This project is my personal blog hosted on GitHub Pages running Jekyll, which itself is pretty neat!

[matthew-dailey.github.io](https://matthew-dailey.github.io/)

## Building

Normally, `jekyll serve` works just fine.

If there are errors about missing dependencies, `bundle exec jekyll serve` should work better.

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

The blog posts themselves are [licensed](_posts/LICENSE) under the CC-BY-SA 4.0 International License.
This **only** includes files within the `_posts` directory.

This project uses the [blueface](https://github.com/tnguyen/blueface) theme, also MIT Licensed.
