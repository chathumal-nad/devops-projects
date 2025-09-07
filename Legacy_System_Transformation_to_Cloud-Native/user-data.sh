#!/bin/bash
set -euxo pipefail

efs_id="fs-01234567890123456"
domain_name="dev.my-project.com"

# Create mount directory
mkdir -p /home/ubuntu/data
chown ubuntu:ubuntu /home/ubuntu/data

# Add EFS entry to /etc/fstab and mount it
echo "${efs_id}:/ /home/ubuntu/data efs _netdev,noresvport,tls,nofail 0 0" >> /etc/fstab
mount -a

# Create deployment.sh script
cat << 'EOF' > /home/ubuntu/deployment.sh
#!/bin/bash
set -euxo pipefail

echo "Deploying package"
cd /opt/apps/apache-tomcat-10.1.31/
sudo systemctl stop tomcat
rm -rf webapps/*
mv /home/ubuntu/my-project-saas.war /opt/apps/apache-tomcat-10.1.31/webapps/
sudo systemctl start tomcat
echo "Successfully deployed"
EOF

# Set permissions for deployment.sh so ubuntu user can execute it
chown ubuntu:ubuntu /home/ubuntu/deployment.sh
chmod +x /home/ubuntu/deployment.sh

# Create nginx server block configuration
# Note: Include escape characters for "$"

cat << EOF > /etc/nginx/conf.d/${domain_name}.conf
server {
    server_name ${domain_name};

    proxy_buffering on;
    proxy_buffers 16 16k;
    proxy_buffer_size 32k;

    client_max_body_size 5G;
    client_body_timeout 7200s;
    proxy_connect_timeout 7200s;
    proxy_send_timeout 7200s;
    proxy_read_timeout 7200s;
    send_timeout 7200s;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Forwarded-Proto https;
    }

    location ~ ^/my-project-saas/file-test/getFilePreviews/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;

        set \$no_cache 0;
        if (\$request_uri ~* \\.txt\$) {
          set \$no_cache 1;
        }

        proxy_cache_bypass \$no_cache;
        proxy_no_cache \$no_cache;

        proxy_cache my_cache;
        proxy_cache_methods GET;
        proxy_cache_valid 200 30d;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        add_header X-Proxy-Cache \$upstream_cache_status;
        proxy_ignore_headers Cache-Control Expires;
    }

    listen 80;
}
EOF

# Restart nginx to load new config
systemctl restart nginx

# Download the WAR file from S3 to /home/ubuntu
sudo -u ubuntu aws s3 cp s3:///my-project-artifacts/my-project/dev/my-project-saas.war /home/ubuntu/

# Run deployment.sh as ubuntu user
sudo -u ubuntu /home/ubuntu/deployment.sh

systemctl enable nginx
systemctl enable tomcat