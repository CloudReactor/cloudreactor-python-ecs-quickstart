"""
An example task that is using Flask to implement a simple web server.
"""

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    """Returns a sample string as the response."""
    return 'Hello from CloudReactor!'
