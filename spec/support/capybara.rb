def chrome_options
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('no-sandbox')
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1680,1050')
  options
end

# ローカル開発環境でRSpecを行う（webコンテナからchromeコンテナを参照するリモートブラウザ。ブラウザが違うマシンにあるとき用）
Capybara.register_driver :remote_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV['SELENIUM_DRIVER_URL'], options: chrome_options)
end

# CI環境でRSpecを行う（CI上のubuntuでrailsもRSpecも動くため、ローカルとなる。ブラウザが同じマシンにあるとき用）
Capybara.register_driver :local_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options)
end

IS_REMOTE = ENV['SELENIUM_DRIVER_URL'].present?
SYSTEM_SPEC_DRIVER = IS_REMOTE ? :remote_chrome : :local_chrome

if IS_REMOTE
  Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
  Capybara.server_port = 3001
  Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
end
