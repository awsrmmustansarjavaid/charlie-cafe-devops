# -------------------------------------------------
# ☕ Charlie Cafe Dockerfile (PHP + Apache)
# -------------------------------------------------

# Use official PHP Apache image
FROM php:8.2-apache

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite (important)
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy your app code into container
COPY app/frontend/ /var/www/html/

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80