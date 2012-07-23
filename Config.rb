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


class Config
    def initialize (conf)
        cfg = File.open(conf) { |handle|
            handle.each_line { |line|
                line_array = line.split(/=/)
                case line
                    when /^INSTALL_TOOLS/
                        if line_array[1].downcase == "yes" or
                           line_array[1].downcase == "y" then
                            @install_tools = true
                        else
                            @install_tools = false
                        end
                    when /^BOOTLOADER/
                        @bootloader = line_array[1]
                    else
                        puts "Unknown sequence of characters: #{line}"
                end
            }
        }
    end
end

