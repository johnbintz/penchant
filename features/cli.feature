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

