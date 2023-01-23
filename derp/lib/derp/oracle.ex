defmodule Derp.Oracle do
  use Supervisor
  require Logger

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_init_arg) do
    contract_abi = ExW3.Abi.load_abi("assets/js/Derp-abi.json")
    ExW3.Contract.start_link()
    ExW3.Contract.register(:Derp, abi: contract_abi)
    ExW3.Contract.at(:Derp, Application.fetch_env!(:derp, :contract_address))

    children = [
      Derp.Oracle.ReviewTokenRequest,
      # Derp.Oracle.AllReviewTokenRequest,
      Derp.Oracle.RefreshProductRequest
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defmodule ReviewTokenRequest do
    use Task, restart: :permanent

    def start_link(_arg) do
      {:ok, review_token_req_filter} = ExW3.Contract.filter(:Derp, "ReviewTokenRequested")

      state = [
        filter_id: review_token_req_filter
      ]

      Task.start_link(__MODULE__, :run, [state])
    end

    def run(state) do
      filter_id = state[:filter_id]
      {:ok, changes} = ExW3.Contract.get_filter_changes(filter_id)
      handle_changes(changes)
      :timer.sleep(1000)
      run(state)
    end

    def handle_changes([]) do

    end

    def handle_changes(changes) do
      Logger.info("Got ReviewToken request!\n\t #{inspect(changes)}")
    end
  end

  defmodule AllReviewTokenRequest do
    use Task, restart: :permanent
  end

  defmodule RefreshProductRequest do
    use Task, restart: :permanent

    def start_link(_arg) do
    {:ok, product_req_filter} = ExW3.Contract.filter(:Derp, "ProductRefreshRequested")

      state = [
        filter_id: product_req_filter
      ]

      Task.start_link(__MODULE__, :run, [state])
    end

    def run(state) do
      filter_id = state[:filter_id]
      {:ok, changes} = ExW3.Contract.get_filter_changes(filter_id)
      handle_changes(changes)
      :timer.sleep(1000)
      run(state)
    end

    def handle_changes([]) do

    end

    def handle_changes(changes) do
      Logger.info("Got ProductRefresh request! \n #{inspect(changes)}")
    end
  end
end