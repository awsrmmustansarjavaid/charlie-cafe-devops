# -------------------------------------------------
# ☕ Charlie Cafe - FINAL Dockerfile (PHP + Apache)
# Production Ready | DevOps Standard
# -------------------------------------------------

# Use official PHP with Apache
FROM php:8.2-apache

# -------------------------------------------------
# Install required PHP extensions
# (For MySQL / RDS connectivity)
# -------------------------------------------------
RUN docker-php-ext-install mysqli pdo pdo_mysql

# -------------------------------------------------
# Enable Apache rewrite module (for clean URLs / routing)
# -------------------------------------------------
RUN a2enmod rewrite

# -------------------------------------------------
# Set working directory
# -------------------------------------------------
WORKDIR /var/www/html

# -------------------------------------------------
# Copy frontend code (NO modification required)
# -------------------------------------------------
COPY ./app/frontend/ /var/www/html/

# -------------------------------------------------
# Set proper permissions
# -------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

# -------------------------------------------------
# Expose Apache port
# -------------------------------------------------
EXPOSE 80