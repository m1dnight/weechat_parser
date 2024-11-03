defmodule WeechatParserTest do
  use ExUnit.Case, async: true
  alias WeechatParser.Examples

  test "joins" do
    assert Examples.joins() == []
  end

  test "kicks" do
    assert Examples.kicks() == []
  end

  test "leave" do
    assert Examples.leave() == []
  end

  test "nick_change" do
    assert Examples.nick_change() == []
  end

  test "quit" do
    assert Examples.quit() == []
  end

  test "server" do
    assert Examples.server() == []
  end

  test "actions" do
    assert Examples.actions() == []
  end

  test "chat" do
    assert Examples.chat() == []
  end

  test "invalid logfile" do
    assert Examples.invalid_logfile() ==
             {:error, "expected file", "wrong line\n", %{}, {3, 77}, 77}
  end
end
