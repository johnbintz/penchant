require 'cuke-pack/support/pause'
require 'cuke-pack/support/pending'

Before do
  # if you want pending steps to pause before marking the step as pending,
  # set @pause_ok to true

  @pause_ok = false
end

require 'cuke-pack/support/step_writer'
require 'cuke-pack/support/wait_for'
require 'cuke-pack/support/failfast'

# set the level of flaying on the step definitions
# set it to false to skip flaying
flay_level = 32

require 'cuke-pack/support/flay'

