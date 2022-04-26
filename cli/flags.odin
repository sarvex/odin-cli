package cli

import "core:fmt"
import "core:strings"


check_short_flag_name :: proc(name: string) -> Error {
    switch true {
    case len(name) != 2:
        fmt.println(
            red(
                "A short flag name must have a total length of two, and the first charachter must be a dash.",
            ),
        )
    case strings.contains(name, " "):
        fmt.println(red("A flag name cannot contain any whitespaces."))
    case !strings.has_prefix(name, "-"):
        fmt.println(red("A short flag name must start with a single dash."))
    case:
        return .None
    }
    return .Invalid_Flag_Name
}


check_long_flag_name :: proc(name: string) -> Error {
    switch true {
    case name == "":
        fmt.println(red("A long flag name is required."))
    case !strings.has_prefix(name, "--"):
        fmt.println(red("A long flag name must start with two dashes."))
    case len(name) == 2:
        fmt.println(red("A long flag name "))
    case strings.contains(name, " "):
        fmt.println(
            red(
                "A flag name must start with two dashes, if your flag name uses multiple words, replace the spaces with dashes.",
            ),
        )
    case:
        return .None
    }
    return .Invalid_Flag_Name
}


add_flag :: proc(app: ^App, flag: ^Flag) -> Error {
    check_long_flag_name(flag.long) or_return
    check_short_flag_name(flag.short) or_return

    app.flags[flag.long] = flag^
    if flag.required {
        app.required_flags[flag.long] = flag^
    }
    if len(flag.aliases) != 0 {
        for alias in flag.aliases {
            app.aliases.flags[alias] = flag
        }
    }
    return .None
}


remove_flag :: proc {
    remove_flag_by_name,
    remove_flag_by_struct,
}


remove_flag_by_name :: proc(app: ^App, flag: string) -> Error {
    return remove_flag_by_struct(app, app.flags[flag])
}

remove_flag_by_struct :: proc(app: ^App, flag: Flag) -> Error {
    flags := &app.flags
    if flag.long in flags {
        delete_key(flags, flag.long)
        if len(flag.aliases) != 0 {
            for alias in flag.aliases {
                delete_key(&app.aliases.flags, alias)
            }
        }
        return .None
    }
    return .Flag_Not_Found
}
