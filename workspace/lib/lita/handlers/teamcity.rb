

# lita-teamcity plugin
module Lita
  # Because we can.
  module Handlers
    # Main handler
    # rubocop:disable Metrics/ClassLength
    class Teamcity < Handler
      namespace 'Teamcity'

      config :site, required: true, type: String
      config :username, required: true, type: String, default: ''
      config :password, required: true, type: String, default: ''
      config :project_grep, required: false, type: String, default: ''

      config :context, required: false, type: String, default: ''
      config :format, required: false, type: String, default: 'verbose'
      config :ignore, required: false, type: Array, default: []
      config :rooms, required: false, type: Array

      #include ::Teamcityhelper::Regex

      PR_PATTERN      = /(?<pr>pr[0-9]{1,3})/
      BUILD_ID_PATTERN = /(?<build_id>[a-zA-Z0-9\_]{4,100})/

      route(
        /^list$/,
        :list,
        command: true,
        help: {
          t('help.list.syntax') => t('help.list.desc')
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
        /^build\s#{BUILD_ID_PATTERN}$/,
        :build,
        command: true,
        help: {
          t('help.build.syntax') => t('help.build.desc')
        }
      )

      def list(response)
        begin
          build_types = fetch_build_types()
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

      def fetch_build_types()
        response_str = ''

        http = Curl.get("#{config.site}/guestAuth/app/rest/buildTypes") do|http|
          http.headers['Accept'] = 'application/json'
        end
        data = JSON.parse(http.body_str)

        data['buildType'].each do |build_type|
          unless config.project_grep.nil?
            config.project_grep.split(",").each do |str|
              if build_type['projectName'] =~ /^#{str}/
                response_str << "#{build_type['projectName']} :: id=`#{build_type['id']}`\n"
              end
            end
          end
        end

        return response_str
      end
      # rubocop:enable Metrics/AbcSize
    end
    # rubocop:enable Metrics/ClassLength
    Lita.register_handler(Teamcity)
  end
end
