#!/bin/bash

# You generally run a command with LC_ALL=C to avoid the user's settings
# to interfere with your script. For instance, if you want [a-z] to match
# the 26 ASCII characters from a to z, you have to set LC_ALL=C.
# On GNU systems, LC_ALL=C and LC_ALL=POSIX (or LC_MESSAGES=C|POSIX) override $LANGUAGE,
# while LC_ALL=anything-else wouldn't.

LC_ALL=C

# Check root privileges
echo "This quick installer script requires root privileges."
echo "Checking..."
if [[ $(/usr/bin/id -u) -ne 0 ]];
then
    echo "Not running as root."
    echo "Exit"
    exit 1
else
    echo "Installation continues..."
fi

# Check sudo
SUDO=
if [ "$UID" != "0" ]; then
    if [ -e /usr/bin/sudo -o -e /bin/sudo ]; then
        SUDO=sudo
        echo "Installation continues..."
    else
        echo "*** This quick installer script requires root privileges."
        echo "Exit"
        exit 1
    fi
fi

# main
echo "---> Start"

# Create directory for temp mounted custom_iso image
mkdir /tmp/custom_iso

# Create directory for iso images
mkdir /iso

#Load iso image into variable ISO
ISO="/iso/example.iso"

# Mount custom_iso image
mount -t iso9660 -o loop $ISO /mnt

# Copy the custom_iso image
cd /mnt
tar cf - . | (cd /tmp/custom_iso; tar xfp -)

# Modify isolinux.cfg Set the default start option to DVD - here you have to change the line with sed to modify it the way you need. 
cd /tmp/custom_iso/boot/x86_64/loader
sed -i 's/DEFAULT harddisk/DEFAULT Autoinstallation/g' isolinux.cfg

# Create an iso image
mkisofs -joliet -rock -full-iso9660-filenames -o $temp_iso -no-allow-lowercase -b boot/x86_64/loader/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot EFI/BOOT/bootx64.efi .

# Unmount custom_iso image
umount /mnt

cd /tmp
# remove custom_iso directory from /tmp
rm -rf custom_iso

# generate a file checksum and store the value in a file
md5sum $temp_iso > $temp_md5

# check a file checksum
cat $temp_md5

echo "Proceed with PXE boot"
