#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
local_ip=$(hostname -I | awk '{print $1}')


echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}=========================== Script Install Moodle. =========================${NC}"
echo -e "${GREEN}========================== Apache2, PHP, MariaDB, ========================${NC}"
echo -e "${GREEN}===================== By LSTNetwork. Info 085322692888 =====================${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}Silahkan baca terlebih dahulu. Apakah anda ingin melanjutkan? (y/n)${NC}"
read confirmation
if [ "$confirmation" != "y" ]; then
    echo -e "${GREEN}Install dibatalkan. Tidak ada perubahan dalam ubuntu server anda.${NC}"
    exit 1
fi

# Pastikan skrip dijalankan dengan hak akses root
if [ "$(id -u)" -ne 0 ]; then
  echo "Skrip ini harus dijalankan sebagai root atau menggunakan sudo" 
  exit 1
fi


# add repository
cat <<EOF > /etc/apt/sources.list
deb http://deb.debian.org/debian bullseye main
deb-src http://deb.debian.org/debian bullseye main
deb http://security.debian.org/debian-security bullseye-security main
deb-src http://security.debian.org/debian-security bullseye-security main
deb http://deb.debian.org/debian bullseye-updates main
deb-src http://deb.debian.org/debian bullseye-updates main
EOF

# Pembaruan dan instalasi paket-paket yang diperlukan
echo "Melakukan pembaruan dan menginstal paket yang diperlukan..."
apt update -y && apt upgrade -y
apt install -y apache2 mariadb-server php php-mysqli php-xmlrpc php-intl php-json php-curl php-gd php-mbstring php-xml php-zip php-soap php-intl wget unzip phpmyadmin

# Aktifkan dan mulai layanan Apache dan MariaDB
echo "Mengaktifkan layanan Apache dan MariaDB..."
systemctl enable apache2
systemctl enable mariadb
systemctl start apache2
systemctl start mariadb

# Mengamankan instalasi MariaDB
echo "Menjalankan konfigurasi keamanan MariaDB..."
mysql_secure_installation

# Konfigurasi MariaDB untuk Moodle
echo "Membuat database dan user untuk Moodle di MariaDB..."
mysql -u root -p -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Download Moodle
echo "Mendownload Moodle versi terbaru..."
cd /var/www/html
wget https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz

# Ekstrak file Moodle
echo "Mengekstrak file Moodle..."
tar -zxvf moodle-latest-311.tgz
rm moodle-latest-311.tgz

# Menetapkan izin folder moodle
echo "Menetapkan izin folder untuk Moodle..."
chown -R www-data:www-data /var/www/html/moodle
chmod -R 755 /var/www/html/moodle

# Menetapkan izin folder moodle
mkdir /var/www/moodledata
chown -R www-data:www-data /var/www/moodledata/

# Konfigurasi Apache untuk Moodle
echo "Membuat konfigurasi virtual host untuk Moodle di Apache..."
cat <<EOF > /etc/apache2/sites-available/moodle.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/moodle
    ServerName moodle.example.com
    <Directory /var/www/html/moodle>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Aktifkan situs dan mod_rewrite Apache
echo "Mengaktifkan situs Moodle dan mod_rewrite di Apache..."
a2ensite moodle.conf
a2enmod rewrite
systemctl reload apache2

# Persiapan untuk instalasi Moodle
echo "Persiapkan instalasi Moodle melalui web browser..."

#Sukses
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}========= Buka browser dan buka alamat: http://$local_ip/moodle ============${NC}"
echo -e "${GREEN}=================== Informasi: Whatsapp 0853-2269-2888 =====================${NC}"
echo -e "${GREEN}============================================================================${NC}"

# Catatan tambahan: Anda akan diminta untuk memasukkan database dan informasi administrator Moodle selama instalasi web