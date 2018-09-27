require "twitter_dumper/version"
require "selenium-webdriver"

module TwitterDumper
  class Navigator
    attr_reader :url, :options, :driver

    def initialize(username, shot_path = "/tmp", since_date = '2013-01-01')
      @username = username
      @since_date = Date.parse(since_date)
      @url = "https://twitter.com/search?f=tweets&vertical=default&q=from%3A#{username}%20since%3A{since}%20until%3A{until}include%3Aretweet&src=typd"
      @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
      @driver = Selenium::WebDriver.for(:chrome, options: options)
      @slaves = (1..4).map { Selenium::WebDriver.for(:chrome, options: options) }
      @shot_path = "#{shot_path}/"
    end

    def pray_and_run!
      counter = 1
      (@since_date..Date.today).each do |date|
        url = @url.gsub("{since}", date.to_s).gsub("{until}", (date + 1).to_s)
        puts url
        @driver.get(url)
        @driver.execute_script("window.scrollTo(0, document.body.scrollHeight);") # just in case there is more results in the same day and needs paginating, but only gets 1 extra page ...
        sleep(0.5)
        if @driver.execute_script("return document.getElementsByClassName('SearchEmptyTimeline').length") == 0
          urls = @driver.execute_script("var links = document.getElementsByClassName('js-permalink'); var urls = []; for(var i = 0; i < links.length; i ++ ) { urls[i] = links[i].href}; return urls")
          (urls || []).each do |url|
            @driver.get(url)
            resize_window!
            current_shot(counter, date.to_s)
            counter += 1
          end
        end
      end
    rescue
      puts $!
    ensure
      puts "probably done!"
    end

    private

    def resize_window!
      width  = @driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
      height = @driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
      @driver.manage.window.resize_to(width, height)
    end

    def current_shot(counter = 0, date)
      shot = @driver.screenshot_as(:png)
      Dir.mkdir(@shot_path + date) unless File.directory?(@shot_path + date)
      file_path = @shot_path + date + "/#{@username}_#{counter}.png"
      puts "Saving #{file_path}"
      File.open(file_path, "w+") do |file|
        file.write(shot)
      end
    end
  end
end
