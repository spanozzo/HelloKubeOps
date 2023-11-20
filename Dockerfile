FROM alpine
ARG VERSION=v1.0.0
ENV APP_VERSION=$VERSION
CMD echo "Hello World - Version $APP_VERSION" && tail -f /dev/null