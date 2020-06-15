#!/usr/local/bin/python
import logging
import os
import signal
import random
import time
from dotenv import load_dotenv

from status_updater import StatusUpdater


def signal_handler(signum, frame):
    # This will cause the exit handler to be executed, if it is registered.
    raise RuntimeError('Caught SIGTERM, exiting.')


def make_start_message(prefix: str) -> str:
    return prefix + ' sleeping!'

def main():
    load_dotenv()

    logging.basicConfig(level=logging.DEBUG, format="%(asctime)s %(levelname)s: %(message)s")

    signal.signal(signal.SIGTERM, signal_handler)

    num_rows = int(os.environ.get('NUM_ROWS', '5'))
    row_to_fail_at = int(os.environ.get('ROW_TO_FAIL_AT', '-1'))

    updater = StatusUpdater()

    try:
        start_message = make_start_message('I am')
        updater.send_update(last_status_message=start_message,
                            expected_count=random.randrange(5, 15))
        success_count = 0
        for i in range(num_rows):
            if i == row_to_fail_at:
                updater.send_update(error_count=1)
                logging.error(f"Failed on row {i}, exiting!")
                exit(1)
            else:
                print(f"sleeping {i} ...")
                time.sleep(2)
                success_count += random.randrange(1, 10)

                try:
                    updater.send_update(success_count=success_count)
                except:
                    logging.info('Failed to send update')

                print("done sleeping")

        updater.send_update(last_status_message='woken up')
    finally:
        try:
            updater.shutdown()
        except Exception as ex:
            logging.exception("Can't shutdown updater")


if __name__ == '__main__':
    main()
