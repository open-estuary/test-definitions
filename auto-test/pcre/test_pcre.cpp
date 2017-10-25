#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <assert.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "pcre.h"
#include <iostream>
#include <string>
using namespace std;

#define OVECCOUNT 30 /* should be a multiple of 3 */
#define EBUFLEN 128
#define BUFLEN 1024

int main()
{
        pcre *re;
        const char *error;
        int erroffset;
        int ovector[OVECCOUNT];
        int rc, i;

        char buffer[128];
        memset(buffer,'\0',128);

        char src [] = "<head><title>Hello World</title></head>";
        char pattern [] = "<title>(.*)</title>";

        printf("String : %s\n", src);
        printf("Pattern: \"%s\"\n", pattern);

        re = pcre_compile(pattern, 0, &error, &erroffset, NULL);
        if (re == NULL) {
                printf("PCRE compilation failed at offset %d: %s\n", erroffset, error);
                return 1;
        }

        rc = pcre_exec(re, NULL, src, strlen(src), 0, 0, ovector, OVECCOUNT);
        if (rc < 0) {
                if (rc == PCRE_ERROR_NOMATCH) printf("Sorry, no match ...\n");
                else printf("Matching error %d\n", rc);
                free(re);
                return 1;
        }

        printf("\nOK, has matched ...\n\n");

        for (i = 0; i < rc; i++)
        {
                char *substring_start = src + ovector[2*i];
                int substring_length = ovector[2*i+1] - ovector[2*i];
                printf("%2d: %.*s\n", i, substring_length, substring_start);
        }

        free(re);
        return 0;
}


