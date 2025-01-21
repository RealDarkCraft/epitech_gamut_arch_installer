echo "Setting FRENCH keyboard"
loadkeys fr
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
w" | fdisk /dev/sda

echo "Finished"
echo "Finished"


