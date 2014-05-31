<p align="center">
  <a href="https://github.com/mirego/encore">
    <img src="http://i.imgur.com/erXBozp.png" alt="Encore" />
  </a>
  <br />
  Encore provides serializers and persisters to build <a href="http://jsonapi.org">JSON API</a>-compliant<br /> Web services with Ruby on Rails.
  <br /><br />
  <a href="https://rubygems.org/gems/encore"><img src="http://img.shields.io/gem/v/encore.svg" /></a>
  <a href="https://travis-ci.org/mirego/encore"><img src="http://img.shields.io/travis/mirego/encore.svg" /></a>
  <a href="https://codeclimate.com/github/mirego/encore"><img src="http://img.shields.io/codeclimate/github/mirego/encore.svg" /></a>
</p>

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'encore'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install encore
```

## Disclaimer

As Encore is under heavy development at the moment, we advise against using this gem in production unless you know exactly what you’re doing. *Breaking changes* are still being committed.

## Basic serializer usage

### Configure your serializer

```ruby
class PostSerializer < Encore::Serializer::Base
  attributes :id, :body, :links

  # By default, root_key will be the pluralized model
  # name. If you want to set a custom root_key, you can
  # do that:
  def self.root_key
    :blog_posts
  end
end
```

The `links` attribute is generated by Encore and will return the included associations. Read more in the [Inclusion](#inclusion) section.

### Returning serialized model

```ruby
class PostsController < ApplicationController
  before_action :fetch_posts, only: %i(index)

  def index
    render json: Encore::Serializer::Instance.new(@posts)
  end

protected

  def fetch_posts
    @posts = Post.all
  end
end
```

Will result in the following JSON output:

```json
{
  "posts": [
    {
      "id": "1",
      "body": "I enjoy having breakfast in bed. I like waking up to the smell of bacon.",
      "links": {
        "author": {
          "href": "/authors/1",
          "id": "1",
          "type": "authors"
        },
        "comments": {
          "href": "/comments?post_id=1",
          "type": "comments"
        }
      }
    }
  ],
  "linked": {},
  "meta": {
    "posts": {
      "page": 1,
      "count": 1,
      "page_count": 1,
      "previous_page": null,
      "next_page": null
    }
  }
```

### Inclusion

Encore can handle model associations. For example, let’s include the `comments` in the code sample above.

```ruby
Encore::Serializer::Instance.new(@posts, include: 'comments')
```

Since we don’t want all associations to be exposed, we also need to allow the serializer to include the association. To do so, we need to update the `CommentSerializer`.

```ruby
class PostSerializer < Encore::Serializer::Base
  # ...

  def self.can_include
    [:author, :comments]
  end
end
```

Requesting `GET /posts?include=comments` will result in the following JSON output:

```json
{
  "posts": [
    {
      "id": "1",
      "body": "First!",
      "links": {
        "comments": ["1"],
        "author": {
          "href": "/authors/1",
          "id": 1,
          "type": "authors"
        }
      }
    }
  ],
  "linked": {
    "comments": [
      {
        "id": "1",
        "title": "FIRST!"
      }
    ]
  },
  "meta": {
    "comments": {
      "page": 1,
      "count": 1,
      "page_count": 1,
      "previous_page": null,
      "next_page": null
    }
  }
```

If you want the `comments` to **always** be included when you request a `post`, update the `PostSerializer` this way:

```ruby
class PostSerializer < Encore::Serializer::Base
  # ...

  def self.always_include
    [:comments]
  end
end
```

## License

`Encore` is © 2013-2014 [Mirego](http://www.mirego.com) and may be freely distributed under the [New BSD license](http://opensource.org/licenses/BSD-3-Clause).  See the [`LICENSE.md`](https://github.com/mirego/encore/blob/master/LICENSE.md) file.

The hazelnut logo is based on [this lovely icon](http://thenounproject.com/term/hazelnuts/3618/) by [Alessandro Suraci](http://thenounproject.com/alessandro.suraci/), from The Noun Project. Used under a [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/) license.

## About Mirego

[Mirego](http://mirego.com) is a team of passionate people who believe that work is a place where you can innovate and have fun. We’re a team of [talented people](http://life.mirego.com) who imagine and build beautiful Web and mobile applications. We come together to share ideas and [change the world](http://mirego.org).

We also [love open-source software](http://open.mirego.com) and we try to give back to the community as much as we can.
