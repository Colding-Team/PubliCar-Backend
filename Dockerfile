# Stage 1
FROM golang:1.23.4-alpine3.21 AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /bin/server ./cmd/server/main.go

# Stage 2
FROM scratch

WORKDIR /app

COPY --from=builder /bin/server /app/server

EXPOSE 8080

ENTRYPOINT ["/app/server"]
