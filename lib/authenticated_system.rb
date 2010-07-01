# The Authenticated System requires that the developer implement two methods in the
# ApplicationController or all controllers that includes this class. These methods
# are "find_active_user(id)" and "access_denied!". See below for sample implementations.
#
#  def find_active_user(id)
#    User.find_by_id(id)
#  end
#
#  def access_denied!
#    if not is_authenticated?
#      redirect_to(:controller=> '/account', :action => 'login')
#    else
#      redirect_to(:controller => '/security', :action => 'access_denied')
#    end
#  end

module AuthenticatedSystem
  # Security error. Controllers throw these in situations where a user is trying to access a
  # function that he is not authorized to access.
  class SecurityError < StandardError
  end

  protected

  def is_authenticated?
    !!current_user
  end

  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights
  # example:
  #
  #  # only allow non-bobs
  #  def authorize?
  #    current_user.name != "bob"
  #  end
  def authorized?
    true
  end

  # accesses the current user from the session.
  def current_user
    @current_user ||= session[:user_id] ? find_active_user(session[:user_id]) : nil
  end

  # store the given user in the session.  overwrite this to set how
  # users are stored in the session.
  def current_user=(user)
    session[:user_id] = user.nil? ? nil : user_to_id(user)
    @current_user = user
    post_set_current_user
  end

  # Method to convert user object into ID to store in session
  def user_to_id(user)
    user.id
  end

  # Template method called when user is set. Override to hook into event.
  def post_set_current_user
  end

  # overwrite this method if you only want to protect certain actions of the controller
  # example:
  #
  #  # don't protect the login and the about method
  #  def protect?
  #    if ['login', 'about'].include?(action_name)
  #       return false
  #    else
  #       return true
  #    end
  #  end
  def protect?
    true
  end

  def check_authorization
    # skip login check if action is not protected
    return true unless protect?
    # check if user is logged in and authorized
    return true if (is_authenticated? and authorized?)

    # store current location so that we can
    # come back after the user logged in
    store_location if store_location?

    # call overwriteable reaction to unauthorized access
    access_denied! and return false
  end

  # Overwrite this method if you don't want to redirect users back to the location they tried
  # to access that forced redirection to login page.
  def store_location?
    true
  end

  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    session[:return_to] = request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    session[:return_to] ? redirect_to_url(session[:return_to]) : redirect_to(default)
    session[:return_to] = nil
  end

  # if an error occurs and it is a security error then redirect to access_denied page
  def rescue_action(e)
     if e.is_a?(AuthenticatedSystem::SecurityError)
        access_denied!
     else
        super
     end
  end
  
  module Test
    def logout
      @controller.instance_variable_set('@current_user', nil)
    end
  end

  def self.included(base)
    base.class_eval do
      before_filter :check_authorization
      helper_method :current_user, :is_authenticated?
    end
  end
end
