# Copyright    2012-2013        Bryan Garber da Silva

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#################################################################################
# This file contains global constants that controls every option for the        #
# installation process. MODIFY IT CAREFULLY!                                    #
#################################################################################

CONF_PARTITIONS = {
    :root => ["sda1", "ext4"],
    :swap => ["sda2", "swap"],
    :home => ["sda3", "ext4"],
}
CONF_MOUNT_ROOT_PATH = "/mnt"
CONF_REPO_URL        = "http://ftp.br.debian.org/debian"
CONF_DEB_VERSION     = "jessie" # or 'testing', or any other Debian version.
CONF_BOOTLOADER      = "grub2"
CONF_NET_MAN         = "wicd"
CONF_OPT_PACK        = "xfce4"
CONF_EXEC_TASKSEL    = false    # if we should exec tasksel after installation

