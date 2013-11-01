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

# This is the main function for running the DebootStrapper.

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'Executor'
require 'Config'

#################################################################################
# Check for debootstrap
#################################################################################
rc = Exec.exec_cmd("debootstrap --help > /dev/null 2>&1")
if rc != 0
    if Exec.ask_yes_no("Debootstrap not found. Install it now?")
        rc = Exec.install('debootstrap')
        if rc != 0
            puts "Failed to get debootstrap, returning..."
            exit 1
        end
    else
        puts "No debootstrap, impossible to proceed."
        exit 1
    end
end

#################################################################################
# Configure partitions
#################################################################################

# root partition
root_dev = "/dev/#{CONF_PARTITIONS[:root][0]}" unless CONF_PARTITIONS[:root][0].empty?
root_fs  = CONF_PARTITIONS[:root][1]
root_lbl = CONF_PARTITIONS[:root][2]

if root_dev.nil? or root_fs.empty?
    puts "The conf for the root partition must not be empty."
    exit 1
end

if Exec.conf_partition(root_dev, root_fs, root_lbl) != 0
    puts "Failed to create root partition."
    exit 1
end

# swap partition
swap = "/dev/#{CONF_PARTITIONS[:swap][0]}" unless CONF_PARTITIONS[:swap][0].empty?
if swap.nil?
    puts "No swap partition... But Ok, continuing..."
else
    if Exec.exec_cmd("mkswap #{swap}") != 0
        puts "Could not create swap partition!"
        exit 1
    end

    if Exec.exec_cmd("swapon #{swap}") != 0
        puts "Failed to activate swap partition..."
        exit 1
    end
end

# home partition
home_dev = "/dev/#{CONF_PARTITIONS[:root][0]}" unless CONF_PARTITIONS[:home][0].empty?
home_fs  = CONF_PARTITIONS[:home][1]
home_lbl = CONF_PARTITIONS[:home][2]

if home_dev.nil?
    puts "No home partition. Keeping everything on the same partition."
else
    if home_fs.nil? or home_fs.empty?
        puts "No file system specified for home partition."
        exit 1
    end

    if Exec.conf_partition(root_dev, root_fs, root_lbl) != 0
        puts "Failed to create root partition."
        exit 1
    end
end

#################################################################################
# Install basic system
#################################################################################

# mount root disk
if Exec.exec_cmd("mount #{root_dev} #{CONF_MOUNT_ROOT_PATH}") != 0
    puts "Could not mount root disk!"
    exit 1
end

# exec debootstrap
if Exec.exec_cmd("debootstrap #{CONF_DEB_VERSION} #{CONF_MOUNT_ROOT_PATH} #{CONF_REPO_URL}") != 0
    puts "Error installing basic system. Check the configuration file."
    exit 1
end

# install kernel
# install boot loader
# Configure system network and fstab
# Create users
# Install extra-packages

