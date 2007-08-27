require 'authenticated_system'
ActionController::Base.send :include, AuthenticatedSystem
Test::Unit::TestCase.send :include, AuthenticatedSystem::Test