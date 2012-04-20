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
* `hooks`, several git hooks that the prior script symlinks into .git/hooks for you
* `initialize-environment`, which bootstraps your local environment so you can get up and running

## Gemfile.erb?!

Yeah, it's a `Gemfile` with ERB in it:

``` erb
<% env :local do %>
  gem 'guard', :path => '../guard'
<% end %>

<% env :remote do %>
  gem 'guard', :git => 'git://github.com/johnbintz/guard.git'
<% end %>

<% no_deployment do %>
  gem 'os-specific-things'
<% end %>
```

Use `script/gemfile local` to get at the local ones, and `script/gemfile remote` to get at the remote ones.
It then runs `bundle install`.

You can also run `penchant gemfile ENV`.

### Deployment mode

Use `no_deployment` blocks to indicate gems that shouldn't even appear in `Gemfiles` destined for
remote servers. *Very* helpful when you have OS-specific gems and are developing on one platform
and deploying on another:

``` erb
<% no_deployment do %>
  require 'rbconfig'
  case RbConfig::CONFIG['host_os']
  when /darwin/
    gem 'growl_notify'
    gem 'growl'
    gem 'rb-fsevent'
  when /linux/
    gem 'libnotify', :require => nil
  end
<% end %>
```

Run `penchant gemfile ENV --deployment` to get this behavior. This is run by default when the
pre-commit git hook runs.

## initialize-environment

Get new developers up to speed fast! `script/initialize-environment` does the following when run:

* Check out any remote repos found in `Gemfile.erb` to the same directory where your current project lives.
  That way, you can have your `Gemfile.erb` set up as above and everything works cleanly.
* Runs `script/gemfile remote` to set your project to using remote repositories.
* Runs `rake bootstrap` for the project if it exists.

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

### Skipping all that Rake falderal?

Do it Travis CI style: stick `[ci skip]` in your commit message. That's why the meat of hte git hooks resides in
`commit-msg` and not `pre-commit`: you need the commit message before you can determine if the tests should be run
based on the commit message. Weird, I know.

## How?!

* `gem install penchant`
* `cd` to your project directory

And then one of the following:

* `penchant install` for a new project (`--dir=WHEREVER` will install the scripts to a directory other than `$PWD/scripts`)
* `penchant update` to update the installation (`--dir=WHEVEVER` works here, too)
* `penchant convert` for an existing project (`--dir=WHEVEVER` works here, too)

