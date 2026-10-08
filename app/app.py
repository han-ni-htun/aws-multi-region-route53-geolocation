# Import Flask to create the web application.
from flask import Flask

# Import os so the application can read environment variables.
import os


# Create the Flask application.
app = Flask(__name__)


# Define the main page of the regional web application.
@app.route("/")
def home():
    # Read the regional configuration passed to the Docker container.
    location = os.getenv("LOCATION", "Unknown")
    aws_region = os.getenv("AWS_REGION", "Unknown")

    # Return a simple HTML page showing which regional deployment answered.
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Route 53 Geolocation Demo</title>
    </head>
    <body>
        <h1>Hello from {location}! 🌍</h1>
        <h2>AWS Region: {aws_region}</h2>
        <p>Route 53 Geolocation Routing</p>
        <p>Terraform + AWS + Docker + Amazon ECR</p>
    </body>
    </html>
    """


# Start the Flask web server on port 8080.
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)