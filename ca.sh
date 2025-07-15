#!/bin/bash

# Skrip konfigurasi make-ca di LFS/BLFS 11.2 tanpa error
# p11-kit sudah terinstal dan menggunakan wget tanpa verifikasi sertifikat

set -e  # Hentikan skrip jika ada kesalahan

echo "Memulai konfigurasi make-ca..."

# Pastikan p11-kit sudah terinstal
if ! command -v p11-kit &> /dev/null; then
    echo "p11-kit belum terinstal. Pastikan p11-kit sudah terinstal terlebih dahulu."
    exit 1
else
    echo "p11-kit sudah terinstal."
fi

# Pastikan make-ca sudah terinstal
if [ ! -f /usr/sbin/make-ca ]; then
    echo "Instalasi make-ca..."
    
    # Download dan ekstrak make-ca
    wget --no-check-certificate https://github.com/lfs-book/make-ca/releases/download/v1.10/make-ca-1.10.tar.xz
    tar -xvf make-ca-1.10.tar.xz
    cd make-ca-1.10
    sudo make install
    sudo install -vdm755 /etc/ssl/local
else
    echo "make-ca sudah terinstal."
fi

# Mengunduh sertifikat root menggunakan wget tanpa memverifikasi sertifikat SSL
echo "Mengunduh sertifikat root dari CAcert..."
wget --no-check-certificate -O /etc/ssl/certs/root.crt http://www.cacert.org/certs/root.crt
wget --no-check-certificate -O /etc/ssl/certs/class3.crt http://www.cacert.org/certs/class3.crt

# Mengonversi dan menambahkan sertifikat root ke sistem
echo "Menambahkan sertifikat root ke sistem..."
sudo openssl x509 -in /etc/ssl/certs/root.crt -text -fingerprint -setalias "CAcert Class 1 root" \
     -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
     > /etc/ssl/local/CAcert_Class_1_root.pem

sudo openssl x509 -in /etc/ssl/certs/class3.crt -text -fingerprint -setalias "CAcert Class 3 root" \
     -addtrust serverAuth -addtrust emailProtection -addtrust codeSigning \
     > /etc/ssl/local/CAcert_Class_3_root.pem

# Memperbarui store sertifikat dengan make-ca
echo "Memperbarui store sertifikat dengan make-ca..."
sudo /usr/sbin/make-ca -r

# Menambahkan cron job untuk pembaruan sertifikat otomatis setiap minggu
echo "Menambahkan cron job untuk pembaruan sertifikat otomatis..."
sudo bash -c 'cat > /etc/cron.weekly/update-pki.sh << "EOF"
