# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :rspec do
  guard 'rspec', :cli => '-c', :version => 2 do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }
  end
end

# added by cuke-pack

group :wip do
  guard 'cucumber', :env => :cucumber, :cli => '-p wip' do
    watch(%r{^features/.+.feature$})
    watch(%r{^(app|lib).*})          { 'features' }
    watch(%r{^features/support/.+$})          { 'features' }
    watch(%r{^features/step_definitions/(.+).rb$}) { 'features' }
  end
end
