package instructions

# blacklist = [
#   "add"
# ]

# deny[msg] {
#   input[i].Cmd == "add"
#   contains(input[_].Cmd, blacklist[_])

#   msg = sprintf("blacklisted instructions found %s", [val])
# }