#!/bin/sh

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

htaccess="$parent_path/../.htaccess"

if [ -f "$htaccess" ]
then
	echo "$htaccess found. Skipping file generation"
  exit 0
else
    echo "Generating new $htaccess"
cat > $htaccess <<- "EOF"
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /wp_playground/
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /wp_playground/index.php [L]
</IfModule>

php_value upload_max_filesize 64M
php_value post_max_size 64M
php_value max_execution_time 300
php_value max_input_time 300
EOF
    chmod -v 644 $htaccess
    exit 0
fi