FROM python:3.12

# Create a dedicated non-root group and user to run the application.
RUN groupadd --system app \
    && useradd --system --gid app --create-home --home-dir /app app

# Always use an absolute path for WORKDIR.
WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Ensure the non-root user owns the application files.
RUN chown -R app:app /app

EXPOSE 5000

# Run the application as the non-root user.
USER app

# Bind inside the container; override at runtime if needed.
ENV FLASK_HOST=0.0.0.0 \
    FLASK_PORT=5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health')" || exit 1

CMD ["python", "run.py"]

