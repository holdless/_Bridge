import matplotlib.pyplot as plt
import numpy as np

# Define input data
x = np.arange(100, step=.1)
y = x + 20 * np.sin(x/10)
# Plot input data
plt.scatter(x, y)


fit = np.polyfit(x,y,1)
fit_fn = np.poly1d(fit) 
# fit_fn is now a function which takes in x and returns an estimate for y

plt.plot(x,y, 'yo', x, fit_fn(x), '--k')
plt.xlim(-20, 120)
plt.ylim(-20, 120)
