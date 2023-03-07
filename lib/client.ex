defmodule CommunicatorClient do
  def start(ip, port) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, packet: :line])
    handle_input(socket)
  end

  def handle_input(socket) do
    IO.puts("Enter your nickname:")
    nickname = IO.gets("") |> String.trim()
    IO.puts("Choose a chatroom or create a new one:")
    chatroom = IO.gets("") |> String.trim()

    send_message(socket, "JOIN #{chatroom} #{nickname}")

    spawn(fn -> receive_messages(socket) end)
    handle_output(socket, nickname, chatroom)
  end

  def handle_output(socket, nickname, chatroom) do
    IO.puts("Enter your message or type 'QUIT' to exit:")
    message = IO.gets("") |> String.trim()

    case message do
      "QUIT" ->
        send_message(socket, "QUIT")
        :ok

      _ ->
        send_message(socket, "MSG #{chatroom} #{nickname}: #{message}")
        handle_output(socket, nickname, chatroom)
    end
  end

  def send_message(socket, message) do
    :gen_tcp.send(socket, message <> "\r\n")
  end

  def receive_messages(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, message} ->
        IO.puts(message)
        receive_messages(socket)

      {:error, :closed} ->
        IO.puts("Connection closed.")

      _ ->
        receive_messages(socket)
    end
  end
end
