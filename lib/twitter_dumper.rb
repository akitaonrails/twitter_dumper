require "twitter_dumper/version"
require "selenium-webdriver"

module TwitterDumper
  class Navigator
    USER_AGENT = 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Trident/5.0)'
    attr_reader :url, :options, :driver

    def initialize(username, shot_path = "/tmp")
      @url = "https://twitter.com/#{username}"
      @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless', "user-agent=#{USER_AGENT}"])
      @driver = Selenium::WebDriver.for(:chrome, options: options)
      @shot_path = "#{shot_path}/#{username}_{counter}.png"
    end

    def pray_and_run!
      initial_fetch!
      counter = 1
      while true
        puts "page #{counter} ..."
        current_shot(counter)
        click_loader!
        counter += 1
      end
    rescue Selenium::WebDriver::Error::NoSuchElementError
      puts "probably done!"
    end

    private

    def initial_fetch!
      @driver.get(@url)
      resize_window!
    end

    def resize_window!
      width  = @driver.execute_script("return Math.max(document.body.scrollWidth, document.body.offsetWidth, document.documentElement.clientWidth, document.documentElement.scrollWidth, document.documentElement.offsetWidth);")
      height = @driver.execute_script("return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight);")
      @driver.manage.window.resize_to(width, height)
    end

    def delete_tweets!
      @driver.execute_script("var tweets = document.getElementsByClassName('tweet'); while(tweets[0]) { tweets[0].parentNode.removeChild(tweets[0])}")
    end

    def click_loader!
      delete_tweets!
      @driver.find_element(link_text: "Load older Tweets").click
      resize_window!
    end

    def current_shot(counter = 0)
      shot = @driver.screenshot_as(:png)
      File.open(@shot_path.gsub("{counter}", counter.to_s), "w+") do |file|
        file.write(shot)
      end
    end
  end
end
