#!/usr/local/bin/python

import logging
import os
import time


def inner_loop(i, row_to_fail_at):
    if i == row_to_fail_at:
        logging.error(f"Failed on row {i}, exiting!")
        exit(1)
    else:
        logging.debug(f"Processing row {i} ...")
        time.sleep(2)

def run():
    logging.basicConfig(level=logging.DEBUG,
                        format=f"%(asctime)s %(levelname)s: %(message)s")

    num_rows = int(os.environ.get('NUM_ROWS', '30'))
    row_to_fail_at = int(os.environ.get('ROW_TO_FAIL_AT', '-1'))
    is_service = (os.environ.get('PROC_WRAPPER_PROCESS_IS_SERVICE', 'FALSE') == 'TRUE')

    logging.info('Starting example process ...')

    if is_service:
        while True:
            inner_loop(0, row_to_fail_at)
    else:
        for i in range(num_rows):
            inner_loop(i, row_to_fail_at)

    logging.info('Done example process.')


if __name__ == '__main__':
    run()
