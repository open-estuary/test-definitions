import tensorflow as tf

def save_model():
    v1 = tf.Variable(tf.random_normal([1, 2]), name="v1")
    v2 = tf.Variable(tf.random_normal([2, 3]), name="v2")
    init_op = tf.global_variables_initializer()
    saver = tf.train.Saver()
    with tf.Session() as sess:
        sess.run(init_op)
        saver_path = saver.save(sess, "./model.ckpt")
        print("model saved in file: ", saver_path)

save_model()
