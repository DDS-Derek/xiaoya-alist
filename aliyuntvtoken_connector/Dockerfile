FROM golang:1.22-alpine3.20 as builder

WORKDIR /app/

COPY . .

RUN go build

FROM alpine:3.20

COPY --from=builder --chmod=755 /app/aliyuntvtoken_connector /aliyuntvtoken_connector

EXPOSE 34278

ENTRYPOINT ["/aliyuntvtoken_connector"]
