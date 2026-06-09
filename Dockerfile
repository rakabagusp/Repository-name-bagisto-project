FROM php:8.3-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev zip \
    libicu-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo \
        pdo_mysql \
        bcmath \
        intl \
        gd \
        calendar \
        zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy project
COPY . .

# Install dependencies Laravel / Bagisto
RUN composer install --no-dev --optimize-autoloader

# Expose port Railway
EXPOSE 8080

# Run Laravel
CMD php artisan config:clear && \
    php artisan cache:clear && \
    php artisan key:generate --force && \
    php artisan migrate --force && \
    php artisan db:seed --force && \
    php artisan storage:link && \
    php -S 0.0.0.0:$PORT -t public
