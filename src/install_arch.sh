echo "Setting FRENCH keyboard"
loadkeys fr
pacman -Sy
echo "Setting font"
setfont ter-c24n
echo "Setting France Timezone"
timedatectl set-timezone Europe/Paris
echo "Creating disk"

echo -e "n\n\
e\n\
4\n\
\n\
+500M\n\
t\n\
ef\n\
n\n\
p\n\
1\n\
\n\
+21G\n\
n\n\
p\n\
2\n\
\n\
+35G\n\
w" | fdisk /dev/sda
yes | pvcreate /dev/sda2
yes | vgcreate my_vg2 /dev/sda2
lvcreate -n root -L 25G my_vg2
lvcreate -n home -L 5G my_vg2
lvcreate -n boot -L 500M my_vg2
lvcreate -n swap -L 500M my_vg2
mkfs.ext4 /dev/my_vg2/root
mkfs.ext4 /dev/my_vg2/home
mkfs.ext4 /dev/my_vg2/boot
mkswap /dev/my_vg2/swap


yes | pvcreate /dev/sda1
yes | vgcreate my_vg /dev/sda1
lvcreate -n root -L 15G my_vg
lvcreate -n home -L 5G my_vg
lvcreate -n boot -L 400M my_vg
lvcreate -n swap -L 500M my_vg
mkfs.ext4 /dev/my_vg/root
mkfs.ext4 /dev/my_vg/home
mkfs.ext4 /dev/my_vg/boot
mkfs.fat -F 32 /dev/sda4
mkswap /dev/my_vg/swap
echo "Mount disk"
mount /dev/my_vg/root /mnt
mount --mkdir /dev/my_vg/home /mnt/home
mount --mkdir /dev/sda4 /mnt/esp
mount --mkdir /dev/my_vg/boot /mnt/boot
swapon /dev/my_vg/swap
yes | pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt <<EOF
sed -i '/^HOOKS=(/s/.$/ lvm2)/' /etc/mkinitcpio.conf
pacman -S --noconfirm lvm2
pacman -S --noconfirm emacs
pacman -S --noconfirm man-db man-pages texinfo
pacman -S --noconfirm amd-ucode
hwclock --systohc
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
mkinitcpio -P
echo "root:admin" | chpasswd
pacman -S --noconfirm grub
pacman -S --noconfirm efibootmgr
sed -i 'GRUB_PRELOAD_MODULES="/s/.$/ lvm"/' /etc/default/grub
sed -i '/#GRUB_DISABLE_OS_PROBER/s/^#//' /etc/default/grub
pacman -S --noconfirm os-probber

grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB --modules="lvm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
groupadd Hogwarts
groupadd asso
groupadd managers
useradd -m -g asso -G Hogwarts turban
useradd -m -g managers -G Hogwarts dumbleddore
echo "dumbleddore:gamut" | chpasswd
echo "turban:gamut" | chpasswd


pacman -S --noconfirm sddm konsole plasma
pacman -S --noconfirm kde-applications
pacamn -S --noconfirm sddm-kcm
systemctl enable sddm
systemctl start sddm
systemctl enable NetworkManager
systemctl start NetworkManager
nmcli connection up "Wired connection 1"


exit
EOF
umount -R /mnt
reboot
echo "Finished"


