# -------------------------------------------------
# ☕ Charlie Cafe Dockerfile - PHP + Apache (FINAL)
# -------------------------------------------------

# 1️⃣ Use official PHP + Apache image
FROM php:8.2-apache

# 2️⃣ Install required PHP extensions (MySQL / RDS)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 3️⃣ Enable Apache rewrite module (for clean URLs)
RUN a2enmod rewrite

# ✅ 4️⃣ FIX Apache warning (ServerName)
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# 5️⃣ Set working directory inside container
WORKDIR /var/www/html

# 6️⃣ Copy HTML files
COPY ./app/frontend/html/ ./

# 7️⃣ Copy PHP files
COPY ./app/frontend/php/ ./

# 8️⃣ Copy CSS files
COPY ./app/frontend/css/ ./css/

# 9️⃣ Copy JS files
COPY ./app/frontend/js/ ./js/

# 🔟 Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html

# 1️⃣1️⃣ Expose Apache port
EXPOSE 80

# ✅ 1️⃣2️⃣ (Optional but BEST PRACTICE)
# Healthcheck for container monitoring
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1