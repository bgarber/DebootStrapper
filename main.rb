# Copyright    2012        Bryan Garber da Silva

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

require 'Config'

SUCCESS = 0
ERROR   = 1

class Main
    def initialize (conf)
        @config = Config.new(conf)
    end

    def ask_yes_no (question)
        printf("%s [Y/n] ", question)
        answer = gets
        if answer.downcase == "y" then
            answer = "y"
        else
            answer = "n"
        end
        yield(answer)
    end

    def run ()
        # Check for debootstrap
        %x[debootstrap --help > /dev/null]
        last_rc = %x[echo $?] # the last return code
        if last_rc == 0 then
            if @config.install_tools then
                %x[apt-get install debootstrap]
            else
                ask_yes_no("The debootstrap tool wasn't found. " +
                    "Should I install it?") { | answer |
                    if answer = "y" then
                        %x[apt-get install debootstrap]
                        last_rc = %x[echo $?]
                        if last_rc then
                            puts "Failed to get debootstrap, returning..."
                            return ERROR
                        end
                    end
                }
            end
        end

        # Configure the partitions

        # Install basic system
        # Install boot loader
        # Configure system network and fstab
        # Create users
        # Install extra-packages

        return SUCCESS
    end
end

mp = Main.new(ARGV[0])
mp.run

