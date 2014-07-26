require 'json'
require 'net/http'
require 'net/http/post/multipart'

module Services
  STRAVA_URL = 'https://www.strava.com'
  STRAVA_API_V3 = '/api/v3/'

  def upload_to_strava(files, conf)
    upload_uri = URI.join(STRAVA_URL, STRAVA_API_V3, 'uploads')

    if not conf.has_key? 'token'
      STDERR.puts "To upload to Strava, you must provide a valid access token"
      raise "No access token provided"
    end

    token = conf['token']
    auth = { 'Authorization' => "Bearer #{token}" }

    files.each do |fit_file|
      req = Net::HTTP::Post::Multipart.new(upload_uri.path, {
        'data_type' =>  'fit',
        'file' =>       UploadIO.new(fit_file, "application/octet-stream")
      }, initheader = auth)

      res = Net::HTTP.start(upload_uri.host) { |http| http.request(req) }
      mesg = JSON.parse res.body

      if res.code == "201" && mesg['error'].nil?
        # Success
        # ID: mesg['id']]

        loop do
          check_uri = URI.join(STRAVA_URL, STRAVA_API_V3, "uploads/#{mesg['id']}")
          req = Net::HTTP::Get.new(check_uri.path, initheader = auth)
          res = Net::HTTP.start(check_uri.host) { |http| http.request(req) }
          mesg = JSON.parse res.body

          case mesg['status']
          when /activity is ready/
            break
          when /activity has been deleted/
            STDERR.puts "Error: activity deleted."
            break
          when /error processing your activity/
            STDERR.puts "Error processing activity"
            STDERR.puts "#{mesg.error}"
            break
          else
            sleep 2
          end
        end

        puts "#{fit_file} uploaded to #{STRAVA_URL}/activities/#{mesg['activity_id']}"

      else
        STDERR.puts "Error uploading #{fit_file}"
        STDERR.puts "#{mesg['error']}"
      end

    end
  end
end
