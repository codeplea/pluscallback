#include "../callback.hpp"

#include <algorithm>
#include <set>
#include <cassert>
#include <cstdio>
#include <string>

///\file This is basically a bunch of random tests for the callback library.
///It's a bit of a mess and probably not something one should use as learning material.
///When running this, a tool should be used to check for memory leaks.
///This test always leaks 12345 bytes of memory on purpose. Any other amount is an error.


class A {}; class B {}; class C {};

class Test : public A, public B, public virtual C
{
    public:
        int Return1() {return 1;}
        int Return2() {return 2;}
        void Turn1(int& a) {a = 1;}
};


class X
{
    public:
        int Return1() {return 1;}
};


int Free1() {return 1;}
int Free3() {return 3;}
int FreeX2(int a) {return a*2;}


int main(int argc, char *argv[])
{
    //Check that asserts are actually on.
    {
        int checkAsserts = 0;
        assert(checkAsserts = 1);
        if (!checkAsserts)
        {
            printf("Error, the code was not compiled with asserts.\n");
            exit(1);
        }
    }


    //Leak some memory on purpose to check that
    //a memory leak detection tool is working.
    char* leak = new char[12345];
    leak = 0;

    std::printf("Begin.\n");

    Test test;
    Test test2;

    {
        cb::Callback0<int> a;
        assert(!a.IsSet());

        //Test callback.
        a.Reset(&test, &Test::Return1);
        assert(a.IsSet());
        assert(a() == 1);

        //Test reseting callback.
        a.Reset(&test, &Test::Return2);
        assert(a() == 2);

        //Test equality with generated callbacks.
        assert(a == cb::Make0(&test, &Test::Return2)); //same func, same obj
        assert(a != cb::Make0(&test2, &Test::Return2)); //same func, diff obj
        assert(a != cb::Make0(&test, &Test::Return1)); //diff func, same obj
        assert(a != cb::Make0(Free3)); //Free function.
        assert(cb::Make0(Free3) == cb::Make0(Free3));

        //Test equality.
        cb::Callback0<int> b(&test, &Test::Return2);
        assert(b.IsSet());
        assert(a == b);

        b.Reset(Free3);
        assert(a != b);

        b.Reset(&test, &Test::Return1);
        assert(a != b);

        //Test equality with unset callbacks.
        b.Reset();
        assert(!b.IsSet());
        assert(a != b);

        a.Reset();
        assert(!a.IsSet());
        assert(a == b);
    }

    {
        //Test copy constructor.
        cb::Callback0<int> a(&test, &Test::Return1);
        cb::Callback0<int> b(a);
        assert(a == b);
        assert(a() == b());
        assert(b() == 1);

        cb::Callback0<int> c(Free1);
        cb::Callback0<int> d(c);
        assert(c == d);
        assert(c() == d());
        assert(d() == 1);
    }

    {
        //Test less than and equality some more.
        Test test;
        Test test2;
        X s;

        cb::Callback0<int> f1(Free1);
        cb::Callback0<int> f3(Free3);
        cb::Callback0<int> a(&test, &Test::Return1);
        cb::Callback0<int> aa(&test, &Test::Return1);
        cb::Callback0<int> b(&test2, &Test::Return1);
        cb::Callback0<int> c(&test, &Test::Return2);
        cb::Callback0<int> d(&s, &X::Return1);

        assert(d != a);
        assert(d() == a());

        assert((f1 < f3) ^ (f3 < f1));

        assert((f1 < a) && !(a < f1));
        assert((f1 < aa) && !(aa < f1));
        assert((f1 < b) && !(b < f1));
        assert((f1 < c) && !(c < f1));
        assert((f1 < d) && !(d < f1));

        assert(!(aa < a) && !(a < aa));

        assert((a < b) ^ (b < a));
        assert((a < c) ^ (c < a));
        assert((c < b) ^ (b < c));

        assert((a < d) ^ (d < a));

        f1 = f3 = a = aa = b = c = d;
        assert(f1 == f3);
        assert(a == aa);
        assert(b == c);
        assert(f1 == a && f1 == b && b == d);
    }

    {
        //Test free function callback.
        cb::Callback0<int> a(Free3);
        assert(a() == 3);
        assert(a == cb::Make0(Free3));
        assert(a != cb::Make0(Free1));

        cb::Callback1<int, int> b(FreeX2);
        assert(b(5) == 10);
    }

    {
        //Test reference parameters.
        cb::Callback1<void, int&> a(&test, &Test::Turn1);
        int i = 1000;
        a(i);
        assert(i == 1);
    }

    {
        //Test errors by calling unset callback.
        try
        {
            cb::Callback0<int> a;
            a.Call();
            assert(false);
        }
        catch (std::runtime_error err)
        {
            assert(err.what() == cb::unset_call_error);
        }
    }

    {
        //Test self assignment.
        cb::Callback0<int> a(&test, &Test::Return1);
        a = a;
        assert(a() == 1);

        cb::Callback0<int> b(Free3);
        b = b;
        assert(b() == 3);
    }

    {
        //Test container storage.
        std::set<cb::Callback0<int> > set;
        std::multiset<cb::Callback0<int> > mset;

        for (int i = 0; i < 10; ++i)
            if (i % 2)
                set.insert(cb::Make0(&test, &Test::Return1));
            else
                set.insert(cb::Make0(Free1));

        assert(set.size() == 2);

        for (std::set<cb::Callback0<int> >::const_iterator it = set.begin(); it != set.end(); ++it)
            assert(it->Call() == 1);



        for (int i = 0; i < 100; ++i)
            if (i % 2)
                mset.insert(cb::Make0(&test, &Test::Return1));
            else
                mset.insert(cb::Make0(Free1));
        assert(mset.size() == 100);
    }

    std::printf("End.\n");
}

