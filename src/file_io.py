#!/usr/local/bin/python

import logging
import os

def run():
    logging.basicConfig(level=logging.DEBUG,
                        format=f"%(asctime)s %(levelname)s: %(message)s")

    logging.info("Starting file_io.py ...")

    num_rows = int(os.environ.get('NUM_ROWS', '10'))
    temp_file_dir = os.environ.get('TEMP_FILE_DIR', '/tmp').rstrip('/')
    filename = f"{temp_file_dir}/test.txt"

    sum = 0
    i = 1
    with open(filename, 'w') as f:
        for i in range(1, num_rows):
            sum = sum + i
            logging.info(f"Writing sum {sum} ...")
            f.write(str(sum) + '\n')

    with open(filename, 'r') as f:
        for i in range(1, num_rows):
            s = f.readline()
            logging.info(f"Read sum {s.rstrip()}")

    logging.info("Done file_io.py")

if __name__ == '__main__':
    run()
