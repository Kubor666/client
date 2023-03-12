defmodule CommunicatorClient.Supervisor do

  def start(ip, port) do

    children = [
      {Task.Supervisor, name: Communicator.TaskSupervisor},
      {Task, fn -> CommunicatorClient.start(ip, port) end},
    ]

    opts = [strategy: :one_for_one, name: Communicator.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
