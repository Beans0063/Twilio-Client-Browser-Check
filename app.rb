require 'rubygems'
require 'bundler'
Bundler.require

configure do
  set :twilio_account_sid, "ACXXXXXXXXXX"
  set :twilio_auth_token, "XXXXXXXXXXXX"
  set :twilio_app_sid, "APXXXXXXXXXX"
end

get '/' do
  @token=generate_token(params[:name])
  @browser=full_browser_name
  @browser_compatible= compatible_browser? ? "true" : "false"
  @lion=lion?
  erb :client_test
end


def generate_token(operator_name)
  # generate a Twilio Client token that allows inbound calling. Client name will be <operator_name>.
  twilio_capability = Twilio::Util::Capability.new(settings.twilio_account_sid, settings.twilio_auth_token)
  twilio_capability.allow_client_outgoing(settings.twilio_app_sid,  {})
  twilio_token = twilio_capability.generate
end 

def lion?
  request.env['HTTP_USER_AGENT'].index("OS X 10_7") ||   request.env['HTTP_USER_AGENT'].index("OS X 10.7")
end

def compatible_browser?
  # valid browsers:
  # Firefox >= 3.6
  # IE 7,8,9
  # Safari >= 5
  # Chrome >= 11
  begin
    return true if browser_name=="firefox" && browser_version.to_f>=3.6
    return true if browser_name.index("ie") && browser_version.to_f>=7
    return true if browser_name=="safari" && browser_version.to_f>=5
    return true if browser_name=="chrome" && browser_version.to_f>=11
  rescue
    return false
  end

end

def full_browser_name
  browser_name + ' ' + browser_version
end

def browser_version
  version=''
  result  = request.env['HTTP_USER_AGENT']
  if result =~ /Safari/
    unless result =~ /Chrome/
      version = result.split('Version/')[1].split(' ').first#.split('.').first
    else
      version = result.split('Chrome/')[1].split(' ').first#.split('.').first
    end
  elsif result =~ /Firefox/
    version = result.split('Firefox/')[1]#.split('.').first
  elsif result =~ /Opera/
    version = result.split('Version/')[1]#.split('.').first
  elsif result =~ /MSIE/
    version = result.split('MSIE')[1].split(' ').first.split(";").first
  end
  return version
end
      
def browser_name
user_agent =  request.env['HTTP_USER_AGENT'].downcase 
@users_browser ||= begin
  if user_agent.index('msie') && !user_agent.index('opera') && !user_agent.index('webtv')
                'ie'+user_agent[user_agent.index('msie')+5].chr
    elsif user_agent.index('firefox/')
        'firefox'
    elsif user_agent.index('gecko/')
        'gecko'
    elsif user_agent.index('opera')
        'opera'
    elsif user_agent.index('konqueror')
        'konqueror'
    elsif user_agent.index('ipod')
        'ipod'
    elsif user_agent.index('ipad')
        'ipad'
    elsif user_agent.index('iphone')
        'iphone'
    elsif user_agent.index('chrome/')
        'chrome'
    elsif user_agent.index('applewebkit/')
        'safari'
    elsif user_agent.index('googlebot/')
        'googlebot'
    elsif user_agent.index('msnbot')
        'msnbot'
    elsif user_agent.index('yahoo! slurp')
        'yahoobot'
    #Everything thinks it's mozilla, so this goes last
    elsif user_agent.index('mozilla/')
        'gecko'
    else
        'unknown'
    end
    end

    return @users_browser
end