echo "Setting FRENCH keyboard"
loadkeys fr
echo "Setting font"
setfont ter-c24n
echo "Setting France Timezone"
timedatectl set-timezone Europe/Paris
sed -i '/^HOOKS=(/s/.$/ lvm2)/' /etc/mkinitcpio.conf
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
w" | fdisk /dev/sda

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
mkdir /mnt/home
mount /dev/my_vg/home /mnt/home
mkdir /mnt/esp
mount /dev/sda4 /mnt/esp
mkdir /mnt/boot
mount /dev/my_vg/boot /mnt/boot
swapon /dev/my_vg/swap
yes | pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
hwclock --systohc
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
mkinitcpio -P
echo "root:admin" | chpasswd
yes | pacman -S grub
yes | pacman -S efibootmgr
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB --modules="lvm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
echo "yes | pacman -S sddm konsole plasma"
umount -R /mnt
exit
reboot

echo "Finished"


