# Dockerfile for CodeIgniter 3 Project with Composer

# Use the official PHP image with Apache
FROM php:7.4-apache

# Install necessary PHP extensions for CodeIgniter, MySQL, and GD
RUN apt-get update && apt-get install -y \
  libpng-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libzip-dev \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install gd mysqli pdo pdo_mysql zip

# Enable Apache mod_rewrite (required for CodeIgniter)
RUN a2enmod rewrite

RUN mkdir -p /var/www/html/sessions \
  && chmod 0777 /var/www/html/sessions \
  && chown www-data:www-data /var/www/html/sessions

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy the CodeIgniter project files to the container
COPY . /var/www/html

# Run composer install if composer.json exists
RUN if [ -f "composer.json" ]; then composer install; fi

# Set correct permissions for the Apache web user
RUN chown -R www-data:www-data /var/www/html

# Expose port 80 for Apache
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2-foreground"]
