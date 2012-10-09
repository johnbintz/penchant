module Penchant
  autoload :Gemfile, 'penchant/gemfile'
  autoload :Repo, 'penchant/repo'
  autoload :DotPenchant, 'penchant/dot_penchant'
  autoload :Hooks, 'penchant/hooks'
  autoload :Env, 'penchant/env'
  autoload :FileProcessor, 'penchant/file_processor'
  autoload :Defaults, 'penchant/defaults'
  autoload :CustomProperty, 'penchant/custom_property'
  autoload :PropertyStack, 'penchant/property_stack'
  autoload :PropertyStackBuilder, 'penchant/property_stack_builder'
  autoload :PropertyStackProcessor, 'penchant/property_stack_processor'
end
