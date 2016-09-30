require "digest"
require "github_api"
require "json"

class GithubHelper
	def initialize(payload)
		token = JSON.parse(payload)["credentials"]["token"]
		@github = ::Github.new(oauth_token: token, per_page: 100, auto_pagination: true)
	end

	def repositories(exclude: [])
		@github.repos.list.select { |repo|
			repo.permissions.admin && !exclude.include?(repo.ssh_url)
		}.map do |repo|
			{
				fn: repo.full_name,
				remote: repo.git_url,
				link: repo.html_url,
				description: repo.description,
			}
		end
	end
end
