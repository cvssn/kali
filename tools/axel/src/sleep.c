#include "config.h"
#define _POSIX_C_SOURCE 200112L

#include <errno.h>
#include <time.h>

#include "sleep.h"


int
axel_sleep(struct timespec delay)
{
    int res;

    while ((res = nanosleep(&delay, &delay)) && errno == EINTR);

    return res;
}