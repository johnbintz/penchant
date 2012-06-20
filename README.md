# I have a penchant for setting up all my projects so they work the same.

I like to do these things in all my projects:

* Have all my tests run before committing. I don't like buying ice cream for the team on test failures.
* If I'm developing gems alongside this project, I use a `Gemfile.penchant` to get around the "one gem, one source" issue in
  current versions of Bundler.
* If I'm moving to different machines or (heaven forbid!) having other developers work on the project, I want to make
  getting all those local gems as easy as possible.

This gem makes that easier!

## What's it do?

Installs a bunch of scripts into the `scripts` directory of your project:

* `gemfile` which switches between `Gemfile.penchant` environments
* `install-git-hooks` which will do just what it says
* `hooks`, several git hooks that the prior script symlinks into .git/hooks for you
* `initialize-environment`, which bootstraps your local environment so you can get up and running

## Gemfile.penchant?!

Yeah, it's a `Gemfile` with some extras:

``` ruby
source :rubygems

gem 'rails', '3.2.3'
# expands to:
#
# gem 'rake'
# gem 'nokogiri'
# gem 'rack-rewrite'
gems 'rake', 'nokogiri', 'rack-rewrite'

no_deployment do
  group :development, :test do
    gem 'rspec', '~> 2.6.0'

    dev_gems = %w{flowerbox guard-flowerbox}

    # set up defaults for certain gems that are probably being used in envs
    defaults_for dev_gems, :require => nil

    env :local do
      # expands to:
      #
      # gem 'flowerbox', :path => '../flowerbox', :require => nil
      # gem 'guard-flowerbox', :path => '../guard-flowerbox', :require => nil
      gems dev_gems, :path => '../%s'
    end

    env :remote do
      # expands to:
      #
      # gem 'flowerbox', :git => 'git://github.com/johnbintz/flowerbox.git', :require => nil
      # gem 'guard-flowerbox', :git => 'git://github.com/johnbintz/guard-flowerbox.git', :require => nil
      gems dev_gems, :git => 'git://github.com/johnbintz/%s.git'
    end

    # only expanded on Mac OS X
    os :darwin do
      gem 'rb-fsevent'
    end

    # only expanded on Linux
    os :linux do
      gems 'rb-inotify', 'ffi'
    end
  end
end
```

Use `script/gemfile local` to get at the local ones, and `script/gemfile remote` to get at the remote ones.
It then runs `bundle install`.

You can also run `penchant gemfile ENV`.

### Deployment mode

Use `no_deployment` blocks to indicate gems that shouldn't even appear in `Gemfiles` destined for
remote servers. *Very* helpful when you have OS-specific gems and are developing on one platform
and deploying on another, or if you don't want to deal with the dependencies for your testing
frameworks:

``` ruby
no_deployment do
  os :darwin do
    gems 'growl_notify', 'growl', 'rb-fsevent'
  end

  os :linux do
    gem 'libnotify', :require => nil
  end

  group :test do
    # ... all your testing libraries you won't need on the deployed end ...
  end
end
```

Run `penchant gemfile ENV --deployment` to get this behavior. This is run by default when the
pre-commit git hook runs, but only after the default Rake task passes.

## initialize-environment

Get new developers up to speed fast! `script/initialize-environment` does the following when run:

* Check out any remote repos found in `Gemfile.penchant` to the same directory where your current project lives.
  That way, you can have your `Gemfile.penchant` set up as above and everything works cleanly.
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

