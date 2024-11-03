defmodule WeechatParser.Examples do
  alias WeechatParser

  require Logger

  def joins() do
    "test/test_logs/split/join.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :join}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def kicks() do
    "test/test_logs/split/kicks.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :kick}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def leave() do
    "test/test_logs/split/leave.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :leave}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def nick_change() do
    "test/test_logs/split/nickchange.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :nick_change}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def quit() do
    "test/test_logs/split/quit.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :quit}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def actions() do
    "test/test_logs/split/actions.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :action}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def chat() do
    "test/test_logs/split/chat.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, [_, %{type: :message}], _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def server() do
    "test/test_logs/split/server.txt"
    |> File.stream!()
    |> Stream.map(&{&1, WeechatParser.parse_line(&1)})
    |> Enum.into([])
    |> Enum.flat_map(fn {line, res} ->
      case res do
        {:ok, _, _, _, _, _} ->
          []

        _ ->
          [{line, res}]
      end
    end)
  end

  def invalid_logfile() do
    """
    2022-02-22 20:28:13	 *	matsaman shrugs
    2022-02-23 19:17:40	 *	Chunkyz shrugs
    wrong line
    """
    |> WeechatParser.parse_log()
  end

  def invalid_logfile_wrapped() do
    """
    2022-02-22 20:28:13	 *	matsaman shrugs
    2022-02-23 19:17:40	 *	Chunkyz shrugs
    wrong line
    """
    |> WeechatParser.try_parse_log()
  end
end
