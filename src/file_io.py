#!/usr/local/bin/python

import logging
import os

def run():
    logging.basicConfig(level=logging.DEBUG,
                        format=f"%(asctime)s %(levelname)s: %(message)s")

    logging.info("Done file_io.py")

    num_rows = int(os.environ.get('NUM_ROWS', '10'))
    temp_file_dir = os.environ.get('TEMP_FILE_DIR', '/tmp')

    sum = 0
    i = 1
    with open("test.txt", 'w') as f:
        for i in range(1, num_rows):
            sum = sum + i
            logging.info(f"Writing sum {sum} ...")
            f.write(str(sum) + '\n')

    with open("test.txt", 'r') as f:
        for i in range(1, num_rows):
            s = f.readline()
            logging.info(f"Read sum {s.rstrip()}")

    logging.info("Done file_io.py")

if __name__ == '__main__':
    run()
