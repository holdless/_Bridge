#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  1 20:58:14 2016

@author: hiroshi
"""

import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

_hiddenLayerWidth = 10

def add_layer(inputs, in_size, out_size, activation_function=None):
    Weights = tf.Variable(tf.random_normal([in_size, out_size]))
    biases = tf.Variable(tf.zeros([1, out_size]) + 0.1)
    Wx_plus_b = tf.matmul(inputs, Weights) + biases #matrix multiply

    if activation_function is None:
        outputs = Wx_plus_b
    else:
        outputs = activation_function(Wx_plus_b)

    return outputs

### Create Data : poly. + noise
x_data = np.linspace(-2,2,600)[:,np.newaxis]
noise = np.random.normal(0,0.8,x_data.shape)
# y_data_ori = 1.5*np.power(x_data,3) + 2*np.power(x_data,2) + 1
y_data_ori = 2*x_data + 2 * np.sin(x_data/0.5)
y_data = y_data_ori + noise

xs = tf.placeholder(tf.float32,[None,1])
ys = tf.placeholder(tf.float32,[None,1])

### Create NN graph
l1 = add_layer(xs, 1,  _hiddenLayerWidth, activation_function=tf.nn.relu)
prediction = add_layer(l1 , _hiddenLayerWidth , 1 , activation_function=None)

# Set Learning Parameter
loss = tf.reduce_mean(tf.reduce_sum(tf.square(ys - prediction),reduction_indices=[1]))
train_step = tf.train.GradientDescentOptimizer(0.1).minimize(loss)

# initial tensorflow variables
init = tf.initialize_all_variables()

# initial graph
fig = plt.figure()
ax = fig.add_subplot(1,1,1)
ax.scatter(x_data, y_data)
plt.ion()
plt.show()
myAxes = plt.gca()
myAxes.set_xlim([min(min(x_data)), max(max(x_data))])
myAxes.set_ylim([min(min(y_data)), max(max(y_data))])

with tf.Session() as sess:
    sess.run(init)

    for i in range(1500):
        sess.run(train_step, feed_dict={xs:x_data, ys:y_data})

        # predict and plot the result
        if i % 50 ==0:
            print(sess.run(loss,feed_dict={xs:x_data, ys:y_data}))
            try:
                ax.lines.remove(lines[0])
            except Exception:
                pass

            prediction_value = sess.run(prediction, feed_dict={xs: x_data})
            # plot the prediction
            lines = ax.plot(x_data, prediction_value, 'r-', lw=5)
            plt.pause(0.1)

    lines = ax.plot(x_data, y_data_ori,'g-', lw=3)
    plt.pause(1)
