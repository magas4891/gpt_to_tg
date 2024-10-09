# frozen_string_literal: true

class TelegramBotController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    message = params['message']['text']
    chat_id = params['message']['chat']['id']

    # Send the message to an external API and get the response
    api_response = send_to_api(message)

    # Send the API response back to the Telegram bot
    send_message(chat_id, api_response)

    head :ok
  end

  private

  def send_to_api(message)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: message}],
        temperature: 0.7,
      })

    # Example of sending the message to an external API
    response.dig("choices", 0, "message", "content")
  rescue StandardError => e
    "Error: #{e.message}"
  end

  def send_message(chat_id, text)
    token = ENV['TELEGRAM_BOT_TOKEN']
    Telegram::Bot::Client.run(token) do |bot|
      bot.api.send_message(chat_id: chat_id, text: text)
    end
  end
end
