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

require './Executor'

exec = Executor.new

# Check for debootstrap
if not exec.check_debootstrap then
    exit 1
end

# Configure the partitions
# Install basic system
# Install boot loader
# Configure system network and fstab
# Create users
# Install extra-packages

