defmodule CommunicatorClient do
  def start(ip, port) do
    {:ok, socket} = :gen_tcp.connect(ip, port, [:binary, active: false])
    join_server(socket)
  end

  def join_server(socket) do
    IO.puts("Press 1 to see existing chat rooms, press 2 to create a new one")
    option = IO.gets("") |> String.trim()

    case option do
      "1" ->
        :gen_tcp.send(socket, "1\n")
        receive_messages(socket)

      "2" ->
        send_message(socket, "2\n")
        room_name = IO.gets("") |> String.trim()
        join_chatroom(socket, room_name)

      _ ->
        IO.puts("Invalid option")
        join_server(socket)
    end
  end

  def join_chatroom(socket, room_name) do
    IO.puts("Enter your nickname:")
    nickname = IO.gets("") |> String.trim()

    send_message(socket, "JOIN #{room_name} #{nickname}\r\n")

    loop(socket)
  end

  def send_message(socket, message) do
    :gen_tcp.send(socket, message)
  end

  def receive_messages(socket) do
    Task.start_link(fn ->
      loop(socket)
    end)
  end

  defp loop(socket) do
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, message} ->
        IO.puts(message)
        loop(socket)

      {:error, :closed} ->
        IO.puts("Connection closed.")
    end
  end
end
