from task_1 import make_start_message

class TestTask1:
    def test_make_start_message(self):
        x = make_start_message('Not')
        assert x == 'Not sleeping!'        