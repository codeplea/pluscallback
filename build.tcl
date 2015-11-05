# Copyright (c) 2009-2010 Lewis Van Winkle
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#   1. The origin of this software must not be misrepresented; you must not
#   claim that you wrote the original software. If you use this software
#   in a product, an acknowledgment in the product documentation would be
#   appreciated but is not required.
#
#   2. Altered source versions must be plainly marked as such, and must not be
#   misrepresented as being the original software.
#
#   3. This notice may not be removed or altered from any source
#   distribution.

set version {1.7}

puts {This Tcl script will attempt to build the callback library header.}

set maxParams 9

puts "The library is being built supporting a maximum of $maxParams parameters."

set file [open {callback.hpp} {w}]

puts $file "/*
 * PlusCallback $version
 * Copyright (c) 2009-2010 Lewis Van Winkle
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source
 * distribution.
 */


#ifndef __CALLBACK_HPP__
#define __CALLBACK_HPP__

#include <string.h>
#include <stdexcept>


//PlusCallback $version
//This library was built on [clock format [clock seconds] -format {%d.%m.%Y}] to support
//functions with a maximum of $maxParams parameters.
#define CALLBACK_VERSION $version


namespace cb
{

        static const std::string unset_call_error(\"Attempting to invoke null callback.\");

"


for {set i 0} {$i <= $maxParams} {incr i} {

    set paramTypenames ""
    set paramTypes ""
    set params ""
    set paramsCall ""

    for {set j 0} {$j < $i} {incr j} {
        set paramTypes "$paramTypes, T$j"
        set paramTypenames "$paramTypenames, typename T$j"
        
        if {$j > 0} {
            set params "$params, T$j t$j"
            set paramsCall "$paramsCall, t$j"
        } else {
            set params "T$j t$j"
            set paramsCall "t$j"
        }
    }

    puts $file "
        ///Stores a callback for a function taking $i parameters.
        ///\\tparam R Callback function return type.
        template <typename R$paramTypenames>
            class Callback$i
            {
                public:
                    ///Constructs the callback to a specific object and member function.
                    ///\\param object Pointer to the object to call upon. Care should be taken that this object remains valid as long as the callback may be invoked.
                    ///\\param function Member function address to call.
                    template <typename C>
                        Callback$i\(C* object, R (C::*function)($params))
                            :mCallback(new(&mMem) ChildMethod<C>(object, function))
                        {
                        }

                    ///Constructs the callback to a free function or static member function.
                    ///\\param function Free function address to call.
                    Callback$i\(R (*function)($params))
                        :mCallback(new(&mMem) ChildFree(function))
                    {
                    }

                    ///Constructs a callback that can later be set.
                    Callback$i\()
                        :mCallback(0)
                    {
                    }

                    Callback$i\(const Callback$i& c)
                        :mCallback(c.mCallback)
                    {
                        if (mCallback)
                        {
                            memcpy(mMem, c.mMem, sizeof(mMem));
                            mCallback = reinterpret_cast<Base*>(&mMem);
                        }
                    }

                    Callback$i& operator=(const Callback$i& rhs)
                    {
                        mCallback = rhs.mCallback;
                        if (mCallback)
                        {
                            memcpy(mMem, rhs.mMem, sizeof(mMem));
                            mCallback = reinterpret_cast<Base*>(&mMem);
                        }

                        return *this;
                    }

                    ~Callback$i\()
                    {
                    }

                    ///Sets the callback to a specific object and member function.
                    ///\\param object Pointer to the object to call upon. Care should be taken that this object remains valid as long as the callback may be invoked.
                    ///\\param function Member function address to call.
                    template <typename C>
                        void Reset(C* object, R (C::*function)($params))
                        {
                            mCallback = new(&mMem) ChildMethod<C>(object, function);
                        }

                    ///Sets the callback to a free function or static member function.
                    ///\\param function Free function address to call.
                    void Reset(R (*function)($params))
                    {
                        mCallback = new(&mMem) ChildFree(function);
                    }

                    ///Resests to callback to nothing.
                    void Reset()
                    {
                        mCallback = 0;
                    }

                    ///Note that comparison operators may not work with virtual function callbacks.
                    bool operator==(const Callback$i& rhs) const
                    {
                        if (mCallback && rhs.mCallback)
                            return (*mCallback) == (*(rhs.mCallback));
                        else
                            return mCallback == rhs.mCallback;
                    }

                    ///Note that comparison operators may not work with virtual function callbacks.
                    bool operator!=(const Callback$i& rhs) const
                    {
                        return !(*this == rhs);
                    }

                    ///Note that comparison operators may not work with virtual function callbacks.
                    bool operator<(const Callback$i rhs) const
                    {
                        if (mCallback && rhs.mCallback)
                            return (*mCallback) < (*(rhs.mCallback));
                        else
                            return mCallback < rhs.mCallback;
                    }

                    ///Returns true if the callback has been set, or false if the callback is not set and is invalid.
                    bool IsSet() const
                    {
                        return mCallback;
                    }

                    ///Invokes the callback.
                    R operator()($params) const
                    {
                        if (mCallback)
                            return (*mCallback)($paramsCall);
                        else
                            throw std::runtime_error(unset_call_error);
                    }

                    ///Invokes the callback. This function can sometimes be more convenient than the operator(), which does the same thing.
                    R Call($params) const
                    {
                        if (mCallback)
                            return (*mCallback)($paramsCall);
                        else
                            throw std::runtime_error(unset_call_error);
                    }

                private:
                        class Base
                        {
                            public:
                                Base(){}
                                virtual R operator()($params) = 0;
                                virtual bool operator==(const Base& rhs) const = 0;
                                virtual bool operator<(const Base& rhs) const = 0;
                                virtual void* Comp() const = 0; //Returns a pointer used in comparisons.
                        };

                        class ChildFree : public Base
                        {
                            public:
                                ChildFree(R (*function)($params))
                                :mFunc(function)
                                    {}

                                virtual R operator()($params)
                                {
                                    return mFunc($paramsCall);
                                }

                                virtual bool operator==(const Base& rhs) const
                                {
                                    const ChildFree* const r = dynamic_cast<const ChildFree*>(&rhs);
                                    if (r)
                                        return (mFunc == r->mFunc);
                                    else
                                        return false;
                                }

                                virtual bool operator<(const Base& rhs) const
                                {
                                    const ChildFree* const r = dynamic_cast<const ChildFree*>(&rhs);
                                    if (r)
                                        return mFunc < r->mFunc;
                                    else
                                        return true; //Free functions will always be less than methods (because comp returns 0).
                                }

                                virtual void* Comp() const
                                {
                                    return 0;
                                }

                            private:
                                R (*const mFunc)($params);
                        };

                    template <typename C>
                        class ChildMethod : public Base
                        {
                            public:
                                ChildMethod(C* object, R (C::*function)($params))
                                    :mObj(object), mFunc(function)
                                    {}

                                virtual R operator()($params)
                                {
                                    return (mObj->*mFunc)($paramsCall);
                                }

                                virtual bool operator==(const Base& rhs) const
                                {
                                    const ChildMethod<C>* const r = dynamic_cast<const ChildMethod<C>*>(&rhs);
                                    if (r)
                                        return (mObj == r->mObj) && (mFunc == r->mFunc);
                                    else
                                        return false;
                                }

                                virtual bool operator<(const Base& rhs) const
                                {
                                    const ChildMethod<C>* const r = dynamic_cast<const ChildMethod<C>*>(&rhs);
                                    if (r)
                                    {
                                        if (mObj != r->mObj)
                                            return mObj < r->mObj;
                                        else
                                            return 0 > memcmp((void*)&mFunc, (void*)&(r->mFunc), sizeof(mFunc));
                                    }
                                    else
                                        return mObj < rhs.Comp();
                                }

                                virtual void* Comp() const
                                {
                                    return mObj;
                                }

                            private:
                                C* const mObj;
                                R (C::* const mFunc)($params);
                        };

                    ///This class is only to find the worst case method pointer size.
                    class unknown;

                    char mMem\[sizeof(ChildMethod<unknown>)]; //Reserve memory for creating useful objects later.
                    Base* mCallback;
            };


        ///Helper function to construct a callback without bothering to specify template parameters.
        template <typename C, typename R$paramTypenames>
            Callback$i<R$paramTypes> Make$i\(C* object, R (C::*function)($params))
            {
                return Callback$i<R$paramTypes>(object, function);
            }

        ///Helper function to construct a callback without bothering to specify template parameters.
        template <typename R$paramTypenames>
            Callback$i<R$paramTypes> Make$i\(R (*function)($params))
            {
                return Callback$i<R$paramTypes>(function);
            }
"

}


puts $file "}
#endif /*__CALLBACK_HPP__*/
"
close $file
