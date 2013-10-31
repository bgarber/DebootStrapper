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

load 'Executor.rb'
load 'Config.rb'

# Check for debootstrap
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

# Configure partitions
puts CONF_PARTITIONS

# Install basic system
# Install boot loader
# Configure system network and fstab
# Create users
# Install extra-packages

