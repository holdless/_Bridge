from selenium import webdriver
import time

driver = webdriver.Chrome('D:/Users/changyht/Downloads/tool/coding/python/chromedriver') #8.3
driver.maximize_window()
driver.get('https://zh.surveymonkey.com/r/EmployeeHealthCheck')
driver.implicitly_wait(8)

#agreeButton = driver.find_element_by_id('484584749_3199605580_label')
agreeButton = driver.find_element_by_xpath('//*[@id="486014833_3209788694_label"]')
agreeButton.click()

#employeeIdInput = driver.find_element_by_id('484584746')
employeeIdInput = driver.find_element_by_xpath('//*[@id="486014830"]')
employeeIdInput.clear()
employeeIdInput.send_keys("056860")

#foreheadThermometer = driver.find_element_by_id('430334644_2860832441_label')
foreheadThermometer = driver.find_element_by_xpath('//*[@id="486014835_3209788698_label"]')
foreheadThermometer.click()

#bodyTemperature = driver.find_element_by_id('430334640')
bodyTemperature = driver.find_element_by_xpath('//*[@id="486014831"]')
bodyTemperature.clear()
bodyTemperature.send_keys('35.4')

doesNotContact =  driver.find_element_by_xpath('//*[@id="486015076_3209796414_label"]')
doesNotContact.click()

#antipyretic = driver.find_element_by_id('447437405_2965044714_label')
#antipyretic.click()

#Symptoms = driver.find_element_by_id('430334646_2860832447')
#driver.execute_script("arguments[0].click();", Symptoms)

##from selenium.webdriver.common.action_chains import ActionChains
##action = ActionChains(driver)
##action.move_to_element(Symptoms).perform();

#declaration = driver.find_element_by_id('430334641_2860832427')
#driver.execute_script("arguments[0].click();", declaration)
declaration = driver.find_element_by_xpath('//*[@id="486014832_3209788684_label"]')
declaration.click()

nextPage = driver.find_element_by_xpath('//*[@id="patas"]/main/article/section/form/div[2]/button')
nextPage.click()

time.sleep( 5 )

closePage = driver.find_element_by_xpath('//*[@id="patas"]/main/article/section/form/div[2]/button')
closePage.click()

time.sleep( 5 )

driver.quit()
