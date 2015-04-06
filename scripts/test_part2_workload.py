#!/usr/bin/python
import os
import sys
import random
import string
import subprocess

def generate_random_file(filename, size, seed=0):
    if seed != 0:
        random.seed(seed)
    else:
        random.seed()
    f = open(filename, 'wb')
    chunk_size = 1024
    chunk = ''.join(random.choice(string.ascii_uppercase+string.digits) for x in range(chunk_size))
    for i in range(size / 1024):
        f.write(chunk)
    f.close()

def test_read_file(filename):
    f = open(filename, 'r')
    lines = f.readlines()
    f.close()

def stress_test(fuse_dir):
    n = 200
    m = 1000
    min_file_size = 2 * 1024 * 1024
    max_file_size = 4 * 1024 * 1024
    for i in range(n):
        size = random.randint(min_file_size, max_file_size)
        generate_random_file('%s/%d.in'%(fuse_dir, i), size)
    for j in range(m):
        i = random.randint(0, n-1)
        fn = '%s/%d.in'%(fuse_dir, i)
        if random.randint(0, 5) == 0:
            size = random.randint(min_file_size, max_file_size)
            generate_random_file(fn, size)
        else:
            test_read_file(fn)
    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        os.remove(fn)

def deduplicate_test(fuse_dir):
    n = 200
    min_file_size = 2 * 1024 * 1024
    max_file_size = 4 * 1024 * 1024
    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        if i % 4 == 0:
            random.seed()
            size = random.randint(min_file_size, max_file_size)
            generate_random_file(fn, size)
        else:
            size = 1024*1024
            generate_random_file(fn, size, 1987)

    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        os.remove(fn)

def set_xattr(filename, attribute, value):
    print ['attr', '-s', attribute, '-V', value, filename]
    subprocess.call(['attr', '-s', attribute, '-V', value, filename])

def file_sharing_test(fuse_dir):
    n = 200
    types = ['music', 'video', 'photo', 'document']
    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        os.mknod(fn)
        set_xattr(fn, 'user.location', 'cloud')
        set_xattr(fn, 'user.type', 'music')
        generate_random_file(fn, 1024*1024)

    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        test_read_file(fn)

    for i in range(n):
        fn = '%s/%d.in'%(fuse_dir, i)
        os.remove(fn)

def main():
    if len(sys.argv) < 3:
        print "usage: python ./test_part2_workload.py [test_name] [fuse_dir]"
        exit()
    test_name = sys.argv[1]
    fuse_dir = sys.argv[2]
    if test_name == 'stress':
        stress_test(fuse_dir)
    elif test_name == 'dedup':
        deduplicate_test(fuse_dir)
    elif test_name == 'fshare':
        file_sharing_test(fuse_dir)

if __name__ == '__main__':
    main()
