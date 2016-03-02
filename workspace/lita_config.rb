Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = "BuildBot"

  # The locale code for the language to use.
  # config.robot.locale = :en

  # The severity of messages to log. Options are:
  # :debug, :info, :warn, :error, :fatal
  # Messages at the selected level and above will be logged.
  config.robot.log_level = :info

  config.http.port = 8082

  # An array of user IDs that are considered administrators. These users
  # the ability to add and remove other users from authorization groups.
  # What is considered a user ID will change depending on which adapter you use.
  # config.robot.admins = ["1", "2"]

  # The adapter you want to connect with. Make sure you've added the
  # appropriate gem to the Gemfile.
  # config.robot.adapter = :shell

  ## Example: Set options for the chosen adapter.
  # config.adapter.username = "myname"
  # config.adapter.password = "secret"

  ## Example: Set options for the Redis connection.
  # config.redis.host = "127.0.0.1"
  # config.redis.port = 1234

  ## Example: Set configuration for any loaded handlers. See the handler's
  ## documentation for options.
  # config.handlers.some_handler.some_config_key = "value"

  config.robot.adapter = :slack
  config.adapters.slack.token = ENV['SLACK_TOKEN']

  config.handlers.teamcity.site             = ENV['TEAMCITY_SITE']
  config.handlers.teamcity.username         = ENV['TEAMCITY_USERNAME'] || ''
  config.handlers.teamcity.password         = ENV['TEAMCITY_PASSWORD'] || ''
  config.handlers.teamcity.git_uri          = ENV['GIT_URI'] || ''
  config.handlers.teamcity.python_script    = ENV['PYTHON_SCRIPT'] || ''

end
