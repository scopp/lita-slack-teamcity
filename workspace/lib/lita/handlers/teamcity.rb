
# lita-teamcity plugin
module Lita
  module Handlers
    # Main handler
    class Teamcity < Handler
      namespace 'Teamcity'

      config :site, required: true, type: String
      config :username, required: true, type: String, default: ''
      config :password, required: true, type: String, default: ''
      config :git_uri, required: true, type: String, default: ''
      config :python_script, required: true, type: String, default: ''

      config :context, required: false, type: String, default: ''
      config :format, required: false, type: String, default: 'verbose'
      config :ignore, required: false, type: Array, default: []
      config :rooms, required: false, type: Array

      PR_PATTERN       = /(?<pr>pr[0-9]{1,3})/
      BUILD_ID_PATTERN = /(?<build_id>[a-zA-Z0-9\_]{1,100})/
      REPO_PATTERN     = /(?<repo>.+)/

      route(
        /^list$/,
        :list_all,
        command: true,
        help: {
          t('help.list.syntax') => t('help.list.desc')
        }
      )

      route(
        /^list\s#{BUILD_ID_PATTERN}\*$/,
        :list_wild,
        command: true,
        help: {
          t('help.list.syntax_wild') => t('help.list.desc_wild')
        }
      )

      route(
        /^build\s#{BUILD_ID_PATTERN}$/,
        :build,
        command: true,
        help: {
          t('help.build.syntax') => t('help.build.desc')
        }
      )

      route(
        /^build\s#{PR_PATTERN}\sfor\s#{BUILD_ID_PATTERN}$/,
        :buildpr,
        command: true,
        help: {
          t('help.build.prsyntax') => t('help.build.prdesc')
        }
      )

      route(
        /^cp_commits\s+#{REPO_PATTERN}/,
        :list_cps_to_commit,
        command: true,
        help: {
          t('help.cp_commits.syntax') => t('help.build.desc')
        }
      )

      def list_cps_to_commit(response)
        repo = response.match_data['repo']
        repo_uri = "#{config.git_uri}/#{repo}.git"
        log.info "repo_uri : #{repo_uri}"

        repos_dir = File.join(Dir.home, 'repos')
        Dir.mkdir(repos_dir) unless File.exists? File.expand_path("#{repos_dir}")

        if File.exists? File.expand_path("#{repos_dir}/#{repo}")
          response.reply(t('git.fetching'))
          log.info "command  : cd #{repos_dir}/#{repo}/ && git fetch -p"
          result = `cd #{repos_dir}/#{repo}/ && git fetch -p`
        else
          response.reply(t('git.cloning'))
          log.info "command  : cd #{repos_dir}/ && git clone #{repo_uri} #{repo}"
          result = `cd #{repos_dir}/ && git clone #{repo_uri} #{repo}`
        end

        result = `cd #{repos_dir}/#{repo}/ && #{config.python_script}`
        response.reply(t('git.commits'))
        sleep(0.5)
        response.reply("```#{result}```")
      end

      def list_all(response)
        list(response, false)
      end

      def list_wild(response)
        list(response, true)
      end

      def list(response, wildcard)
        begin
          if wildcard
            build_types = fetch_build_types(response.match_data['build_id'])
          else
            build_types = fetch_build_types(nil)
          end
        rescue
          log.error('TeamCity HTTPError')
          response.reply(t('error.request'))
          return
        end

        return response.reply(t('buildtypes.empty')) unless build_types.size > 0

        response.reply(t('buildtypes.list', build_types: build_types))
      end

      def build(response)
        build_id = response.match_data['build_id']
        xml = build_master_xml(build_id)

        build_url = curl_build(xml)
        response.reply("Build has been triggered: #{build_url}")
      end

      def buildpr(response)
        build_id = response.match_data['build_id']
        pr_number = response.match_data['pr'].gsub('pr', '')
        xml = build_pr_xml(pr_number, build_id)

        build_url = curl_build(xml)
        response.reply("Build has been triggered: #{build_url}")
      end

      #########################################
      ############## HELPERS ##################
      #########################################

      def build_master_xml(build_id)
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.build do |b|
          b.buildType(:id=>"#{build_id}")
          b.comment do |c|
            c.text 'Triggering build from TeamCity Slack buildbot.'
          end
        end
      end

      def build_pr_xml(pr_number, build_id)
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.build(:branchName=>"#{pr_number}/merge") do |b|
          b.buildType(:id=>"#{build_id}")
          b.comment do |c|
            c.text 'Triggering build from TeamCity Slack buildbot.'
          end
        end
      end

      def curl_build(xml)
        curl = Curl::Easy.new("#{config.site}/app/rest/buildQueue")
        curl.username = config.username
        curl.password = config.password
        curl.headers["Content-Type"] = 'application/xml'
        curl.post_body=xml
        curl.http_post
        doc = Nokogiri::XML(curl.body_str)
        build_url = doc.at_xpath('//build/@webUrl').text

        return build_url
      end

      def fetch_build_types(build_id_wildcard)
        response_str = ''

        http = Curl.get("#{config.site}/guestAuth/app/rest/buildTypes") do|http|
          http.headers['Accept'] = 'application/json'
        end
        data = JSON.parse(http.body_str)

        data['buildType'].each do |build_type|
          if build_id_wildcard
            if build_type['id'].include? build_id_wildcard
              response_str << "\n#{build_type['projectName']} :: id=`#{build_type['id']}`"
            end
          else
            response_str << "\n#{build_type['projectName']} :: id=`#{build_type['id']}`"
          end
        end

        return response_str
      end

    end
    Lita.register_handler(Teamcity)
  end
end
