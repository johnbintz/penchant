@fakefs
Feature: Gemfiles
  Scenario: When rebuilding for deployment, save the original state
    Given I have the file "Gemfile.erb" with the content:
      """
      this is content
      """
      And I have the file "Gemfile" with the content:
      """
      # generated by penchant, environment: local
      """
    When I rebuild the Gemfile for "production" mode with deployment
    Then the file "Gemfile" should have the following content:
      """
      # generated by penchant, environment: production, deployment mode (was local)
      this is content
      """

  Scenario: When unbundling from deployment with an original state, switch to that state
    Given I have the file "Gemfile.erb" with the content:
      """
      this is content
      """
      And I have the file "Gemfile" with the content:
      """
      # generated by penchant, environment: production, deployment mode (was local)
      """
    When I rebuild the Gemfile asking to switch back to the previous state
    Then the file "Gemfile" should have the following content:
      """
      # generated by penchant, environment: local
      this is content
      """

  Scenario: Simple env
    Given I have the file "Gemfile.erb" with the content:
      """
      gem 'test'
      <% env :local do %>
        gem 'test'
      <% end %>
      """
    When I rebuild the Gemfile for "local" mode
    Then the file "Gemfile" should have the following stripped content:
      """
      # generated by penchant, environment: local
      gem 'test'
      gem 'test'
      """

  Scenario: Use placeholder expansion
    Given I have the file "Gemfile.erb" with the content:
      """
      <% env :local, :path => '../%s' do %>
        gem 'test'
      <% end %>
      """
    When I rebuild the Gemfile for "local" mode

    Then the file "Gemfile" should have the following stripped content:
      """
      # generated by penchant, environment: local
      gem 'test', {:path=>"../test"}
      """

  Scenario: Use a gem list for an operation
    Given I have the file "Gemfile.erb" with the content:
      """
      <% gems 'test' do %>
        <% env :local, :path => '../%s' do %>
          <%= gem %>
        <% end %>
      <% end %>
      """
    When I rebuild the Gemfile for "local" mode
    Then the file "Gemfile" should have the following stripped content:
      """
      # generated by penchant, environment: local
      gem 'test', {:path=>"../test"}
      """
  
  Scenario: Let gem get additional info
    Given I have the file "Gemfile.erb" with the content:
      """
      <% gems 'test' do %>
        <%= gem :path => '../%s' %>
      <% end %>
      """
    When I rebuild the Gemfile for "local" mode
    Then the file "Gemfile" should have the following content:
      """
      # generated by penchant, environment: local

        gem 'test', {:path=>"../test"}

      """
  
  Scenario: Use a gem list without a block
    Given I have the file "Gemfile.erb" with the content:
      """
      <% gems 'test', :path => '../%s' %>
      """
    When I rebuild the Gemfile for "local" mode
    Then the file "Gemfile" should have the following content:
      """
      # generated by penchant, environment: local
      gem 'test', {:path=>"../test"}

      """

  Scenario: Use a gem list with an array
    Given I have the file "Gemfile.erb" with the content:
      """
      <% gems [ 'test' ], :path => '../%s' %>
      """
    When I rebuild the Gemfile for "local" mode
    Then the file "Gemfile" should have the following content:
      """
      # generated by penchant, environment: local
      gem 'test', {:path=>"../test"}

      """

