# api
require 'net/http'
require 'json'

# cli
require 'open3'
require 'tmpdir'


class Okcugit
  class Contributor < Struct.new(:name, :email)
    def initialize(name:, email:)
      self.name = name
      self.email = email
    end
  end

  def self.contributors_for(owner_slash_repo)
    owner, reponame = owner_slash_repo.split("/", 2)

    # rate limit exceeded >.<
    # API.contributors_for(owner, reponame)
    CLI.contributors_for(owner, reponame)
  end


  # solution using git on the command-line
  class CLI
    def self.contributors_for(owner, reponame)
      stdout = Dir.mktmpdir do |dir|
        Dir.chdir(dir) { run 'git', 'clone', "https://github.com/#{owner}/#{reponame}", reponame }
        Dir.chdir(File.join dir, reponame) { run 'git', 'log', "--format=%an\n%ae"  }
      end

      contributors = stdout.lines.each_slice(2).to_a.uniq.map do |name, email|
        Contributor.new name: name.chomp, email: email.chomp
      end

      contributors.sort_by { |contributor| contributor.name.downcase }
    end

    def self.run(*command)
      stdout, stderr, status = Open3.capture3(*command)
      raise "Exit status: #{status.inspect}, stderr: #{stderr.inspect}" unless status.success?
      stdout
    end
  end

  # solution using the github API... but I got rate limited fast!
  class API
    def self.contributors_for(owner, reponame)
      contributors = get(repo_url_for owner, reponame).map do |contributor|
        user_info = get "https://api.github.com/users/#{contributor[:login]}"
        Contributor.new name: user_info[:name], email: user_info[:email]
      end
      contributors.sort_by(&:name)
    end

    def self.repo_url_for(owner, reponame)
      "https://api.github.com/repos/#{owner}/#{reponame}/contributors"
    end

    def self.get(url)
      JSON.parse Net::HTTP.get(URI url), symbolize_names: true
    end
  end
end
