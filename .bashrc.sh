# Mengubah warna prompt berdasarkan nama pengguna
if [ "$(whoami)" == "root" ]; then
    # Jika pengguna adalah root, warna prompt merah
    PS1="\[\033[1;31m\]\u@\h \[\033[1;37m\]\w\[\033[0m\]$ "
elif [ "$(whoami)" == "leakos" ]; then
    # Jika pengguna adalah leakos, warna prompt biru muda
    PS1="\[\033[1;36m\]\u@\h \[\033[1;37m\]\w\[\033[0m\]$ "
else
    # Pengguna lain menggunakan warna default
    PS1="\[\033[0m\]\u@\h \[\033[1;37m\]\w\[\033[0m\]$ "
fi
