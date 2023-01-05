#!/usr/bin/env python
# Takes amalgamated hosts file and converts to privoxy action file
# so you could block malicious hosts via proxy rather then /etc/hosts file
# See http://www.privoxy.org/faq/misc.html#HOSTSFILE
#
import re
import os

badguys_pattern = re.compile(
    '^0.0.0.0(\s*|\t*)(.*)\n|^127.0.0.1(\s*|\t*)(.*)\n')
localhost_pattern = re.compile(
    '^(?!\#)(.*)localhost(.*)$|^(?!\#)(.*)broadcasthost(.*)$|^0.0.0.0(\t*)local\n')
comment_pattern = re.compile('#(.*)\n')

os.unlink("hosts.action")
# touch hosts.action first if it doesn't exist
output = open("hosts.action", "w")
output.write("# Block hosts from amalgamated hosts file\n")
output.write("# See - https://github.com/StevenBlack/hosts\n")

output.write("\n# This is privoxy statement!\n{+block{bad-guys.}}\n\n")

with open('hosts', 'r') as f:
    for line in f.readlines():
        if re.match(localhost_pattern, line):
            pass
        elif re.match(comment_pattern, line):
            output.write(line)
        else:
            m = badguys_pattern.match(line)
            if m:
                if m.group(2) is not None:
                    output.write("." + m.group(2) + "\n")

output.close()
