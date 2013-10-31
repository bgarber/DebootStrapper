# Copyright    2013        Bryan Garber da Silva

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

require './Config'

class Executor
    def initialize ()
    end

    def ask_yes_no (question)
        print "#{question} [Y/n] "
        answer = gets.downcase
        if answer == "" or answer == "y" then
            return true
        else
            return false
        end
    end

    def exec_cmd (cmd)
        %x[ #{cmd} ]
        return %[echo $?]
    end

    def install (pkg)
        return exec_cmd("apt-get install #{pkg}")
    end

    def check_debootstrap ()
        last_rc = exec_cmd("debootstrap --help > /dev/null 2>&1")
        if last_rc != 0 then
            if ask_yes_no("Debootstrap not found. Install it now?") then
                last_rc = install('debootstrap')
                if last_rc != 0 then
                    puts "Failed to get debootstrap, returning..."
                    return false
                end
            end
        end

        return true
    end

    private :ask_yes_no, :exec_cmd, :install
end
