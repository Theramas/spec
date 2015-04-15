#encoding: UTF-8
require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "HospitalSpec" do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://localhost:9000/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
    @driver.manage.window.resize_to(1301, 744)
  end

  
  after(:each) do
    @driver.quit
    expect(@verification_errors).to eq([])
  end
  
  it "Лечение травм: получение, проверка негативных эффектов, лечение, проверка стоимости лечения" do
    login("Vernon","freestyle")
    enter_menu
    before_e = "/ 100" #@driver.find_element(:xpath, $maxenergy).text #Макс энергия до боя
    @driver.find_element(:xpath, $military).click #Вход на воен. базу
    @driver.find_element(:xpath, "//a[contains(@class,'js-back c-icon-menu-6 c-header__menu-button')]").click #Возврат в боковое меню
    before_d = @driver.find_element(:xpath, $dollar_meter).text #Долларов до лечения
    @driver.find_element(:xpath, $hospital).click #Вход в больницу
    light = @driver.find_elements(:xpath, "//div[contains(text(),'У вас легкая травма')]").size() #Количество легких травм у персонажа
    medium = @driver.find_elements(:xpath, "//div[contains(text(),'У вас средняя травма')]").size() #Количество средних травм у персонажа
    severe = @driver.find_elements(:xpath, "//div[contains(text(),'У вас тяжелая травма')]").size() #Количество тяжелых травм у персонажа
    light_cost = 300 #Цена лечения легкой
    medium_cost = 450 #Цена лечения средней
    severe_cost = 600 #Цена лечения тяжелой
    cost_d = (light*light_cost) + (medium*medium_cost) + (severe*severe_cost) #Затраты на полное лечение всех травм
    return_menu #Возврат в боковое меню
    after_e = before_e[2...6].to_f - ((before_e[2...6].to_f*light*0.1) + (before_e[2...6].to_f*medium*0.15) + (before_e[2...6].to_f*severe*0.2)) #Ожидаемое количество энергии при травмах
    expect(@driver.find_element(:xpath, $maxenergy).text).to eq("/ "+(after_e.to_i).to_s) #Проверка влияния травм на макс энергию
    @driver.find_element(:xpath, $hospital).click #Вход в больницу  
    #Лечение травм
    t = 0
    while t < (light+medium+severe) do;
         @driver.find_element(:xpath, "//a[contains(@class,'js-heal-trauma btn btn-primary btn-sm')]").click #Клик "Вылечиться"
         sleep(4)
         alert = @driver.switch_to.alert #Переключение на алерт
         expect(alert.text).to eq("You're healed") #Проверка текста алерта
         alert.accept #Закрыть алерт    
         t = t + 1
         sleep(4)
    end  
    return_menu #Возврат в боковое меню
    expect(@driver.find_element(:xpath, $maxenergy).text).to eq(before_e) #Проверка возврата макс энергии в нормальное состояние
    dollar_check(before_d,cost_d) #Проверка затрат долларов на лечение травм

  end

end
