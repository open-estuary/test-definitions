import tensorflow as  tf

input_1 = tf.placeholder(tf.float32)
input_2 = tf.placeholder(tf.float32)
output = tf.add(input_1, input_2)

with tf.Session() as sess:
        print(sess.run([output],feed_dict={input_1:[7.],input_2:[2.]}))
