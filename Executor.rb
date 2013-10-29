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


class Executor
    def initialize (c)
        @config = c
    end

    def ask_yes_no (question)
        puts "#{question} [Y/n] "
        answer = gets.downcase
        if answer == "" or answer == "y" then
            yield(true)
        else
            yield(false)
        end
    end

    def install (pkg)
        %x[apt-get install #{pkg}]
        return %x[echo $?]
    end

    def call_cmd (cmd)
        %x[ #{cmd} ]
        return %[echo $?]
    end

    def check_debootstrap ()
        last_rc = call_cmd("debootstrap --help > /dev/null")
        if last_rc == 0 then
            if @config.install_tools then
                install("debootstrap")
            else
                if ask_yes_no("The debootstrap tool wasn't found. Should I install it?") then
                    last_rc = install('debootstrap')
                    if last_rc then
                        puts "Failed to get debootstrap, returning..."
                        return ERROR
                    end
                end
            end
        end
    end
end
