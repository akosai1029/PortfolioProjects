#!/usr/bin/env python
# coding: utf-8

# In[28]:


name = input("Enter your first name: ")

weight = float(input("Enter your weight in kilograms: "))

height = float(input("Enter your height in meters: "))

BMI = round((weight) / (height ** 2), 2)

print()
print("Your BMI is", BMI)


if BMI > 0:
    if BMI <= 18.4:
        print(name + ", you are underweight.")
    elif BMI <= 24.9:
        print(name + ", you are normal.")
    elif BMI <= 39.9:
        print(name + ", you are overweight.")
    elif BMI >= 40:
        print(name + ", you are obese.")
else:
    print("Please enter valid data.")


# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




