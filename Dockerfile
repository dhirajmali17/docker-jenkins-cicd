# Use official Apache HTTPD image
FROM httpd:2.4

# Copy your website files to Apache document root
COPY ./index.html /usr/local/apache2/htdocs/

# Expose port 80
EXPOSE 80
