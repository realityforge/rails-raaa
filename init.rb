require 'authenticated_system'
ActionController::Base.send :include, AuthenticatedSystem
