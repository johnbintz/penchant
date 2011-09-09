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
* `initialize-environment`, which bootstraps your local environment so you can get up and running

## initialize-environment

It will also try to run `rake bootstrap`, so add a `:bootstrap` task for things that should happen when you start going
(make databases, other stuff, etc, whatever). This won't run if the `:bootstrap` task is not there.

## Gemfile.erb?!

Yeah, it's a `Gemfile` with ERB in it:

``` erb
<% env :local do %>
  gem 'guard', :path => '../guard'
<% end %>

<% env :remote do %>
  gem 'guard', :git => 'git://github.com/johnbintz/guard.git'
<% end %>
```

Use `script/gemfile local` to get at the local ones, and `script/gemfile remote` to get at the remote ones.
It then runs `bundle install`.

You can also run `penchant gemfile ENV`.

### After-`gemfile` hooks?

Drop a file called `.penchant` in your project directory. It'll get executed every time you switch environments using
Penchant. I use it to tell my Hydra clients to sync and update their Gemfiles, too:

``` ruby
# rake knows if you need "bundle exec" or not.

rake "hydra:sync hydra:remote:bundle"
```

### What environment are you currently using in that Gemfile?

`head -n 1` that puppy, or `penchant gemfile-env`.

## git hook?!

It runs `penchant gemfile remote` then runs `bundle exec rake`. Make sure your default Rake task for the project runs your
tests and performs any other magic necessary before each commit. Your re-environmented Gemfile and Gemfile.lock will be added
to your commit if they've changed.

## How?!

* `gem install penchant`
* `cd` to your project directory

And then one of the following:

* `penchant install` for a new project (`--dir=WHEREVER` will install the scripts to a directory other than `$PWD/scripts`)
* `penchant convert` for an existing project (`--dir=WHEVEVER` works here, too)

