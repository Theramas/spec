require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  #config.include JsonSpec::Helpers
  #config.include FactoryGirl::Syntax::Methods
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end

#Локаторы:
$jobcenter = "//a[contains(@data-screen-id,'job/job-center')]" #Биржа труда
$job_eslider = "//div[contains(@class,'js-energy-slider c-energy-slider mt-5')]" #Полоса выбора энергии для работы
$joblevel = "//div[contains(@class,'c-progress mt-5')]" #Слайдер уровня работы
$progress = "//div[contains(@class,'c-progress__bar c-progress__bar--gold')]" #Прогресс в прогресс баре работы
$job_level = "//div[contains(@class,'fz-h5 c-yellow-2 pull-left mr-5')]" #Текущий уровень рабочего навыка
$slider_handle = "//div[contains(@class,'js-energy-slider-handle c-energy-slider__handle')]" #Слайдер энергии в работе
$jenergy_cost = "//span[contains(@class,'js-energy-value')]" #Индикатор необходимой для работы энергии
$salary = "//span[contains(@class,'js-salary-value')]" #Количество ЗП за работу при текущих затратах энергии
$workb = "//div[contains(text(),'Работать')]" #Клик "Работать"
$otli4no = "//a[contains(@class,'js-back fz-h4 c-btn c-btn-light c-btn-block fw-500 mt-5 mb-5')]" #Клик "Отлично" в попапе
$military = "//*[@id='menu']/section/div[3]/div[6]/a/div/div/div/table/tbody/tr/td[2]" #Воен-база
$hospital = "//*[@id='menu']/section/div[3]/div[7]/a/div/div/div/table/tbody/tr/td[2]" #Больница
$health = "//i[contains(@class,'icon-hp')]" #Индикатор здоровья
$level = "/html/body/section[1]/div/section/div[1]/div[2]/div/div[1]" #Индикатор уровня персонажа
$maxhealth = "/html/body/section[1]/div/section/div[1]/div[4]/div[1]/div/div[1]/div/span" #Индикатор максимального здоровья
$maxenergy = "/html/body/section[1]/div/section/div[1]/div[4]/div[1]/div/div[2]/div/span" #Индикатор макс энергии
$job = "/html/body/section[1]/div/section/div[3]/div[3]/a/div/div/div/table/tbody/tr/td[2]" #Работа
$energy_meter = "//*[@id='menu']/section/div[1]/div[4]/div[1]/div/div[2]/div" #Индикатор энергии
$gold_meter = "//span[contains(@class,'c-yellow')]" # Индикатор золота
$dollar_meter = "//span[contains(@class,'c-green')]" #Индикатор долларов
$city_indicator = "#profile > div.character > div.character__name.text-center > p.c-blue-4.fz-h6" #Индикатор города\статуса
$port_menu = "/html/body/section[1]/div/section/div[3]/div[14]/a/div/div/div/table/tbody/tr/td[2]"
$yacht_name = "/html/body/section[2]/div/div/div[4]/div[1]/div[2]/div[1]"


#Функции:
def element_present?(how, what)
  @driver.find_element(how, what)
  true
rescue Selenium::WebDriver::Error::NoSuchElementError
  false
end

def alert_present?()
  @driver.switch_to.alert
  true
rescue Selenium::WebDriver::Error::NoAlertPresentError
  false
end

def verify(&blk)
  yield
rescue ExpectationNotMetError => ex
  @verification_errors << ex
end

def close_alert_and_get_its_text(how, what)
  alert = @driver.switch_to().alert()
  alert_text = alert.text
  if (@accept_next_alert) then
    alert.accept()
  else
    alert.dismiss()
  end
  alert_text
ensure
  @accept_next_alert = true
end

def login(log,pass)
    @driver.find_element(:name, "login").clear #Очистка поля логина
    @driver.find_element(:name, "login").send_keys log
    @driver.find_element(:name, "password").clear #Очистка поля пароля
    @driver.find_element(:name, "password").send_keys pass
    @driver.find_element(:xpath, "//button[@type='submit']").click #Нажатие на кнопку "Войти"
    sleep(4)
end

def enter_menu #Вход в боковое меню
      @driver.find_element(:xpath, "//a[contains(@class,'js-back c-header__menu-button c-btn-tap')]").click
end

def return_menu #Возврат в боковое меню
    @driver.find_element(:xpath, "//a[contains(@class,'js-back c-header__menu-button c-btn-tap')]").click
end

def energy_check(a,b) #Рассчет затрат энергии и сравнение с текущим количеством
    current_e = a.to_f - b.to_f
    energy_amount = @driver.find_element(:xpath, "//*[@id='menu']/section/div[1]/div[4]/div[1]/div/div[2]/div")
    expect((energy_amount.text).to_f).to eq(current_e)
end

def gold_check(a,b) #Рассчет затрат золота и сравнение с текущим количеством
    current_g = a.to_f - b.to_f
    gold_amount = @driver.find_element(:xpath, "//span[contains(@class,'c-yellow')]")
    expect((gold_amount.text).to_f).to eq(current_g)
end

def dollar_check(a,b) #Рассчет затрат долларов и сравнение с текущим количеством
    current_d = a.to_f - b.to_f
    dollar_amount = @driver.find_element(:xpath, "//span[contains(@class,'c-green')]")
    expect((dollar_amount.text).to_f).to eq(current_d)
end

def prestige_check(a,b) #Рассчет престижа и сравнение с текущим количеством
    current_e = a.to_f + b.to_f
    prestige_amount = @driver.find_element(:xpath, "//div[@id='menu']/section/div/div/div/div[2]/div")
    expect((prestige_amount.text).to_f).to eq(current_e)
end

def healthChange_check(a)
  	current_e = (a.to_f * 0.08).to_i
    health_amount = @driver.find_element(:xpath, "//div[@id='menu']/section/div/div[4]/div/div/div/div/span")
    expect((health_amount.text).to_f).to eq(current_e)
end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
