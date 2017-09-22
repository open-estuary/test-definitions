#include "sqrt.h"
#include "gtest/gtest.h"

TEST(SQRTTest,Zero){
    EXPECT_EQ(0,sqrt(0));
}

TEST(SQRTTest,Positive){
    EXPECT_EQ(100,sqrt(10000));
    EXPECT_EQ(1000,sqrt(1000009));
    EXPECT_EQ(99,sqrt(9810));
}

TEST(SQRTTest,Negative){
    int i=-1;
    EXPECT_EQ(0,sqrt(i));
}
