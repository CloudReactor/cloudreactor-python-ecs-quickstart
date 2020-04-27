import json
import logging
import os
import socket
import atexit


def _exit_handler(updater):
    atexit.unregister(_exit_handler)
    updater.shutdown()


class StatusUpdater:
    DEFAULT_STATUS_UPDATE_PORT = 2373

    def __init__(self):
        self._logger = logging.getLogger(__name__)
        self._logger.addHandler(logging.NullHandler())

        self.socket = None
        self.port = None
        self.enabled = os.environ.get('PROC_WRAPPER_ENABLE_STATUS_UPDATE_LISTENER', 'FALSE').upper() == 'TRUE'

        if self.enabled:
            self._logger.info('StatusUpdater is enabled')
        else:
            self._logger.info('StatusUpdater is disabled')
            return
            
        self.port = int(os.environ.get('PROC_WRAPPER_STATUS_UPDATE_SOCKET_PORT') or StatusUpdater.DEFAULT_STATUS_UPDATE_PORT)

        atexit.register(_exit_handler, self)

    def send_update(self, success_count=None, error_count=None, skipped_count=None,
        expected_count=None, last_status_message=None, extra_props=None):
        if not self.enabled:
            return

        status_hash = {}

        if success_count is not None:
            status_hash['success_count'] = success_count

        if error_count is not None:
            status_hash['error_count'] = error_count

        if skipped_count is not None:
            status_hash['skipped_count'] = skipped_count

        if expected_count is not None:
            status_hash['expected_count'] = expected_count

        if last_status_message:
            status_hash['last_status_message'] = last_status_message

        if extra_props:
            status_hash['other_runtime_metadata'] = extra_props

        message = (json.dumps(status_hash) + "\n").encode('UTF-8')

        try:
            self.reuse_or_create_socket().sendto(message, ('127.0.0.1', self.port))
        except:
            self._logger.debug("Can't send status update, resetting socket")
            self.socket = None

    def shutdown(self):
        if self.socket:
            self._logger.info('Closing status update socket ...')
            try:
                self.socket.close()
                self._logger.info('Done closing status update socket.')
            finally:
                self.socket = None

    def reuse_or_create_socket(self):
        if not self.socket:
            self.socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
            self.socket.setblocking(False)

        return self.socket
