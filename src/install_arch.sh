echo "Setting FRENCH keyboard"
loadkeys fr
echo "Setting font"
setfont ter-c24n
echo "Setting France Timezone"
timedatectl set-timezone Europe/Paris
echo "Creating disk"
yes | pvcreate /dev/sda
yes | vgcreate my_vg /dev/sda
lvcreate -n root -L 15G my_vg
lvcreate -n home -L 5G my_vg
lvcreate -n boot -L 400M my_vg
lvcreate -n swap -L 500M my_vg
mkfs.ext4 /dev/my_vg/root
mkfs.ext4 /dev/my_vg/home
mkfs.ext4 /dev/my_vg/boot
mkswap /dev/my_vg/swap
echo "Mount disk"
mount /dev/my_vg/root /mnt
mkdir /mnt/home
mount /dev/my_vg/home /mnt/home
mkdir /mnt/boot
mount /dev/my_vg/boot /mnt/boot
swapon /dev/my_vg/swap

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
hwclock --systohc
locale-gen
echo "LANG=fr_FR.UTF-8" > etc/locale.conf
echo "KEYMAP=fr" > /etc/vconsole.conf
mkinitcpio -P
echo "root:admin" | chpasswd
yes | pacman -S grub
yes | pacman -S efibootmgr
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /mnt/boot/grub/grub.cfg
exit
umount -R /mnt
reboot

echo "Finished"


