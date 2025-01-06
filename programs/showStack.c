#include<stdio.h>
int version = 1;
int sum(int var1, int var2)
{
    int count;
    version = 2;
    count = var1 + var2;
    return (count);
}

void main1()
{
    int a, b, result;
    a = 1;
    b = 2;
    result = sum(a, b);
    printf("result=%d\n", result);
}