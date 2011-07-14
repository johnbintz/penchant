# I have a penchant for setting up all my projects so they work the same.

I like to do these things in all my projects:

* Have all my tests run before committing. I don't like buying ice cream for the team on test failures.
* If I'm developing gems alongside this project, I use a `Gemfile.erb` to get around the "one gem, one source" issue in
  current versions of Bundler.
* If I'm moving to different machines or (heaven forbid!) having other developers work on the project, I want to make
  getting all those local gems as easy as possible.

This gem makes that easier!

## What's it do?

Installs a bunch of scripts into the `scripts` directory of your project:

* `gemfile` which switches between `Gemfile.erb` environments
* `install-git-hooks` which will do just what it says
* `hooks/pre-commit`, one of the hooks the prior script installs
* `initialize-environment`, which bootstraps your locak environment so you can get up and running

## Gemfile.erb?!

Yeah, it's a `Gemfile` with ERB in it:

``` ruby
<% if env == "local" %>
  gem 'guard', :path => '../guard'
<% else %>
  gem 'guard', :git => 'git://github.com/johnbintz/guard.git'
<% end %>

Use `script/gemfile local` to get at the local ones, and `script/gemfile remote` (or anything, really) to get at the remote ones.
It then runs `bundle install`.

## git hook?!

It runs `script/gemfile remote` then runs `bundle exec rake`. Make sure your default Rake task for the project runs your
tests and performs any other magic necessary before each commit.

## How?!

* `gem install penchant`
* `cd` to your project directory
* `penchant install` (can do `--dir=WHEREVER`, too)

