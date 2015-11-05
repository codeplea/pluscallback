#C++ Callback Library: PlusCallback

*Find the latest version and more documentation at:*
http://codeplea.com/pluscallback

##Intro

PlusCallback is a C++ library, contained in a single header file, that
implements easy to use function and method callbacks. It is completely
contained in one header file, so it's trivial to add to your projects. It also
uses the simplest syntax of any callback method I've ever seen (for C++), and
it's quite flexible.

##Code Sample

    //Setup callback for TestObject.Foo().
    cb::Callback1<int, int> callback(&TestObject, &TestClass::Foo);

    //Call TestObject.Foo(5).
    callback(5);

    //Change callback to a free function.
    callback = SomeRandomFunction;

    //Call SomeRandomFunction(8).
    callback(8);


##Features

- Contained in one header file, trivial to install
- Portable ANSI C++ code
- Completely free for any use (zlib license)
- Very simple API
- Type-safe, no macros or casts
- Container storage safe (e.g. std::map, list, vector, etc)


##Installation Instructions
This entire library is contained in one header file.
Simply include *callback.hpp* in your project.

##Examples
Some examples are included in the examples directory:
- example.cpp - PlusCallback example walking through most features.
- compare.cpp - Example comparing different callback methods.
- smoke.cpp   - Several random tests for PlusCallback.

##Building Instructions
This library comes pre-built. If you would like to rebuild this
library, you need to run build.tcl with the TCL interpreter. You
can obtain TCL from http:://www.tcl.tk/
When rebuilding, you can change the maximum number of parameters
supported by callbacks.
