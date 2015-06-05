require 'microsoft_translator'
module Lita
  module Handlers
    class EnEspanol < Handler
      config :target_room
      config :source_room
      config :ms_client_id
      config :ms_client_secret
      config :target_language

      route(/.*/, :translate)

      def translate(response)
        return unless response.message.source.room == config.source_room
        translator = MicrosoftTranslator::Client.new(config.ms_client_id, config.ms_client_secret)
        translated = translator.translate(response.message.body, "en", config.target_language, "text/plain")
        post_message_to_alternate_room(translated, response.message.user)
      end

      def post_message_to_alternate_room(message, user)
        @adapter ||= robot.send :adapter
        @api ||= Lita::Adapters::Slack::API.new(@adapter.config)
        outgoing_params = {
          :channel => config.target_room,
          :username => user.name,
          :icon_url => icon_url(user.id),
          :text => message,
        }
        message = @api.send :call_api, 'chat.postMessage', outgoing_params
      end

      def icon_url(id)
        if url = redis.hget(:icon_urls, id)
          return url
        else
          @adapter ||= robot.send :adapter
          @api ||= Lita::Adapters::Slack::API.new(@adapter.config)
          user_object = @api.send :call_api, 'users.info', :user => id
          url = user_object["user"]["profile"]["image_72"]
          redis.hmset(:icon_urls, id, url)
          return url
        end
      end

    end

    Lita.register_handler(EnEspanol)
  end
end
