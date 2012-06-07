When /^I request the list of git repositories$/ do
  @repos = Penchant::Gemfile.defined_git_repos
end
