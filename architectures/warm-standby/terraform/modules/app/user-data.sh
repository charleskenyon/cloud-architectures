#!/bin/bash

DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASS="${db_pass}"
IS_PRIMARY="${is_primary}"

# setup
yum update -y
yum install -y httpd mysql amazon-cloudwatch-agent

systemctl enable httpd
systemctl start httpd

echo "<h1>Starting up... $(hostname -f)</h1>" > /var/www/html/index.html

# wait for RDS connection
echo "Waiting for RDS at $DB_HOST..."

until mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "SELECT 1" >/dev/null 2>&1; do
  echo "RDS not ready... retrying in 10s"
  sleep 10
done

echo "RDS is ready"

# seed RDS on primary only
if [ "$IS_PRIMARY" = "true" ]; then
  echo "Seeding DB (primary region)"

  mysql -h $DB_HOST -u $DB_USER -p$DB_PASS <<EOF
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO users (name) VALUES ('hello-from-primary');
EOF

else
  echo "Secondary region — skipping seed"
fi

# query DB
echo "Querying database..."

DB_OUTPUT=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -D testdb -se "SELECT name FROM users;")

# build static web page and restart web server
HTML_FILE="/var/www/html/index.html"

echo "<html><body>" > $HTML_FILE
echo "<h1>Hello from $(hostname -f)</h1>" >> $HTML_FILE
echo "<p>DB Host: $DB_HOST</p>" >> $HTML_FILE
echo "<h2>Users:</h2>" >> $HTML_FILE

if [ -z "$DB_OUTPUT" ]; then
  echo "<p>No data found</p>" >> $HTML_FILE
else
  for name in $DB_OUTPUT; do
    echo "<p>User: $name</p>" >> $HTML_FILE
  done
fi

echo "</body></html>" >> $HTML_FILE

systemctl restart httpd

echo "Static site generated successfully"