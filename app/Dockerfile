# Use a lightweight Python 3.12 image as the application base image.
FROM python:3.12-slim

# Set /app as the working directory inside the container.
WORKDIR /app

# Copy the dependency file first so Docker can cache the dependency layer.
COPY requirements.txt .

# Install the Python dependencies required by the web application.
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code into the container.
COPY app.py .

# Document that the application listens on TCP port 8080.
EXPOSE 8080

# Start the Flask application when the container starts.
CMD ["python", "app.py"]