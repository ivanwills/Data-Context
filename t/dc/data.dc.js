{
    "TYPE"   : "DEFAULT",  # end of line comment
    "basic"  : "text",
    "number" : 25,
    "hash"   : {
        # nested comment
        "content" : {
            "METHOD" : "expand_vars",
            "value"  : "test.value.0",
        },
        "straight_var" : "#test.value.1#",
    },
    "list" : [
        "one",
        "two"
    ],
}
