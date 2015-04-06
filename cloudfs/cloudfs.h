#ifndef __CLOUDFS_H_
#define __CLOUDFS_H_

#define MAX_PATH_LEN 4096
#define MAX_HOSTNAME_LEN 1024

struct cloudfs_state {
  char hostname[MAX_HOSTNAME_LEN];
  char ssd_path[MAX_PATH_LEN];
  char hdd_path[MAX_PATH_LEN];
  char fuse_path[MAX_PATH_LEN];
  int ssd_size;
  int hdd_size;
  int threshold;
};

int cloudfs_start(struct cloudfs_state* state,
                  const char* fuse_runtime_name);  

#endif
