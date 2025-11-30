# Stage 1: Build the Go binary
FROM golang:1.25 AS builder

# Enable Go modules
WORKDIR /app

# Copy go.mod and go.sum first (better caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

# Stage 2: Run the binary in a tiny container
FROM alpine:latest

# Create a non-root user
RUN adduser -D appuser

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/server .

# Expose the port Gin listens on
EXPOSE 8080

# Switch to non-root
USER appuser

# Start server
CMD ["./server"]
