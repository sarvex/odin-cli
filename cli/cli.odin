package cli

import "core:os"
import "core:fmt"


add_help :: proc(app: ^App) {
    _, exists := app.commands["help"]
    if !exists && !app.disable_help {
        add(
            app,
            &Command{
                name = "help",
                help = "Shows this message.",
                args = 0,
                action = show_help,
            },
        )
    }
}


find_command :: proc(app: App, command_name: string) -> Error {
    if command_name in app.commands {
        return .None
    }
    fmt.printf(red("Unknown command: %s.\n"), command_name)
    return .Command_Not_Found
}

validate_args :: proc(command: Command, args: []string) -> Error {
    if command.args == nil {
        return .None
    } else if command.args == len(args) {
        return .None
    }
    fmt.printf(
        red("Command '%s' expected %i arguments, got %i instead.\n"),
        command.name,
        command.args,
        len(args),
    )
    return .Invalid_Amount_Args
}

run :: proc(app: ^App) -> Error {
    add_help(app) // adds a help a command if it does not exist or is disabled

    args := os.args
    if len(args) == 1 {
        help, exists := app.commands["help"]
        if !exists {
            return .Help_Command_Not_Found
        }
        help.action(app^, args)
        return .None
    }

    command_name := args[1]
    command := app.commands[command_name]

    find_command(app^, command_name) or_return
    validate_args(command, args[2:]) or_return

    if command.action != nil {
        command.action(app^, args)
    } else {
        app->action(args)
    }
    return .None
}
