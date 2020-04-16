package main

disallowed_tags := ["latest"]


deny[msg] {
        input[i].Cmd == "from"
        val := input[i].Value
        tag := split(val[0], ":")[1]
        contains(tag, disallowed_tags[_])
        msg = sprintf("[%s] tag is not allowed", [tag])
}
