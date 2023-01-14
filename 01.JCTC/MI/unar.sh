#!/usr/bin/bash

# dd if=whole_data.h5.tar.xz of=whole_data.h5.tar.xz.1 bs=4M count=20
# dd if=whole_data.h5.tar.xz of=whole_data.h5.tar.xz.2 bs=4M count=25 skip=20

dd if=whole_data.h5.tar.xz.1 of=whole_data.h5.tar.xz bs=4M count=20
dd if=whole_data.h5.tar.xz.2 of=whole_data.h5.tar.xz bs=4M count=25 seek=20

tar -xJvf whole_data.h5.tar.xz

./from_hdf5.py
