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

module Exec
    def Exec.ask_yes_no (question)
        print "#{question} [Y/n] "
        answer = gets.downcase.strip
        if answer.empty? or answer.eql? "y" or answer.eql? "yes"
            return true
        else
            return false
        end
    end

    def Exec.command (cmd)
        %x[ #{cmd} ]
        return %[echo $?]
    end

    def Exec.install (pkg)
        return Exec.exec_cmd("apt-get install #{pkg}")
    end

    def Exec.conf_partition (dev, fs, lbl)
        mkfs_cmd = ""
        if lbl.nil? or lbl.empty?
            mkfs_cmd = "mke2fs -t #{fs} #{dev}"
        else
            mkfs_cmd = "mke2fs -t #{fs} -L #{lbl} #{dev}"
        end

        return Exec.exec_cmd(mkfs_cmd)
    end

    def Exec.chroot (path, cmd)
        return Exec.exec_cmd("chroot #{path} /bin/bash -c #{cmd}")
    end
end

