#!/bin/sh

# Copyright    2011    Bryan Garber da Silva

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

do_chrooted()
{
    # $1 == the command to execute
    # $2 == path to dir
    chroot $2 /bin/bash -c "$1"
    return $?
}

# Check if we have the necessary tools.
debootstrap --help >/dev/null
if [ $? -ne 0 ]; then
    echo "Debootstrap not found. Please, install it before continuing."
    exit 1
fi

# Create the partition table.
echo -n "Do you want to configure the partition table (Y/n)? "
read conf
if [ -z $conf ]; then
    conf=y
fi
if [ "$conf" = "Y" ] || [ "$conf" = "y" ]; then
    echo "Make sure to save your partition table before leaving."
    echo -n "Press ENTER..."
    read
    cfdisk
fi

#============ Configuring the ROOT partition ==================================#
echo -n "Please, type in the partition you want to install [/dev/sda1]:"
read root
if [ -z $root ]; then
    root='/dev/sda1'
fi
echo -n "What is the file system for this partition [ext4]?"
read root_fs
if [ -z $root_fs ]; then
    root_fs='ext4'
fi
echo -n "What is the label for this partition [\"\"]?"
read label
if [ -z $label ]; then
    mke2fs -t $root_fs $root
else
    mke2fs -t $root_fs -L "$label" $root
fi
if [ $? -ne 0 ]; then
    echo "There was some error formatting the partition."
    echo "Please, verify if there the data you provided is valid:"
    echo -n "  Root partition: "
    echo $root
    echo -n "  FS for the partition: "
    echo $root_fs
    exit 1
fi
#==============================================================================#

#============ Configuring the SWAP partition ==================================#
echo -n "There is any swap partition (Y/n)?"
read swap
if [ -z $swap ]; then
    swap=y
fi
if [ "$swap" = "Y" ] || [ "$swap" = "y" ]; then
    with_swap=y
    echo -n "Great! Where is the swap partition located [/dev/sda2]?"
    read swap
    if [ -z $swap ]; then
        swap='/dev/sda2'
    fi
    mkswap $swap
    if [ $? -ne 0 ]; then
        echo "There was some error creating the swap partition."
        echo "Please, verify if there the data you provided is valid:"
        echo -n "  Swap partition: "
        echo $swap
    fi
    swapon $swap
else
    echo "It would be good to have a swap partition, but that's Ok."
fi
#==============================================================================#

#============ Configuring the HOME partition ==================================#
echo -n "The home will reside on a separate partition (Y/n)?"
read home
if [ -z $home ]; then
    home=y
fi
if [ "$home" = "Y" ] || [ "$home" = "y" ]; then
    with_home=y
    echo -n "Great! Where is the home partition located [/dev/sda3]?"
    read home
    if [ -z $home ]; then
        home='/dev/sda3'
    fi
    echo -n "What is the file system for this partition [ext4]?"
    read home_fs
    if [ -z $home_fs ]; then
        home_fs='ext4'
    fi
    echo -n "Do you want to format the home partition (y/N)? "
    read format
    if [ -z $format ]; then
        format=n
    fi
    if [ $format = 'Y' ] || [ $format = 'y' ]; then
        echo -n "What is the label for this partition [\"\"]?"
        read label
        if [ -z $label ]; then
            mke2fs -t $home_fs $home
        else
            mke2fs -t $home_fs -L "$label" $home
        fi
        if [ $? -ne 0 ]; then
            echo "There was some error formatting the partition."
            echo "Please, verify if the data you provided is valid:"
            echo -n "  Home partition: "
            echo $root
            echo -n "  FS for the partition: "
            echo $home_fs
            exit 1
        fi
    fi
else
    echo "It's a good practice to keep your home directory separated, but ok.:)"
fi
#==============================================================================#

# Mount the root partition
mount_dir='/mnt'
mount $root $mount_dir
if [ $? -ne 0 ]; then
    echo "OH NOES! Error?!"
    exit 1
fi

#============ Configuring the Bootstrap repo ==================================#
echo -n "Debian distribution [testing]:"
read distro
if [ -z $distro ]; then
    distro='testing'
fi
echo -n "Debian repository URL [http://ftp.debian.org/debian]: "
read repo_url
if [ -z $repo_url ]; then
    repo_url='http://ftp.debian.org/debian'
fi
debootstrap $distro $mount_dir $repo_url
if [ $? -ne 0 ]; then
    echo "Error checking out the Debian repository."
    echo "Check if the data you provided is valid:"
    echo -n "  Distro: "
    echo $distro
    echo -n "  URL: "
    echo $repo_url
fi
#==============================================================================#

#============ Configuring and installing Linux kernel =========================#
echo "Choose your computer architecture:"
echo " 1) 486"
echo " 2) 686"
echo " 3) 686-bigmem"
echo " 4) 686-pae"
echo " 5) amd64"
echo -n "Which one [2]? "
arch=6
while [ $arch -lt 1 ] || [ $arch -gt 5 ]; do
    read arch
    if [ -z $arch ]; then
        arch=2
    fi
done
case $arch in
    1)arch="486";;
    2)arch="686";;
    3)arch="686-bigmem";;
    3)arch="686-pae";;
    3)arch="amd64";;
esac
linux="linux-image-$arch"
do_chrooted("apt-get update", $mount_dir)
do_chrooted("apt-get -y install $linux", $mount_dir)
#==============================================================================#

#============ Configuring the /etc/fstab ======================================#
echo "Creating fstab..."
echo "#<file system> <mount point> <type> <options> <dump > <pass>" >$mount_dir/etc/fstab
echo "$root      /             $root_fs   defaults  1       1" >>$mount_dir/etc/fstab
if [ $with_swap = "y" ]; then
    echo "$swap      swap          swap   defaults  0       0" >>$mount_dir/etc/fstab
fi
if [ $with_home = "y" ]; then
    echo "$home      /home         $home_fs   defaults  1       2" >>$mount_dir/etc/fstab
fi
#==============================================================================#

# Create the device files
do_chrooted("mknod /dev/sda  b 8 0", $mount_dir)
do_chrooted("mknod /dev/sda1 b 8 1", $mount_dir)
do_chrooted("mknod /dev/sda2 b 8 2", $mount_dir)
do_chrooted("mknod /dev/sda3 b 8 3", $mount_dir)

#============ Configuring and installing GRUB =================================#
echo "apt-get -y install grub2 ; exit" | chroot $mount_dir
#==============================================================================#

#============ Configuring the network =========================================#
echo -n "What is the desired hostname [debian]? "
read hostname
if [ -z $hostname ]; then
    hostname='debian'
fi
echo $hostname >$mount_dir/etc/hostname
echo "127.0.0.127\tlocalhost $hostname" >$mount_dir/etc/hosts
echo "::127\tlocalhost ip6-localhost ip6-loopback" >>$mount_dir/etc/hosts
echo "fe00::0\tip6-localnet" >>$mount_dir/etc/hosts
echo "ff00::0\tip6-mcastprefix" >>$mount_dir/etc/hosts
echo "ff02::1\tip6-allnodes" >>$mount_dir/etc/hosts
echo "ff02::2\tip6-allrouters" >>$mount_dir/etc/hosts
echo -n "Install the default network-manager (Y/n)? "
read net_man
if [ -z $net_man ]; then
    net_man='y'
fi
if [ $net_man = 'Y' ] || [ $net_man = 'y' ]; then
    do_chrooted("apt-get -y install network-manager", $mount_dir)
else
    echo "Well, I will rely that you know what you're doing here."
    echo -n "Entry with the name of the package [network-manager]: "
    read net_man
    if [ -z $net_man ]; then
        net_man='network-manager'
    fi
    do_chrooted("apt-get -y install $net_man", $mount_dir)
fi
#==============================================================================#

#============ Configuring time and locales ====================================#
do_chrooted("apt-get -y install console-data locales locales-all tzdata", $mount_dir)
do_chrooted("dpkg-reconfigure locales", $mount_dir)
do_chrooted("dpkg-reconfigure tzdata", $mount_dir)
#==============================================================================#

#============ Configuring root and a new user =================================#
echo "Configuring the root user password."
do_chrooted("passwd", $mount_dir)
echo -n "Add any new user (Y/n)? "
read user
if [ -z $user ]; then
    user='y'
fi
if [ $user = 'Y' ] || [ $user = 'y' ]; then
    echo -n "Type the login of the new user: "
    read user
    while [ -z $user ]; do
        echo -n "Type a valid name for the user: "
        read user
    done
    do_chrooted("adduser $user", $mount_dir)
    echo -n "Groups for the new user [cdrom audio video plugdev netdev]: "
    read groups
    if [ -z $groups ]; then
        groups='cdrom audio video plugdev netdev'
    fi
    for g in $groups; do
        do_chrooted("adduser $user $g", $mount_dir)
    done
fi
#==============================================================================#

#============ Install any other package? ======================================#
echo -n "Install any additional packages (y/N)?"
read pack
if [ -z $pack ]; then
    pack='n'
fi
if [ $pack = 'Y' ] || [ $pack = 'y' ]; then
    echo "Again, I will rely that you know what you're doing."
    echo -n "Type the desired packages, separated by spaces [vim make gcc]: "
    read pack
    if [ -z $pack ]; then
        pack='vim make gcc'
    fi
    do_chrooted("apt-get -y install $pack", $mount_dir)
fi
#==============================================================================#

# Clean everything
echo "Cleaning everything..."
do_chrooted("apt-get clean", $mount_dir)
umount $mount_dir
echo "It's time to reboot and enjoy the new system! :-)"
echo "Don't forget to edit the /etc/apt/sources.list to add other Debian repositories."

