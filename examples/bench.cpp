

/*
    This file is created by bench.tcl.
    You can compile and run this benchmark
    by hand and it will produce a readable output.

    Note that higher optimization levels may just
    completely optimize out the native C++ tests.
*/

#include <boost/function.hpp>
#include "../callback.hpp"
#include <stdio.h>
#include <time.h>

//Loops to test with.
const size_t iters = 2100000000;

//Just an example method to call.
struct X {
    int Foo(int* a) {return ++(*a);}
} x;


//And an example free function to call.
int FreeFoo(int* a) {return ++(*a);}


double GetTime() {
    return (double)(clock()) / CLOCKS_PER_SEC;
}


double CallbackMethod_native() {
        int (X::*callback)(int*) = &X::Foo; X* object = &x;
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            (object->*callback)(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackMethod_native() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            int (X::*callback)(int*) = &X::Foo; X* object = &x; (object->*callback)(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackMethod_native() {
        int (X::*callback)(int*) = &X::Foo; X* object = &x;
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            int (X::*callback2)(int*) = callback; X* object2 = object; (object2->*callback2)(&a);
        }
        return GetTime() - startTime;
}


double CallbackFunction_native() {
        int (*callback)(int*) = FreeFoo;
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            (*callback)(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackFunction_native() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            int (*callback)(int*) = FreeFoo; (*callback)(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackFunction_native() {
        int (*callback)(int*) = FreeFoo;
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            int (*callback2)(int*) = callback; (*callback2)(&a);
        }
        return GetTime() - startTime;
}


double CallbackMethod_BoostFunction() {
        boost::function<int (int*)> callback(std::bind1st(std::mem_fun(&X::Foo), &x));
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            callback(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackMethod_BoostFunction() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            boost::function<int (int*)> callback(std::bind1st(std::mem_fun(&X::Foo), &x)); callback(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackMethod_BoostFunction() {
        boost::function<int (int*)> callback(std::bind1st(std::mem_fun(&X::Foo), &x));
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            boost::function<int (int*)> callback2(callback); callback2(&a);
        }
        return GetTime() - startTime;
}


double CallbackFunction_BoostFunction() {
        boost::function<int (int*)> callback(FreeFoo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            callback(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackFunction_BoostFunction() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            boost::function<int (int*)> callback(FreeFoo); callback(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackFunction_BoostFunction() {
        boost::function<int (int*)> callback(FreeFoo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            boost::function<int (int*)> callback2(callback); callback2(&a);
        }
        return GetTime() - startTime;
}


double CallbackMethod_PlusCallback() {
        cb::Callback1<int, int*> callback(&x, &X::Foo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            callback(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackMethod_PlusCallback() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            cb::Callback1<int, int*> callback(&x, &X::Foo); callback(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackMethod_PlusCallback() {
        cb::Callback1<int, int*> callback(&x, &X::Foo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            cb::Callback1<int, int*> callback2(callback); callback2(&a);
        }
        return GetTime() - startTime;
}


double CallbackFunction_PlusCallback() {
        cb::Callback1<int, int*> callback(FreeFoo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            callback(&a);
        }
        return GetTime() - startTime;
}


double CreateAndCallbackFunction_PlusCallback() {
        
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            cb::Callback1<int, int*> callback(FreeFoo); callback(&a);
        }
        return GetTime() - startTime;
}


double CopyAndCallbackFunction_PlusCallback() {
        cb::Callback1<int, int*> callback(FreeFoo);
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            cb::Callback1<int, int*> callback2(callback); callback2(&a);
        }
        return GetTime() - startTime;
}


int main() { 

    printf("native\n");
    printf("	CallbackMethod: %0.3f\n", CallbackMethod_native());
    printf("	CreateAndCallbackMethod: %0.3f\n", CreateAndCallbackMethod_native());
    printf("	CopyAndCallbackMethod: %0.3f\n", CopyAndCallbackMethod_native());
    printf("	CallbackFunction: %0.3f\n", CallbackFunction_native());
    printf("	CreateAndCallbackFunction: %0.3f\n", CreateAndCallbackFunction_native());
    printf("	CopyAndCallbackFunction: %0.3f\n", CopyAndCallbackFunction_native());

    printf("\n");

    printf("BoostFunction\n");
    printf("	CallbackMethod: %0.3f\n", CallbackMethod_BoostFunction());
    printf("	CreateAndCallbackMethod: %0.3f\n", CreateAndCallbackMethod_BoostFunction());
    printf("	CopyAndCallbackMethod: %0.3f\n", CopyAndCallbackMethod_BoostFunction());
    printf("	CallbackFunction: %0.3f\n", CallbackFunction_BoostFunction());
    printf("	CreateAndCallbackFunction: %0.3f\n", CreateAndCallbackFunction_BoostFunction());
    printf("	CopyAndCallbackFunction: %0.3f\n", CopyAndCallbackFunction_BoostFunction());

    printf("\n");

    printf("PlusCallback\n");
    printf("	CallbackMethod: %0.3f\n", CallbackMethod_PlusCallback());
    printf("	CreateAndCallbackMethod: %0.3f\n", CreateAndCallbackMethod_PlusCallback());
    printf("	CopyAndCallbackMethod: %0.3f\n", CopyAndCallbackMethod_PlusCallback());
    printf("	CallbackFunction: %0.3f\n", CallbackFunction_PlusCallback());
    printf("	CreateAndCallbackFunction: %0.3f\n", CreateAndCallbackFunction_PlusCallback());
    printf("	CopyAndCallbackFunction: %0.3f\n", CopyAndCallbackFunction_PlusCallback());

    printf("\n");

    return 0;
}
