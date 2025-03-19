FROM golang:1.24 AS builder

COPY . /src
WORKDIR /src

#RUN GOPROXY=https://goproxy.cn make build

#FROM debian:stable-slim
FROM alpine:3.20

#RUN apt-get update && apt-get install -y --no-install-recommends \
#		ca-certificates  \
#        netbase \
#        && rm -rf /var/lib/apt/lists/ \
#        && apt-get autoremove -y && apt-get autoclean -y
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
#RUN apk --no-cache add tzdata \
#    && apk add --no-cache ca-certificates  \
#    && update-ca-certificates \
#    && apk cache clean \

ENV PATH="/app:${PATH}"

COPY --from=builder /src/bin /app

WORKDIR /app

EXPOSE 8000
EXPOSE 9000
VOLUME /data/conf

ENTRYPOINT ["server"]

CMD ["server", "-conf", "/data/conf/config.yaml"]
