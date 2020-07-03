from selenium import webdriver
import urllib

driver = webdriver.Chrome('M:\\_tool\\chrome/chromedriver') #8.3
driver.get('http://localhost:8888/notebooks/triplet_loss/tf21_celebrities%20face%20rec.ipynb')

images = driver.find_elements_by_tag_name('img')
k = 1
for image in images:
    src = image.get_attribute('src')
    #print(src)
    urllib.request.urlretrieve(src, str(k)+".png")
    k = k + 1


outputs = driver.find_elements_by_class_name('output_stdout')
with open('output.txt', 'w') as f:
    for output in outputs:
        f.write(output.text + '\n\n\n\n\n\n')
        
f.close()


driver.close()
