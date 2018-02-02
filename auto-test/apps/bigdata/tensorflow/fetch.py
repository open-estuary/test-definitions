import tensorflow as tf

value_1 = tf.constant(3.0)
value_2 = tf.constant(2.0)
value_3 = tf.constant(5.0)

# 2.0+5.0
temp_value=tf.add(value_2,value_3)

# 3.0+(2.0+5.0)
result=tf.add(value_1,temp_value)

sess = tf.Session()
print(sess.run([temp_value,result]))
