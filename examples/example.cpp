#include <stdio.h>
#include "../callback.hpp"

#include <cassert>
#include <cstdlib>
#include <set>

struct Dog
{
    void Bark(int volume){};
};

struct Cat
{
    void Meow(int volume){};
};

Dog spot, rover; //We have two dogs
Cat felix; //and one cat.

//Define a normal function.
void Func(int a){};


int main(int argc, char *argv[])
{
    //Define a callback to a function returning void and taking
    //one int parameter.
    cb::Callback1<void, int> speak;

    //Point this callback at spot's Bark method.
    speak.Reset(&spot, &Dog::Bark);
    speak(50); //Spot barks loudly.

    speak.Reset(&rover, &Dog::Bark);
    speak(60); //Rovers lets out a mighty bark.

    speak.Reset(&felix, &Cat::Meow);
    speak(30); //Felix meows.

    //Callbacks can be set to free functions.
    speak = Func;

    //Copy and assignment operators are well defined.
    cb::Callback1<void, int> copy = speak;
    assert(copy == speak);

    //Callbacks can be set to null.
    copy.Reset();
    assert(!copy.IsSet());

    //Callbacks are container safe with a well defined sort order.
    std::set<cb::Callback1<void, int> > container;
    container.insert(speak);
    container.insert(copy);

    //Use the helper function MakeX to quickly create callback objects.
    container.insert(cb::Make1(&spot, &Dog::Bark));
    container.insert(cb::Make1(&rover, &Dog::Bark));
    container.insert(cb::Make1(&felix, &Cat::Meow));


    return 0;
}
