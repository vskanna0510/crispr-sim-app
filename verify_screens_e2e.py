import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By

options = Options()
options.add_argument('--headless=new')
options.add_argument('--window-size=1280,800')

driver = webdriver.Chrome(options=options)
try:
    driver.get('http://127.0.0.1:3000')
    time.sleep(5)
    
    body = driver.find_element(By.TAG_NAME, 'body')

    # Click Email field (center x=0, y=0)
    ActionChains(driver).move_to_element_with_offset(body, 0, 0).click().send_keys('scientist_92409a@crisprsim.org').perform()
    time.sleep(1)

    # Click Password field (center x=0, y=65)
    ActionChains(driver).move_to_element_with_offset(body, 0, 65).click().send_keys('MySecretPassword2026!').perform()
    time.sleep(1)

    # Click Sign in button (center x=0, y=130)
    ActionChains(driver).move_to_element_with_offset(body, 0, 130).click().perform()
    time.sleep(6)

    # Save home screen screenshot
    driver.save_screenshot(r'd:\Crispr\crispr_sim\Test Results\Screenshots\verified_home_screen.png')
    print('Saved verified_home_screen.png')

    # Click 'Start Simulation' button (center x=0, y=280)
    ActionChains(driver).move_to_element_with_offset(body, 0, 280).click().perform()
    time.sleep(5)

    # Save input screen screenshot
    driver.save_screenshot(r'd:\Crispr\crispr_sim\Test Results\Screenshots\verified_input_screen.png')
    print('Saved verified_input_screen.png')

finally:
    driver.quit()
