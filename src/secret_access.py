#!/usr/local/bin/python

import logging
import os

from dotenv import load_dotenv

from proc_wrapper import StatusUpdater


def main():
    load_dotenv()

    logging.basicConfig(level=logging.DEBUG, format="%(asctime)s %(levelname)s: %(message)s")
    logger = logging.getLogger(__name__)

    with StatusUpdater() as updater:
        logger.info('Starting secret access ...')
        secret_value = os.environ.get('SECRET_VALUE')

        if secret_value:
            updater.send_update(last_status_message=f"Got secret value: '{secret_value}'",
                    success_count=len(secret_value))
        else:
            raise RuntimeError('Failed to read secret')

if __name__ == '__main__':
    main()
