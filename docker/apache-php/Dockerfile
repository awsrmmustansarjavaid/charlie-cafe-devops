# -------------------------------------------------
# ☕ Charlie Cafe Dockerfile - PHP + Apache
# Copy multiple frontend folders to Apache web root
# -------------------------------------------------

# 1️⃣ Use official PHP + Apache image
FROM php:8.2-apache

# 2️⃣ Install required PHP extensions (MySQL / RDS)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 3️⃣ Enable Apache rewrite module (for clean URLs)
RUN a2enmod rewrite

# 4️⃣ Set working directory inside container
WORKDIR /var/www/html

# 5️⃣ Copy HTML files to Apache root
# Source: app/frontend/html/
# Destination: /var/www/html/
COPY ./app/frontend/html/ ./  

# 6️⃣ Copy PHP files to Apache root
# Source: app/frontend/php/
# Destination: /var/www/html/
COPY ./app/frontend/php/ ./  

# 7️⃣ Copy CSS files (optional, for frontend styling)
COPY ./app/frontend/css/ ./css/

# 8️⃣ Copy JS files (optional, for frontend scripts)
COPY ./app/frontend/js/ ./js/

# 9️⃣ Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# 🔟 Expose Apache port
EXPOSE 80