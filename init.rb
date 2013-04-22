require 'authenticated_system'
ActionController::Base.send :include, AuthenticatedSystem
begin
  Test::Unit::TestCase.send :include, AuthenticatedSystem::Test
rescue NameError
  # Don't care if this fails when not testing
end
