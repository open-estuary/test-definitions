import tensorflow as tf

def load_model():
    v1 = tf.Variable(tf.random_normal([1, 2]), name="v1")
    v2 = tf.Variable(tf.random_normal([2, 3]), name="v2")
    saver = tf.train.Saver()
    with tf.Session() as sess:
        saver.restore(sess,"./model.ckpt")
        print("mode restored")

load_model()
