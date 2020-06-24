#!/usr/bin/env python
# coding: utf-8

# In[1]:


import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D, Flatten, Dropout, MaxPooling2D
from tensorflow.keras.preprocessing.image import ImageDataGenerator

import os
import numpy as np
import matplotlib.pyplot as plt


# ## load data

# In[2]:


PATH = 'D:/_hiroshi/_dataset/5-celebrity-faces-dataset/'
train_dir = os.path.join(PATH, 'train')
val_dir = os.path.join(PATH, 'val')

train_ben_dir = os.path.join(train_dir, 'ben_afflek')  # directory with our training cat pictures
train_elton_dir = os.path.join(train_dir, 'elton_john')  # directory with our training cat pictures
train_jerry_dir = os.path.join(train_dir, 'jerry_seinfeld')  # directory with our training cat pictures
train_madonna_dir = os.path.join(train_dir, 'madonna')  # directory with our training cat pictures
train_mindy_dir = os.path.join(train_dir, 'mindy_kaling')  # directory with our training cat pictures

val_ben_dir = os.path.join(val_dir, 'ben_afflek')  # directory with our validation cat pictures
val_elton_dir = os.path.join(val_dir, 'elton_john')  # directory with our validation cat pictures
val_jerry_dir = os.path.join(val_dir, 'jerry_seinfeld')  # directory with our validation cat pictures
val_madonna_dir = os.path.join(val_dir, 'madonna')  # directory with our validation cat pictures
val_mindy_dir = os.path.join(val_dir, 'mindy_kaling')  # directory with our validation cat pictures


# In[3]:


num_ben_tr = len(os.listdir(train_ben_dir))
num_elton_tr = len(os.listdir(train_elton_dir))
num_jerry_tr = len(os.listdir(train_jerry_dir))
num_madonna_tr = len(os.listdir(train_madonna_dir))
num_mindy_tr = len(os.listdir(train_mindy_dir))

num_ben_val = len(os.listdir(val_ben_dir))
num_elton_val = len(os.listdir(val_elton_dir))
num_jerry_val = len(os.listdir(val_jerry_dir))
num_madonna_val = len(os.listdir(val_madonna_dir))
num_mindy_val = len(os.listdir(val_mindy_dir))

total_train = num_ben_tr + num_elton_tr + num_jerry_tr + num_madonna_tr + num_mindy_tr
total_val = num_ben_val + num_elton_val + num_jerry_val + num_madonna_val + num_mindy_val


# In[4]:


print(total_train)
print(total_val)


# In[5]:


#Some hyper-parameters
IMG_HEIGHT = 150
IMG_WIDTH = 150

embedding_dims = 16 #32.. don't set too high
batch_size = 25 #128.. must greater than batch size
epochs = 50


# ## Data preparation

# ### Create validation data generator

# In[6]:


image_gen_train = ImageDataGenerator(
                    rescale=1./255,
                    rotation_range=15,
                    width_shift_range=.15,
                    height_shift_range=.15,
                    horizontal_flip=True,
#                    zoom_range=0.5
                    )

train_data_gen = image_gen_train.flow_from_directory(batch_size=batch_size,
                                                     directory=train_dir,
                                                     shuffle=True,
                                                     target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                     class_mode='binary',
                                                     color_mode='grayscale')


# ##### Visualize how a single image would look five different times when passing these augmentations randomly to the dataset.

# In[7]:


# This function will plot images in the form of a grid with 1 row and 5 columns where images are placed in each column.
def plotImages(images_arr):
    fig, axes = plt.subplots(1, 5, figsize=(20,20))
    axes = axes.flatten()
    for img, ax in zip( images_arr, axes):
        #ax.imshow(img)
        ax.imshow(img[:,:,0], cmap='gray') #show gray level pic
        ax.axis('off')
    plt.tight_layout()
    plt.show()


# In[8]:


augmented_images = [train_data_gen[0][0][0] for i in range(5)]
plotImages(augmented_images)


# ### Create validation data generator

# In[9]:


image_gen_val = ImageDataGenerator(rescale=1./255)

val_data_gen = image_gen_val.flow_from_directory(batch_size=batch_size,
                                                 directory=val_dir,
                                                 target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                 class_mode='binary',
                                                 color_mode='grayscale')


# In[10]:


imgs, labels = next(train_data_gen)
ncols = 5
nrows = 2

plt.suptitle("faces in training dataset")
plt.figure(figsize = (12,8))
for i,(img,label) in enumerate(zip(imgs,labels)):
    if i > 9 :
        break
    plt.subplot(nrows, ncols, i+1)
#    plt.imshow(img.reshape(IMG_HEIGHT,IMG_WIDTH,3), cmap = 'binary')
    plt.imshow(img.reshape(IMG_HEIGHT,IMG_WIDTH), cmap = 'gray')
    plt.title("label : " + str(label.astype(np.int64)))
    plt.axis("off")
plt.show()


# In[11]:


def augmentation_generator(input_gen, batch_size, embedding_dims):
    dummy_y = np.zeros((batch_size, embedding_dims + 1))
    for img, label in input_gen: 
#        a = cv2.cvtColor(img[0], cv2.COLOR_BGR2GRAY)
        yield [img ,label.astype(np.int64)], dummy_y


# In[12]:


train_aug = augmentation_generator(train_data_gen, batch_size, embedding_dims)
valid_aug = augmentation_generator(val_data_gen, batch_size, embedding_dims)


# In[13]:


next(valid_aug)


# ### Build the model

# In[14]:


next(train_aug)[0][0].shape


# In[15]:


def _cn_bn_relu(filters = 64, kernel_size = (3,3), strides = (1,1), padding = "same"):
    
    def f(input_x):
        
        x = input_x
        x = tf.keras.layers.Conv2D(filters = filters, kernel_size = kernel_size, strides = strides, padding = padding,
                          kernel_initializer = "he_normal")(x)
        x = tf.keras.layers.BatchNormalization()(x)
        x = tf.keras.layers.Activation("relu")(x)
        
        return x
    return f

def _dn_bn_relu(units = 256):
    def f(input_x):
        
        x = input_x
        x = tf.keras.layers.Dense(units = units)(x)
        x = tf.keras.layers.BatchNormalization()(x)
        x = tf.keras.layers.Activation("relu")(x)
        
        return x
    return f
    
def build_model(image_input, embedding_dims):
    
    x = _cn_bn_relu(filters = 64, kernel_size = (3,3))(image_input)
    x = tf.keras.layers.MaxPooling2D(pool_size = (2,2))(x)
    x = _cn_bn_relu(filters = 64, kernel_size = (3,3))(x)
    x = tf.keras.layers.MaxPooling2D(pool_size = (2,2))(x)
    x = tf.keras.layers.Dropout(0.35)(x)
    x = tf.keras.layers.Flatten()(x)
    x = _dn_bn_relu(units = 256)(x)
    x = _dn_bn_relu(units = 128)(x)
    x = tf.keras.layers.Dropout(0.25)(x)
    x = _dn_bn_relu(units = 64)(x)
    x = tf.keras.layers.Dense(units = embedding_dims, name = "embedding_layer")(x)
    # 2020.6.23 hiroshi: add l-2 normalization for triplet loss input argument
    x = tf.keras.layers.Lambda(lambda x: tf.math.l2_normalize(x, axis=1))(x)
    
    return x

#image_input = tf.keras.layers.Input(shape = next(train_aug)[0][0].shape, name = "image_input")
image_input = tf.keras.layers.Input(shape = next(train_aug)[0][0][0].shape, name = "image_input")
label_input = tf.keras.layers.Input(shape = (1,), name = "label_input")

base_model = build_model(image_input, embedding_dims)
output = tf.keras.layers.concatenate([label_input, base_model])

model = tf.keras.models.Model(inputs = [image_input, label_input], outputs = [output])
model.summary()


# ### Training embedding model

# In[16]:


def triplet_loss(y_true, y_pred, margin = 1.2):
    
    del y_true
    
    labels = y_pred[:,:1]
    labels = tf.dtypes.cast(labels, tf.int32)
    labels = tf.reshape(labels, (tf.shape(labels)[0],))
    
    embeddings = y_pred[:,1:]
    #return tfa.losses.triplet_semihard_loss(labels = labels, embeddings = embeddings, margin = margin)
    return tfa.losses.triplet_semihard_loss(y_true=labels, y_pred=embeddings, margin=margin)


# In[17]:


import tensorflow_addons as tfa

# Compile the model
model.compile(
    optimizer=tf.keras.optimizers.Adam(0.001),
    loss=triplet_loss)

reduce_lr = tf.keras.callbacks.ReduceLROnPlateau(monitor = 'val_loss', patience = 3, factor = 0.5, mode = 'min', verbose = 1, min_lr = 1e-6)
es = tf.keras.callbacks.EarlyStopping(monitor = 'val_loss', patience = 15, mode = 'min')
steps_per_epoch = total_train // batch_size
validation_steps = total_val // batch_size

epochs = 20

history = model.fit_generator(train_aug, steps_per_epoch = steps_per_epoch,
                              epochs = epochs, verbose = 1,
                              validation_data = valid_aug, validation_steps = validation_steps,
                              callbacks = [reduce_lr,es],
                              shuffle = True)


# In[18]:


plt.figure(figsize = (12,8))
plt.plot(history.history['loss'], '-', label = 'train_loss', color = 'g')
plt.plot(history.history['val_loss'], '-', label = 'valid_loss', color = 'r')
plt.xlabel('epochs')
plt.ylabel('loss')
plt.title('triple loss of embedding model')
plt.legend()
plt.show()


# In[19]:


#Transfer the weights from original model to embedding model

image_input = tf.keras.layers.Input(shape = next(train_aug)[0][0][0].shape)
embedding_output = build_model(image_input, embedding_dims = embedding_dims)
embedding_model = tf.keras.models.Model(inputs = [image_input], outputs = [embedding_output])

for idx in range(1,18):
    target_layer = embedding_model.layers[idx]
    source_layer = model.layers[idx]
    target_layer.set_weights(source_layer.get_weights())
    
embedding_model.layers[-1].set_weights(model.layers[-2].get_weights())

embedding_model.summary()


# ### load all train and valid data

# In[20]:


image_gen = ImageDataGenerator(rescale=1./255)
train_all_gen = image_gen.flow_from_directory(batch_size=total_train,
                                                     directory=train_dir,
                                                     shuffle=False,
                                                     target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                     class_mode='binary',
                                                     color_mode='grayscale')
val_all_gen = image_gen.flow_from_directory(batch_size=total_val,
                                                     directory=val_dir,
                                                     shuffle=False,
                                                     target_size=(IMG_HEIGHT, IMG_WIDTH),
                                                     class_mode='binary',
                                                     color_mode='grayscale')
all_train_img, all_train_label = next(train_all_gen)
all_val_img, all_val_label = next(val_all_gen)

imgType = 'val'
idx = 2
imgNameStr = 'all_' + imgType + "_img[idx]"
plt.imshow(eval(imgNameStr).reshape(IMG_HEIGHT,IMG_WIDTH), cmap = 'gray')
plt.title("label : " + str(all_train_label[idx].astype(np.int64)))
plt.axis("off")
plt.show()


# In[21]:


from sklearn.manifold import TSNE



import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.patheffects as PathEffects

def scatter(x, labels, subtitle=None):
    # We choose a color palette with seaborn.
    palette = np.array(sns.color_palette("hls", 10))

    # We create a scatter plot.
    f = plt.figure(figsize=(8, 8))
    ax = plt.subplot(aspect='equal')
    sc = ax.scatter(x[:,0], x[:,1], lw=0, s=40,
                    c=palette[labels.astype(np.int)])
    plt.xlim(-25, 25)
    plt.ylim(-25, 25)
    ax.axis('off')
    ax.axis('tight')

    # We add the labels for each digit.
    txts = []
    for i in range(10):
        # Position of each label.
        xtext, ytext = np.median(x[labels == i, :], axis=0)
        txt = ax.text(xtext, ytext, str(i), fontsize=24)
        txt.set_path_effects([
            PathEffects.Stroke(linewidth=5, foreground="w"),
            PathEffects.Normal()])
        txts.append(txt)
        
    if subtitle != None:
        plt.suptitle(subtitle)
        
    plt.show()

train_x_embeddings = embedding_model.predict(all_train_img)
valid_x_embeddings = embedding_model.predict(all_val_img)

tsne = TSNE()
train_tsne_embeds = tsne.fit_transform(train_x_embeddings)
scatter(train_tsne_embeds, all_train_label, "Samples from Training Data")

eval_tsne_embeds = tsne.fit_transform(valid_x_embeddings)
scatter(eval_tsne_embeds, all_val_label, "Samples from Validation Data")


# In[ ]:




