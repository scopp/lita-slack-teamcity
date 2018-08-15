require 'spec_helper'

describe Lita::Handlers::Teamcity, lita_handler: true do
  before do
    registry.config.handlers.teamcity.site             = 'https://build.ankicore.com'
    registry.config.handlers.teamcity.username         = 'username'
    registry.config.handlers.teamcity.password         = 'password'
    registry.config.handlers.teamcity.git_uri          = 'git@github.com:anki'
    registry.config.handlers.teamcity.python_script    = 'python python_script.py'
  end

  describe '#fetch_build_types' do
    build_type_json_str = '{"buildType":[{"id":"Wildcard_A","projectName":"Wildcard :: A"},
                                         {"id":"B_Wildcard","projectName":"Wildcard :: B"},
                                         {"id":"C_Wildcard_C","projectName":"Wildcard :: C"},
                                         {"id":"NoneProject","projectName":"None :: None"}]}'
    before do
      stub_request(:get, /buildTypes/).to_return(:status => 200, :body => build_type_json_str)
    end

    it 'response_str contains all builds if build_id_wildcard is nil' do
      output_string = subject.fetch_build_types(nil)
      expect(output_string).to include("Wildcard_A", "Wildcard :: A", "B_Wildcard", "Wildcard :: B", 
                                       "C_Wildcard_C", "Wildcard :: C", "NoneProject", "None :: None")
    end

    it 'response_str contains all builds that build_id contains build_id_wildcard' do
      output_string = subject.fetch_build_types("Wildcard")
      expect(output_string).to include("Wildcard_A", "Wildcard :: A", "B_Wildcard", "Wildcard :: B", 
                                       "C_Wildcard_C", "Wildcard :: C")
    end

    it 'response_str is empty if no build_id contains build_id_wildcard' do
      output_string = subject.fetch_build_types("Invalid")
      expect(output_string).to eq("")
    end
  end

  describe '#artifacts_by_build_id' do
    build_type = "CozmoOne_MasterBuild"
    build_id = "4307"

    it 'result eq.to empty if data[count] = 0' do
      artifact_json = '{"count":0,"file":[]}'
      stub_request(:get, /artifacts/).to_return(:status => 200, :body => artifact_json)
      output_string = subject.artifacts_by_build_id(build_type, build_id)
      expect(output_string).to eq("")
    end

    it 'result eq.to empty if data[count] > 0 and data[file] is empty' do
      artifact_json = '{"count":1,"file":[]}'
      stub_request(:get, /artifacts/).to_return(:status => 200, :body => artifact_json)
      output_string = subject.artifacts_by_build_id(build_type, build_id)
      expect(output_string).to eq("")
    end

    it 'result not contains empty artifact name if file[name] = ""' do
      artifact_json = '{"count":1,"file":[{"name":"","size":63}]}'
      stub_request(:get, /artifacts/).to_return(:status => 200, :body => artifact_json)
      output_string = subject.artifacts_by_build_id(build_type, build_id)
      expect(output_string).not_to include("|>")
    end

    it 'result contains all artifacts url and text' do
      artifact_name_1 = "filename1"
      artifact_name_2 = "filename2"
      artifact_url_1 = "#{registry.config.handlers.teamcity.site}/repository/download/"\
                       "#{build_type}/#{build_id}:id/#{artifact_name_1}"
      artifact_url_2 = "#{registry.config.handlers.teamcity.site}/repository/download/"\
                       "#{build_type}/#{build_id}:id/#{artifact_name_2}"
      expected_output = "\n<#{artifact_url_1}|#{artifact_name_1}>\n<#{artifact_url_2}|#{artifact_name_2}>"
      artifact_json = '{"count":1,"file":[{"name":"filename1","size":63},{"name":"filename2","size":63}]}'
      stub_request(:get, /artifacts/).to_return(:status => 200, :body => artifact_json)
      output_string = subject.artifacts_by_build_id(build_type, build_id)
      expect(output_string).to eq(expected_output)
    end

  end
end
