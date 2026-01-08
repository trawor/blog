FROM ghcr.io/gohugoio/hugo:v0.154.3 AS BUILD

ADD . /project
RUN /usr/bin/hugo -s /project -d /project/public

FROM nginx:alpine
COPY --from=BUILD /project/public /usr/share/nginx/html/