# Use a suitable base image for your Go application
FROM golang:1.22-alpine AS builder

# Copy Go source code and dependencies
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main .

# Create a slim runtime image for efficiency
FROM alpine:latest AS runner

# Copy the built executable from the builder stage
COPY --from=builder /app/main /app/main

# Set environment variables for database connection
ENV DB_USERNAME=myuser
ENV DB_PASSWORD=mypassword
ENV DB_HOST=host.docker.internal
ENV DB_PORT=5432
ENV DB_NAME=mydb
ENV SSL=disable  # Consider using a secure connection (TLS) in production

# Expose the port for your application
EXPOSE 8080

# Command to run when the container starts (using environment variables)
#CMD ["/app/main", "-db-user", "$DB_USERNAME", "-db-password", "$DB_PASSWORD", ...]

# Optional: Add health check (adjust path based on your application)
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8080/health"]
