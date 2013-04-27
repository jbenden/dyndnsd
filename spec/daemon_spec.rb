require 'spec_helper'

describe Dyndnsd::Daemon do
  include Rack::Test::Methods
  
  def app
    config = {
      'users' => {
        'test' => {
          'password' => 'secret',
          'hosts' => ['foo.example.org']
        }
      }
    }
    db = Dyndnsd::DummyDatabase.new({})
    updater = Dyndnsd::Updater::Dummy.new
    responder = Dyndnsd::Responder::RestStyle.new
    app = Dyndnsd::Daemon.new(config, db, updater, responder)
    
    Rack::Auth::Basic.new(app, "DynDNS") do |user,pass|
      (config['users'].has_key? user) and (config['users'][user]['password'] == pass)
    end
  end
  
  it 'requires authentication' do
    get '/'
    last_response.status.should == 401
  end
  
  it 'only supports GET requests' do
    authorize 'test', 'secret'
    post '/nic/update'
    last_response.status.should == 405
  end
  
  it 'provides only the /nic/update' do
    authorize 'test', 'secret'
    get '/other/url'
    last_response.status.should == 404
  end
  
  it 'requires the hostname query parameter' do
    authorize 'test', 'secret'
    get '/nic/update'
    last_response.status.should == 422
  end
  
  it 'forbids changing hosts a user does not own' do
    authorize 'test', 'secret'
    get '/nic/update?hostname=notmyhost.example.org'
    last_response.status.should == 403
  end
  
  it 'updates a host on change' do
    authorize 'test', 'secret'
    
    get '/nic/update?hostname=foo.example.org&myip=1.2.3.4'
    last_response.should be_ok
    
    get '/nic/update?hostname=foo.example.org&myip=1.2.3.400'
    last_response.should be_ok
    last_response.body.should == 'Good'
  end
  
  it 'returns no change' do
    authorize 'test', 'secret'
    
    get '/nic/update?hostname=foo.example.org&myip=1.2.3.4'
    last_response.should be_ok
    
    get '/nic/update?hostname=foo.example.org&myip=1.2.3.4'
    last_response.should be_ok
    last_response.body.should == 'No change'
  end
  
  it 'forbids invalid hostnames' do
    pending
  end
  
  it 'outputs status per hostname' do
    pending
  end
  
  it 'supports multiple hostnames in request' do
    pending
  end
end