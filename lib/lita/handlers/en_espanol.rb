require 'microsoft_translator'
module Lita
  module Handlers
    class EnEspanol < Handler
      LANGUAGES = {
        "ar" => "Arabic",
        "bs-Latn" => "Bosnian (Latin)",
        "bg" => "Bulgarian",
        "ca" => "Catalan",
        "zh-CHS" => "Chinese Simplified",
        "zh-CHT" => "Chinese Traditional",
        "hr" => "Croatian",
        "cs" => "Czech",
        "da" => "Danish",
        "nl" => "Dutch",
        "en" => "English",
        "et" => "Estonian",
        "fi" => "Finnish",
        "fr" => "French",
        "de" => "German",
        "el" => "Greek",
        "ht" => "Haitian Creole",
        "he" => "Hebrew",
        "hi" => "Hindi",
        "mww" => "Hmong Daw",
        "hu" => "Hungarian",
        "id" => "Indonesian",
        "it" => "Italian",
        "ja" => "Japanese",
        "tlh" => "Klingon",
        "ko" => "Korean",
        "lv" => "Latvian",
        "lt" => "Lithuanian",
        "ms" => "Malay",
        "mt" => "Maltese",
        "no" => "Norwegian",
        "fa" => "Persian",
        "pl" => "Polish",
        "pt" => "Portuguese",
        "otq" => "Querétaro Otomi",
        "ro" => "Romanian",
        "ru" => "Russian",
        "sr-Cyrl" => "Serbian (Cyrillic)",
        "sr-Latn" => "Serbian (Latin)",
        "sk" => "Slovak",
        "sl" => "Slovenian",
        "es" => "Spanish",
        "sv" => "Swedish",
        "th" => "Thai",
        "tr" => "Turkish",
        "uk" => "Ukrainian",
        "ur" => "Urdu",
        "vi" => "Vietnamese",
        "cy" => "Welsh",
        "yua" => "Yucatec Maya"
      }

      config :target_room
      config :source_room
      config :ms_client_id
      config :ms_client_secret
      config :language

      route(/.*/, :translate_message)
      route(/set language to/i, :set_language, command: true)
      route(/list languages/i, :list_languages, command: true)

      def set_language(response)
        return unless response.message.source.room == config.target_room
        input_key = response.args[2..-1].join(" ")
        # See if someone asked for a language code
        language = LANGUAGES.select do |key, value|
          key.downcase == input_key.downcase ||
          value.downcase == input_key.downcase
        end
        # Respond with an error message
        if language.empty?
          response.reply(translate("I can not find that language."))
        else
          redis.set(:language, language.keys[0])
          response.reply(translate("I have set the language to #{language.values[0]}"))
        end
      end

      def list_languages(response)
        return unless response.message.source.room == config.target_room
        response.reply("```" + LANGUAGES.map{|k, v| "#{k} = #{v}"}.join("\n") + "```")
      end

      def translate_message(response)
        return if response.user.id.empty?
        return unless response.message.source.room == config.source_room

        # Assign the message to a temporary variable
        message = response.message.body
        # Find all emoji
        emoji = message.scan(/\:\w*\:/)
        # Replace emoji with untranslatable placeholders
        emoji.each_with_index{|match, index| message.sub!(match, "[[#{index}]]") }
        # Translate the message
        translated = translate(message) || message
        # Put Emoji Back
        emoji.each_with_index{|match, index| translated.sub!("[[#{index}]]", match) }
        post_message_to_target_room(translated, response.user)
      end

      def translate(message)
        translator = MicrosoftTranslator::Client.new(config.ms_client_id, config.ms_client_secret)
        translator.translate(message, nil, language, "text/plain")
      end

      def language
        redis.get(:language) || config.language
      end

      def post_message_to_target_room(message, user)
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
