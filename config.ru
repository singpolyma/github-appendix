require "json"
require "omniauth"
require "omniauth-github"
require "sinatra"
require "sinatra/namespace"

require_relative "github"

register Sinatra::Namespace

use Rack::Session::Cookie, secret: ENV.fetch("SESSION_SECRET")

use OmniAuth::Builder do
	provider :github, ENV.fetch('GITHUB_KEY'), ENV.fetch('GITHUB_SECRET'), scope: "user,repo"
end

namespace "/auth" do
	get "/login" do
		slim :login
	end

	delete "/login" do
		session['user'] = nil
		redirect to("/")
	end

	get "/:provider/callback" do
		session['user'] = request.env["omniauth.auth"].to_json

		redirect to('/')
	end
end

get "/" do
	if session['user']
		r = GithubHelper.new(session['user']).repositories.map do |repo|
			"#{repo[:fn]} <#{repo[:link]}>"
		end.join("\n")
		[200, {"Content-Type" => 'text/plain; charset=utf-8'}, r]
	else
		redirect to('/auth/login')
	end
end

run Sinatra::Application
