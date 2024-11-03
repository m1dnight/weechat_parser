defmodule WeechatParser do
  import NimbleParsec
  require Logger
  ##############################################################################
  #                           Helpers                                          #
  ##############################################################################

  defcombinator :ignore_tab, ignore(ascii_char([?\t])) |> label("ignore_tab")
  defcombinator :ignore_space, ignore(ascii_char([?\s])) |> label("ignore_space")
  defcombinator :ignore_newline, ignore(ascii_char([?\n])) |> label("ignore_newline")

  defcombinator :string_in_parens,
                ignore(string("("))
                |> repeat(utf8_string([{:not, ?\)}], min: 1))
                |> ignore(string(")"))
                |> label("string_in_parens")

  defcombinator :channel,
                ignore(string("#"))
                |> repeat(utf8_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?\#, ?-, ?\.], min: 1))

  # ----------------------------------------------------------------------------
  # Date

  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> optional(string("Z"))

  defp reduce_date([year, month, day, hour, minute, second]) do
    %NaiveDateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: second}
  end

  defcombinator :datetime,
                date |> parsec(:ignore_space) |> concat(time) |> reduce(:reduce_date)

  # ----------------------------------------------------------------------------
  # Separator

  defcombinator :separator, choice([string("--"), string("=!=")]) |> replace(:separator)
  defcombinator :outgoing, string("<--") |> replace(:outgoing)
  defcombinator :incoming, string("-->") |> replace(:incoming)

  # ----------------------------------------------------------------------------
  # Nick

  nickname =
    utf8_string(
      [
        ?a..?z,
        ?A..?Z,
        ?0..?9,
        ?_,
        ?-,
        ?`,
        ?^,
        ?|,
        ?{,
        ?},
        ?\[,
        ?\],
        ?\\,
        ?*,
        ?\.,
        ?\@,
        ?+,
        ?!,
        ?&,
        ?%,
        ?~
      ],
      min: 1
    )

  ##############################################################################
  #                           Parsers                                          #
  ##############################################################################

  # ----------------------------------------------------------------------------
  # Incoming

  defp reduce_incoming([:incoming, {:join, [nick, host, channel]}]) do
    %{type: :join, nick: nick, host: host, channel: channel}
  end

  defp reduce_incoming([:incoming, {:back_on_server, [nick, host]}]) do
    %{type: :back_on_server, nick: nick, host: host}
  end

  defp reduce_incoming(x), do: x

  defcombinator :join,
                nickname
                |> parsec(:ignore_space)
                |> parsec(:string_in_parens)
                |> ignore(string(" has joined "))
                |> parsec(:channel)
                |> tag(:join)

  defcombinator :back_on_server,
                nickname
                |> parsec(:ignore_space)
                |> parsec(:string_in_parens)
                |> ignore(string(" is back on server"))
                |> tag(:back_on_server)

  defcombinator :incoming_line,
                parsec(:incoming)
                |> parsec(:ignore_tab)
                |> choice([
                  parsec(:join),
                  parsec(:back_on_server),
                  utf8_string([{:not, ?\n}], min: 1)
                ])
                |> reduce(:reduce_incoming)
                |> label("incoming")

  # ----------------------------------------------------------------------------
  # Outgoing

  defp reduce_outgoing([:outgoing, {:kick, [nick, kicked, reason]}]) do
    %{type: :kick, nick: nick, kicked: kicked, reason: reason}
  end

  defp reduce_outgoing([:outgoing, {:leave, [nick, hostname, channel, reason]}]) do
    %{type: :leave, nick: nick, hostname: hostname, channel: channel, reason: reason}
  end

  defp reduce_outgoing([:outgoing, {:quit, [nick, hostname | reason]}]) do
    if reason == [] do
      %{type: :quit, nick: nick, hostname: hostname, reason: ""}
    else
      %{type: :quit, nick: nick, hostname: hostname, reason: reason}
    end
  end

  defp reduce_outgoing(args) do
    IO.inspect(args)
    %{type: :outgoing, message: args}
  end

  defcombinator :kick,
                nickname
                |> ignore(string(" has kicked "))
                |> concat(nickname)
                |> parsec(:ignore_space)
                |> utf8_string([{:not, ?\n}], min: 1)
                |> tag(:kick)

  defcombinator :leave,
                nickname
                |> parsec(:ignore_space)
                |> parsec(:string_in_parens)
                |> ignore(string(" has left "))
                |> parsec(:channel)
                |> utf8_string([{:not, ?\n}], min: 0)
                |> tag(:leave)

  defcombinator :quit,
                nickname
                |> parsec(:ignore_space)
                |> parsec(:string_in_parens)
                |> ignore(string(" has quit"))
                |> optional(parsec(:ignore_space) |> utf8_string([{:not, ?\n}], min: 1))
                |> tag(:quit)

  defcombinator :outgoing_line,
                parsec(:outgoing)
                |> parsec(:ignore_tab)
                |> choice([
                  parsec(:kick),
                  parsec(:leave),
                  parsec(:quit),
                  utf8_string([{:not, ?\n}], min: 1)
                ])
                |> reduce(:reduce_outgoing)
                |> label("outgoing_line")

  # ----------------------------------------------------------------------------
  # Server

  defp reduce_server([:separator, {:nick_change, [nick, new_nick]}]) do
    %{type: :nick_change, nick: nick, new_nick: new_nick}
  end

  defp reduce_server([:separator, message]) do
    %{type: :server, message: message}
  end

  defcombinator :nick_change,
                nickname
                |> ignore(string(" is now known as "))
                |> concat(nickname)
                |> tag(:nick_change)

  defcombinator :server_line,
                parsec(:separator)
                |> parsec(:ignore_tab)
                |> choice([parsec(:nick_change), utf8_string([{:not, ?\n}], min: 1)])
                |> reduce(:reduce_server)
                |> label("server_line")

  # ----------------------------------------------------------------------------
  # Message

  defp reduce_message([{:message, [nick, message]}]) do
    %{type: :message, from: nick, message: message}
  end

  defp reduce_message(args), do: IO.inspect(args)

  defcombinator :message_line,
                nickname
                |> parsec(:ignore_tab)
                |> utf8_string([{:not, ?\n}], min: 0)
                |> tag(:message)
                |> reduce(:reduce_message)
                |> label("server_line")

  # ----------------------------------------------------------------------------
  # Action

  defp reduce_action([nick, action]) do
    %{type: :action, nick: nick, action: action}
  end

  defcombinator :action_line,
                parsec(:ignore_space)
                |> ignore(ascii_char([?*]))
                |> parsec(:ignore_tab)
                |> concat(nickname)
                |> parsec(:ignore_space)
                |> utf8_string([{:not, ?\n}], min: 0)
                |> reduce(:reduce_action)
                |> label("action_line")

  # ----------------------------------------------------------------------------

  defparsec :log_entry,
            parsec(:datetime)
            |> parsec(:ignore_tab)
            |> choice([
              parsec(:incoming_line),
              parsec(:outgoing_line),
              parsec(:server_line),
              parsec(:message_line),
              parsec(:action_line)
            ])
            |> parsec(:ignore_newline)
            |> label("log_entry")

  defparsec :parse_file,
            repeat(parsec(:log_entry))
            |> eos()
            |> label("file")

  ##############################################################################
  #                           Helpers                                          #
  ##############################################################################

  defp unwrap({:ok, lines, "", _, _, _}), do: {:ok, lines}
  defp unwrap({:ok, [], "", _, _, _}), do: {:ignored, "empty input"}
  defp unwrap({:ok, _, rest, _, _, _}), do: {:error, "could not parse ruleset" <> rest}

  defp unwrap({:error, reason, rest, _, {line, char}, _}),
    do: {:error, :failed, line: line, char: char}

  ##############################################################################
  #                           API                                              #
  ##############################################################################

  @doc """
  I parse a single line of a weechat log.
  """
  def parse_line(log) do
    log_entry(log)
  end

  @doc """
  I try and parse a line and return pretty errors.
  """
  def try_parse_line(log) do
    log_entry(log)
    |> unwrap()
  end

  @doc """
  I try and parse an entire log file in string format.
  """
  def parse_log(log) do
    parse_file(log)
  end

  @doc """
  I try and parse an entire log file in string format and return pretty errors.
  """
  def try_parse_log(log) do
    parse_file(log)
    |> unwrap()
  end
end
