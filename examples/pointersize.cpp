#include <stdio.h>

class one {};
class two : public one {};
class three : virtual public one{};
class four;

int main(int argc, char *argv[])
{
    printf("This just lists method pointer sizes for your compiler.\n\n");
    typedef void(one::*onepointer)();
    typedef void(two::*twopointer)();
    typedef void(three::*threepointer)();
    typedef void(four::*fourpointer)();

    printf("  Single: %d bytes.\n", sizeof(onepointer));
    printf("Multiple: %d bytes.\n", sizeof(twopointer));
    printf(" Virtual: %d bytes.\n", sizeof(threepointer));
    printf(" Unknown: %d bytes.\n", sizeof(fourpointer));

    return 0;
}
