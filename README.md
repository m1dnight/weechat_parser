# WeechatParser

A parser for Weechat log files. 

To parse a file, simply run the following.

```elixir 
File.read!("test/test_logs/irc.libera.\#elixir.weechatlog") 
|> WeechatParser.try_parse_log
```

The result is a list of maps containing the messages. 

```elixir
{:ok,
 [
   ~N[2022-02-21 16:18:04],
   %{
     type: :join,
     host: "~zorro@1-1-1-1.foo.bar.be",
     nick: "m1dnight",
     channel: "elixir"
   },
   ~N[2022-03-03 11:57:54],
   %{
     message: "Does anyone have some pointers to manually writing an erlang history file?",
     type: :message,
     from: "m1dnight"
   }
 ]}
```

To pars

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `weechat_parser` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:weechat_parser, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/weechat_parser>.

