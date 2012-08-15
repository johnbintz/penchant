# I have a penchant for setting up all my projects so they work the same.

I like to do these things in all my projects:

* Have all my tests run before committing. I don't like buying ice cream for the team on test failures, and setting up internal 
  CI for smaller projects is a pain.
* If I'm developing gems alongside this project, I use a `Gemfile.penchant` to get around the "one gem, one source" issue in
  current versions of Bundler.
* I can also factor out and simplify a lot of my Gemfile settings.
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
# Gemfile.penchant
source :rubygems

# ensure git hooks are installed when a gemfile is processed, see below
ensure_git_hooks!

gem 'rails', '3.2.3'
# expands to:
#
# gem 'rake'
# gem 'nokogiri'
# gem 'rack-rewrite'
gems 'rake', 'nokogiri', 'rack-rewrite'

# define custom gem properties that get expanded to ones bundler understands
property :github, :git => 'git://github.com/$1/%s.git'
  # values to the key are [ value ].flatten-ed and the $s are replaced on the fly,
  # with $1 being the first parameter given

# set up defaults for all gems in a particular environment
defaults_for env(:local), :path => '../%s' # the %s is the name of the gem

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
      gems dev_gems
    end

    env :remote do
      # expands to:
      #
      # gem 'flowerbox', :git => 'git://github.com/johnbintz/flowerbox.git', :require => nil
      # gem 'guard-flowerbox', :git => 'git://github.com/johnbintz/guard-flowerbox.git', :require => nil
      gems dev_gems, :github => 'johnbintz'
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

You can also run `penchant gemfile ENV`. Just straight `penchant gemfile` will rebuild the `Gemfile` from
`Gemfile.penchant` for whatever environment the `Gemfile` is currently using.

If you have an existing project, `penchant convert` will convert the `Gemfile` into a `Gemfile.penchant`
and add some bonuses, like defining that anything in `env :local` blocks automatically reference `..`,
ensuring that hooks are always installed when `penchant gemfile` is executed, and adding the `:github` gem property
that lets you pass in the username of the repo to reference that repo:
`gem 'penchant', :github => 'johnbintz'`.

### Deployment mode

Use `no_deployment` blocks to indicate gems that shouldn't even appear in `Gemfiles` destined for
remote servers. *Very* helpful when you have OS-specific gems and are developing on one platform
and deploying on another, or if you don't want to deal with the dependencies for your testing
frameworks:

``` ruby
gem 'rails'

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

#### Won't this change the project dependencies?!

Probably not. You probably have the "main" gems in your project locked to a version of Rails or
Sinatra or something else, and all of the other gems for authentication, queue processing, etc. are
dependent on that framework. Ripping out your testing framework and deployment helpers really
shouldn't be changing the main versions of your application gems. It WORKSFORME and YMMV.

### Getting local gems all set up

`penchant bootstrap` will go through and find all git repo references in your `Gemfile.penchant` and
will download them to the specified directory (by default, `..`). This means blocks like this
will work as expected when you `penchant bootstrap` and then `penchant gemfile local`:

``` ruby
env :local do
  gem 'my-gem', :path => '../%s'
end

env :remote do
  gem 'my-gem', :git => 'git://github.com/johnbintz/%s.git'
end
```

Note that this just does a quick `git clone`, so if your project is already in there in a different state,
nothing "happens" except that git fails.

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

### Ensuring git hooks get installed

I find that when I pull down new projects I never remember to install the git hooks, which involves an awkward running
of `bundle exec rake` *after* I've already committed code. Since we have computers now, and they can be told to do things,
you can add `ensure_git_hooks!` anywhere in your `Gemfile.penchant` to make sure the git hooks are symlinked to the ones
in the `script/hooks` directory with every processing of `Gemfile.penchant`.

### Performing pre-`bundle exec rake` tasks.

Example: I use a style of Cucumber testing where I co-opt the `@wip` tag and then tell Guard to only run scenarios with `@wip` tags.
I don't want `@wip` tasks to be committed to the repo, since committing a half-completed scenario seems silly.
So I use `bundle exec rake preflight_check` to check all feature files for `@wip` tasks, and to fail if I hit one. Yes, Cucumber
already does this, but in order to get to `bundle exec rake`, I need to go through two `Gemfile` creations, one for `remote --deployment`
and one for `remote` to make sure my tests work on remote gems only.

If `bundle exec rake -T preflight_check` returns a task, that task will be run before all the `Gemfile` switcheroo. *Don't use it
as a place to run your tests!*

### Skipping all that Rake falderal?

Do it Travis CI style: stick `[ci skip]` in your commit message. That's why the meat of the git hooks resides in
`commit-msg` and not `pre-commit`: you need the commit message before you can determine if the tests should be run
based on the commit message. Weird, I know.

## How?!

* No RVM? `gem install penchant`
* RVM? `rvm gemset use global && gem install penchant && rvm gemset use default`
* `cd` to your project directory

And then one of the following:

* `penchant install` for a new project (`--dir=WHEREVER` will install the scripts to a directory other than `$PWD/scripts`)
* `penchant update` to update the installation (`--dir=WHEVEVER` works here, too)
* `penchant convert` for an existing project (`--dir=WHEVEVER` works here, too)

