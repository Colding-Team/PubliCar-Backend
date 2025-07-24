# Stage 1
FROM golang:1.22 as builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server ./cmd/server/main.go

# Stage 2
FROM gcr.io/distroless/static-debian11

WORKDIR /

COPY --from=builder /app/server .

ENTRYPOINT ["/server"]

EXPOSE 8080
