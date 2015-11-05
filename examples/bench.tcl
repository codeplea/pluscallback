#This generates C++ benchmark code to compare
#native, boost, and PlusCallback speeds.


set iterations 2100000000

set methods {native BoostFunction PlusCallback}

#Define the various C++ code.
set CreateMethodCallback(native) {int (X::*callback)(int*) = &X::Foo; X* object = &x;}
set CreateMethodCallback(BoostFunction) {boost::function<int (int*)> callback(std::bind1st(std::mem_fun(&X::Foo), &x));}
set CreateMethodCallback(PlusCallback) {cb::Callback1<int, int*> callback(&x, &X::Foo);}

set CopyMethodCallback(native) {int (X::*callback2)(int*) = callback; X* object2 = object;}
set CopyMethodCallback(BoostFunction) {boost::function<int (int*)> callback2(callback);}
set CopyMethodCallback(PlusCallback) {cb::Callback1<int, int*> callback2(callback);}

set InvokeMethodCallback(native) {(object->*callback)(&a);}
set InvokeMethodCallback(BoostFunction) {callback(&a);}
set InvokeMethodCallback(PlusCallback) {callback(&a);}

set InvokeMethodCallback2(native) {(object2->*callback2)(&a);}
set InvokeMethodCallback2(BoostFunction) {callback2(&a);}
set InvokeMethodCallback2(PlusCallback) {callback2(&a);}

set CreateFunctionCallback(native) {int (*callback)(int*) = FreeFoo;}
set CreateFunctionCallback(BoostFunction) {boost::function<int (int*)> callback(FreeFoo);}
set CreateFunctionCallback(PlusCallback) {cb::Callback1<int, int*> callback(FreeFoo);}

set CopyFunctionCallback(native) {int (*callback2)(int*) = callback;}
set CopyFunctionCallback(BoostFunction) {boost::function<int (int*)> callback2(callback);}
set CopyFunctionCallback(PlusCallback) {cb::Callback1<int, int*> callback2(callback);}

set InvokeFunctionCallback(native) {(*callback)(&a);}
set InvokeFunctionCallback(BoostFunction) {callback(&a);}
set InvokeFunctionCallback(PlusCallback) {callback(&a);}

set InvokeFunctionCallback2(native) {(*callback2)(&a);}
set InvokeFunctionCallback2(BoostFunction) {callback2(&a);}
set InvokeFunctionCallback2(PlusCallback) {callback2(&a);}


puts {Creating C++ code for benchmarking.}
#Create the bench marking code.
set file [open {bench.cpp} {w}]

puts $file "

/*
    This file is created by bench.tcl.
    You can compile and run this benchmark
    by hand and it will produce a readable output.

    Note that higher optimization levels may just
    completely optimize out the native C++ tests.
*/

#include <boost/function.hpp>
#include \"../callback.hpp\"
#include <stdio.h>
#include <time.h>

//Loops to test with.
const size_t iters = $iterations;

//Just an example method to call.
struct X {
    int Foo(int* a) {return ++(*a);}
} x;


//And an example free function to call.
int FreeFoo(int* a) {return ++(*a);}


double GetTime() {
    return (double)(clock()) / CLOCKS_PER_SEC;
}
"

#Creates code for a self timing test function.
proc loop {pretime time} {
    return "    $pretime
        const double startTime = GetTime();
        int a = 0;
        for (size_t i = 0; i < iters; ++i)
        {
            $time
        }
        return GetTime() - startTime;"
}



set CM CallbackMethod
set CCM CreateAndCallbackMethod
set CPCM CopyAndCallbackMethod

set CF CallbackFunction
set CCF CreateAndCallbackFunction
set CPCF CopyAndCallbackFunction

foreach method $methods {
    puts $file "\ndouble $CM\_$method\() {
    [loop $CreateMethodCallback($method) $InvokeMethodCallback($method)]\n}\n"

    puts $file "\ndouble $CCM\_$method\() {
    [loop {} "$CreateMethodCallback($method) $InvokeMethodCallback($method)"]\n}\n"

    puts $file "\ndouble $CPCM\_$method\() {
    [loop $CreateMethodCallback($method) "$CopyMethodCallback($method) $InvokeMethodCallback2($method)"]\n}\n"

    puts $file "\ndouble $CF\_$method\() {
    [loop $CreateFunctionCallback($method) $InvokeFunctionCallback($method)]\n}\n"

    puts $file "\ndouble $CCF\_$method\() {
    [loop {} "$CreateFunctionCallback($method) $InvokeFunctionCallback($method)"]\n}\n"

    puts $file "\ndouble $CPCF\_$method\() {
    [loop $CreateFunctionCallback($method) "$CopyFunctionCallback($method) $InvokeFunctionCallback2($method)"]\n}\n"
}


puts $file "
int main() { "

foreach method $methods {
    puts $file "
    printf(\"$method\\n\");"
    foreach test [list $CM $CCM $CPCM $CF $CCF $CPCF] {
        puts $file "    printf(\"\t$test: %0.3f\\n\", $test\_$method\());"
    }
    puts $file "
    printf(\"\\n\");"
}

puts $file "
    return 0;
}"

close $file


#Attempt to compile and run.
set compileCommand {g++ bench.cpp -Wall -O1 -o bench.exe}
puts "Compiling benchmark with: $compileCommand"
set compileResult [exec -- {*}$compileCommand]
if {$compileResult ne {}} {
    puts "Compiling errors:\n$compileResult"
    return
}
exec -- strip bench.exe


puts {Running benchmark... This should take several minutes...}
set runResult [exec -- bench.exe]
puts "Benchmark Result:\n$runResult\n"


set resultLines [split $runResult "\n"]
set index {}
foreach line $resultLines {
    switch -regexp -matchvar match -- $line {
        "^([^ ]+)$" {set index [lindex $match 1]}
        "^\t([^ :]+): ([.0-9]+)$" {
            set test [lindex $match 1]
            set time [lindex $match 2]
            set results($index,$test) $time
        }
    }
}


#Turn results into iterations per second.
set maxTop 0.0
set maxBottom 0.0
foreach index [array names results] {
    set time $results($index)
    set perSec [expr {$iterations / 1000000.0 / $time}]

    set perSecResults($index) $perSec

    if {[string match native,*Function $index]} {
        set maxTop [expr {max($maxTop, $perSec)}]
    } else {
        set maxBottom [expr {max($maxBottom, $perSec)}]
    }
}

set maxBottom [expr {$maxBottom * 1.2}]




#Write plot file for Ploticus.
puts {Creating script for plotting.}
set file [open plot.pl w]

puts $file "
#proc getdata
    fieldnameheader: yes
    data:
    tic method $CM $CCM $CPCM $CF $CCF $CPCF"

foreach method $methods {
    set tic [expr {1+[lsearch -exact $methods $method]}]

    puts $file "    $tic $method $perSecResults($method,$CM) $perSecResults($method,$CCM) $perSecResults($method,$CPCM) $perSecResults($method,$CF) $perSecResults($method,$CCF) $perSecResults($method,$CPCF)"
}


puts $file "
#proc page
    font: Arial

#proc areadef
    rectangle: 1 1 6 3

    xrange: 0.3 3.7
    xaxis.stubs: C++ Native
    Boost.Function
    PlusCallback

    yrange: 0 $maxBottom
    //yaxis.label: 10^6 Iterations Per Second
    //yaxis.labeldetails: adjust=-.2,.5
    yaxis.grid: color=gray(0.9)
    yaxis.stubs: inc 50
    yaxis.stubrange: 0 [expr {$maxBottom*.8}]
"

set i 0
set tests {}

lappend tests $CM {Method Callback} red
lappend tests $CCM {Method Create and Callback} orange
lappend tests $CPCM {Method Copy and Callback} yellow

lappend tests $CF {Function Callback} green
lappend tests $CCF {Function Create and Callback} blue
lappend tests $CPCF {Function Copy and Callback} purple

set testCount [expr {[llength $tests] / 3}]
foreach {test label color} $tests {
    incr i

    puts $file "
    #proc bars
        color: $color
        legendlabel: $label
        locfield: tic
        lenfield: $test
        cluster: $i / $testCount
        outline: no
        truncate: yes
    #saveas $test
    "
}


#Replot the native function callbacks above the break.

set breakBottom [expr {$maxTop - $maxBottom / 6.0}]

puts $file "
#proc legend
    format: down
    location: min+.25 min-.4
    extent: .5
    chunksep: 1


#proc areadef
    title: Callback Benchmark\\n10^6 Iterations Per Second
    titledetails: align=R
    rectangle: 1 3 6 3.5

    xrange: 0.3 3.7

    yrange: $breakBottom $maxTop
    yaxis.grid: color=gray(0.9)
    yaxis.selflocatingstubs: text
    $maxTop [format %.0f $maxTop]
    "


puts $file "
#proc bars
#clone $CF

#proc bars
#clone $CCF

#proc bars
#clone $CPCF

#proc breakaxis
    axis: y
    location: axis
    breakpoint: [expr {$breakBottom-10}]

//#proc breakaxis
//    axis: y
//    location: 1.2
//    breakpoint: $breakBottom
//    linelength: 1
"

close $file

puts {Producing plot with ploticus.}
exec -- pl -svg plot.pl
