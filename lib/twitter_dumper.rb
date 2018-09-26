require "twitter_dumper/version"
require "selenium-webdriver"

module TwitterDumper
  class Navigator
    attr_reader :url, :options, :driver

    def initialize(username, shot_path = "/tmp", since_date = '2013-01-01')
      @since_date = Date.parse(since_date)
      @url = "https://twitter.com/search?f=tweets&vertical=default&q=from%3A#{username}%20since%3A{since}%20until%3A{until}include%3Aretweet&src=typd"
      @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
      @driver = Selenium::WebDriver.for(:chrome, options: options)
      @shot_path = "#{shot_path}/#{username}_{counter}.png"
    end

    def pray_and_run!
      counter = 1
      (@since_date..Date.today).each do |date|
        url = @url.gsub("{since}", date.to_s).gsub("{until}", (date + 1).to_s)
        puts "page #{counter} - #{url}"
        @driver.get(url)
        resize_window!
        current_shot(counter)
        counter += 1
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

    def current_shot(counter = 0)
      shot = @driver.screenshot_as(:png)
      File.open(@shot_path.gsub("{counter}", counter.to_s), "w+") do |file|
        file.write(shot)
      end
    end
  end
end
