FROM nginx:latest
WORKDIR /app
RUN rm -fr /etc/nginx/conf.d/default.conf
COPY . .
RUN chmod +x ./generate-ssl.sh && ./generate-ssl.sh && rm ./generate-ssl.sh
RUN mkdir -p /etc/nginx/ssl && \
    mv ./ssl/nginx.crt /etc/nginx/ssl/nginx.crt && \
    mv ./ssl/nginx.key /etc/nginx/ssl/nginx.key
COPY ./vp-app.conf /etc/nginx/conf.d/vp-app.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
