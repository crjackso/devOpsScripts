#!/bin/sh

wp_url="http://localhost:8888/wp_playground"
wp_title="WP_Playground"
wp_admin_email="crjackso@gmail.com"

if ! [ -x "$(command -v wp)" ]; then
    echo 'wp-cli is not installed. Installing now.' >&2
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
else
    echo 'wp-cli already installed'
fi

if ! $(wp core is-installed); then
    wp core install
fi

echo 'Setting up WordPress'

wp core download
wp core config --dbname=wordpress_db --dbuser=root --dbpass=test1234 --dbhost=localhost --dbprefix=wp_
wp core install --url=$wp_url --title=$wp_title --admin_user="admin" --admin_password="test1234" --admin_email=$wp_admin_email
