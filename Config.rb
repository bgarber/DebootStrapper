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

################################################################################
# This file contains a module that controls every option for the installation  #
# process. MODIFY IT CAREFULLY!                                                #
################################################################################

module DebStrapConfig
    PARTITIONS = [
        "root" => "sda1",
        "swap" => "sda2",
        "home" => "sda3"
    ]
    BOOTLOADER = "grub2"
    NET_MAN = "wicd"
    OPT_PACK = "xfce4"
end

