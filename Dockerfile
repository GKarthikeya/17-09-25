# Use official Python image
FROM python:3.11-slim

# Install system dependencies (Chrome + Chromedriver + fonts)
RUN apt-get update && apt-get install -y \
    wget curl unzip gnupg2 ca-certificates fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROME_VERSION=$(google-chrome --version | cut -d " " -f3 | cut -d "." -f1) && \
    wget -q https://storage.googleapis.com/chrome-for-testing-public/$CHROME_VERSION.0.0/linux64/chromedriver-linux64.zip && \
    unzip chromedriver-linux64.zip -d /usr/local/bin/ && \
    rm chromedriver-linux64.zip

# Set workdir
WORKDIR /app

# Copy project files
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose Render port
EXPOSE 10000

# Run Gunicorn (Render sets $PORT)
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:${PORT}"]
