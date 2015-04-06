#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include "cloudfs.h"


static void usageExit(FILE *out)
{
    fprintf(out,
"   Command Line:\n"
"\n"
"   -t/--threshold       :  \n"
"   -s/--ssd-path        :  The mount directory of SSD disk\n"
"   -d/--hdd-path        :  The mount directory of HDD disk\n"
"   -f/--fuse-path       :  The directory where cloudfs mounts\n"
"   -h/--hostname        :  The hostname of S3 server, e.g. (localhost,"
                            "localhost:80)\n"
"   -a/--ssd-size        :  The size of SSD disk\n"
"   -b/--hdd-size        :  The size of HDD disk\n"
"\n"
" Commands (with <required parameters> and [optional parameters]) :\n"
"\n");
    exit(-1);
}

static struct option longOptionsG[] =
{
    { "threshold",        required_argument,        0,  't' },
    { "ssd-path",         required_argument,        0,  's' },
    { "hdd-path",         required_argument,        0,  'd' },
    { "fuse-path",        required_argument,        0,  'f' },
    { "hostname",         required_argument,        0,  'h' },
    { "ssd-size",         required_argument,        0,  'a' },
    { "hdd-size",         required_argument,        0,  'b' },
    { 0,                  0,                  0,   0  }
};

static void parse_arguments(int argc, char* argv[], 
                            struct cloudfs_state *state) {
    // Default Values
    strcpy(state->ssd_path, "/mnt/ssd/");
    strcpy(state->hdd_path, "/mnt/hdd/");
    strcpy(state->fuse_path, "/mnt/fuse/");
    strcpy(state->hostname, "localhost:8888");
    state->hdd_size = 1024*1024*1024;
    state->ssd_size = 1024*1024*1024;
    state->threshold = 64*1024;

    // Parse args
    while (1) {
        int idx = 0;
        int c = getopt_long(argc, argv, "t:s:d:f:h:a:b:", longOptionsG, &idx);

        if (c == -1) {
            // End of options
            break;
        }

        switch (c) {
        case 's':
            strcpy(state->ssd_path, optarg);
            break;
        case 'd':
            strcpy(state->hdd_path, optarg);
            break;
        case 'f':
            strcpy(state->fuse_path, optarg);
            break;
        case 'h':
            strcpy(state->hostname, optarg);
            break;
        case 't': 
            state->threshold = atoi(optarg)*1024;
            break;
        case 'a': 
            state->ssd_size = atoi(optarg)*1024;
            break; 
        case 'b':
            state->hdd_size = atoi(optarg)*1024;
            break;
        default:
            fprintf(stderr, "\nERROR: Unknown option: -%c\n", c);
            // Usage exit
            usageExit(stderr);
        }
    }
}

// main ------------------------------------------------------------------------

int main(int argc, char **argv)
{

    struct cloudfs_state state;
    parse_arguments(argc, argv, &state);

    cloudfs_start(&state, argv[0]);

    return 0;
}
