Feature: CLI
  Scenario: Switch back to the original pre-deployment environment
    Given I have the file "tmp/Gemfile.erb" with the content:
      """
      gem 'rake'
      """
      And I have the file "tmp/Gemfile" with the content:
        """
        # generated by penchant, environment: production, deployment mode (was local)
        """
    When I run "bin/penchant gemfile other --switch-back" in the "tmp" directory
    Then the file "tmp/Gemfile" should have the following content:
      """
      # generated by penchant, environment: local
      gem 'rake'
      """
      And the output should include "fallback: other"

  Scenario: Try to convert a project, ignoring git hooks
    Given I have the file "tmp/Gemfile" with the content:
      """
      source :rubygems
      """
    When I run "bin/penchant convert" in the "tmp" directory
    Then the file "tmp/Gemfile.penchant" should have the following content:
      """
      source :rubygems
      """
      And the output should include "No git"

  @wip
  Scenario: Run in a project where the git hooks are not set up
    Given I have the file "tmp/Gemfile.penchant" with the content:
      """
      gem 'rake'
      """
    Given I have the file "tmp/script/hooks/pre-commit" with the content:
      """
      a penchant hook
      """
    When I run "bin/penchant gemfile remote" in the "tmp" directory
    Then the output should include "git hooks not installed"

  @wip
  Scenario: Run in a project where git hooks are set up
    Given I have the file "tmp/Gemfile.penchant" with the content:
      """
      gem 'rake'
      """
    Given I have the file "tmp/script/hooks/pre-commit" with the content:
      """
      a penchant hook
      """
    Given I have the symlink "tmp/.git/hooks/pre-commit" which points to "tmp/script/hooks/pre-commit"
    When I run "bin/penchant gemfile remote" in the "tmp" directory
    Then the output should not include "git hooks not installed"
