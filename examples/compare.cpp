///\file Compares different callback methods.

//Fun fact, the pre processor turns this next line into about 30,000 lines.
#include <boost/function.hpp>
#include <boost/bind.hpp>

//This file is only about 2,500 lines long. It was generated by a script about 350 lines long.
//You don't have to be a genius to understand how it works.
#include "../callback.hpp"

#include <cassert>
#include <stdio.h>



//Just an example method to call.
struct X {
    int Foo(int a) {printf("Foo %d\n", a); return a;}
};

//And an example free function to call.
int FreeFoo(int a) {printf("FreeFoo %d\n", a); return a;}



//Example of just using raw C++ pointers.
void CppExample()
{
    X x;

    //The method pointer and object pointer are stored separately.
    int (X::*callback)(int) = &X::Foo;
    X* object = &x;

    //Call x.foo(5). Note use of rare ->* operator.
    (object->*callback)(5);

    //At this point, there is no easy way to set the callback to
    //an object of a different class, a static method, or a free function.

    //Also, C++ doesn't support the < operator for these method callbacks.
    //assert(!(callback < callback));
}



//Example of using boost for callbacks.
void BoostExample()
{
    X x;

    //Setup callback for x.foo. Note complexity for simple task.
    boost::function<int (int)> callback = std::bind1st(std::mem_fun(&X::Foo), &x);

    /* Or
    boost::function<int (int)> callback(boost::bind(&X::Foo, &x, _1));
    */

    callback(5); //Call x.foo(5);

    //Change callback to free function.
    callback = FreeFoo;

    //Call FreeFunction(8).
    callback(8);

    //Boost doesn't support the < operator for function callbacks.
    //assert(!(callback < callback));
}



void MyExample()
{
    X x;
    
    //Setup callback for x.foo.
    cb::Callback1<int, int> callback(&x, &X::Foo);

    //Call x.foo(5).
    callback(5);

    //Change callback to free function.
    callback = FreeFoo;

    //Call FreeFunction(8).
    callback(8);

    //The < operator than works fine.
    //One can safely store these callbacks in a set or map container.
    assert(!(callback < callback));
}



int main(int argc, char *argv[])
{
    CppExample(); printf("\n");
    BoostExample(); printf("\n");
    MyExample(); printf("\n");
    return 0;
}
