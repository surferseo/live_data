defmodule LiveData do
  defmacro __using__(opts) do
    quote do
      @endpoint Keyword.get(unquote(opts), :endpoint)

      defmodule Channel do
        use Phoenix.Channel

        def join(name, params, socket) do
          send(self(), {:after_join, name, params})
          {:ok, socket}
        end

        def handle_info({:after_join, name, params}, socket) do
          parent_module =
            __MODULE__
            |> to_string
            |> String.split(".")
            |> Enum.drop(-1)
            |> Enum.join(".")
            |> String.to_atom()

          pid =
            case GenServer.whereis(:"#{parent_module}_#{name}") do
              nil ->
                {:ok, pid} =
                  GenServer.start_link(
                    parent_module,
                    [name, params],
                    name: :"#{parent_module}_#{name}"
                  )

                pid

              pid ->
                send(pid, :init)
                pid
            end

          {:noreply, assign(socket, :pid, pid)}
        end

        def handle_in(method, params, socket) do
          GenServer.call(socket.assigns.pid, {method, params})
          {:noreply, socket}
        end
      end

      use GenServer

      def handle_info(:init, {state, name}) do
        synchronize(%{}, state, name)
        {:noreply, {state, name}}
      end

      def handle_info(msg, {state, name}) do
        {:noreply, new_state} = __react_handle_info__(msg, state)
        synchronize(state, new_state, name)
        {:noreply, {new_state, name}}
      end

      def handle_cast(msg, {state, name}) do
        {:noreply, new_state} = __react_handle_cast__(msg, state)
        synchronize(state, new_state, name)
        {:noreply, {new_state, name}}
      end

      def handle_call(msg, from, {state, name}) do
        {:reply, reply, new_state} = __react_handle_call__(msg, from, state)
        synchronize(state, new_state, name)
        {:reply, reply, {new_state, name}}
      end

      def init([name, init_arg]) do
        {:ok, state} =
          case Keyword.has_key?(__MODULE__.__info__(:functions), :__react_init__) do
            true ->
              __MODULE__.__react_init__(init_arg)

            false ->
              {:ok, init_arg}
          end

        synchronize(%{}, state, name)

        {:ok, {state, name}}
      end

      Module.register_attribute(__MODULE__, :callbacks, accumulate: true)
      @on_definition LiveData
      @before_compile LiveData

      defp synchronize(old_state, new_state, name) do
        diff = JSONDiff.diff(serialize(old_state), serialize(new_state))

        if diff != [] do
          @endpoint.broadcast(name, "diff", %{
            diff: diff
          })
        end
      end
    end
  end

  def __on_definition__(env, kind, :handle_info, args, guards, body) do
    Module.put_attribute(env.module, :callbacks, {kind, :handle_info, args, guards, body})
  end

  def __on_definition__(env, kind, :handle_call, args, guards, body) do
    Module.put_attribute(env.module, :callbacks, {kind, :handle_call, args, guards, body})
  end

  def __on_definition__(env, kind, :handle_cast, args, guards, body) do
    Module.put_attribute(env.module, :callbacks, {kind, :handle_cast, args, guards, body})
  end

  def __on_definition__(env, kind, :init, args, guards, body) do
    Module.put_attribute(env.module, :callbacks, {kind, :init, args, guards, body})
  end

  def __on_definition__(env, kind, _fun, args, guards, body), do: nil

  defmacro __before_compile__(env) do
    handlers =
      Module.get_attribute(env.module, :callbacks)
      |> Enum.map(&wrap_handler/1)

    quote do
      unquote(handlers)
      defp serialize(state), do: state

      def __react_handle_call__(msg, _from, state) do
        proc =
          case Process.info(self(), :registered_name) do
            {_, []} -> self()
            {_, name} -> name
          end

        # We do this to trick Dialyzer to not complain about non-local returns.
        case :erlang.phash2(1, 1) do
          0 ->
            raise "attempted to call GenServer #{inspect(proc)} but no handle_call/3 clause was provided"

          1 ->
            {:stop, {:bad_call, msg}, state}
        end
      end

      def __react_handle_info__(msg, state) do
        proc =
          case Process.info(self(), :registered_name) do
            {_, []} -> self()
            {_, name} -> name
          end

        :logger.error(
          %{
            label: {GenServer, :no_handle_info},
            report: %{
              module: __MODULE__,
              message: msg,
              name: proc
            }
          },
          %{
            domain: [:otp, :elixir],
            error_logger: %{tag: :error_msg},
            report_cb: &GenServer.format_report/1
          }
        )

        {:noreply, state}
      end

      def __react_handle_cast__(msg, state) do
        proc =
          case Process.info(self(), :registered_name) do
            {_, []} -> self()
            {_, name} -> name
          end

        # We do this to trick Dialyzer to not complain about non-local returns.
        case :erlang.phash2(1, 1) do
          0 ->
            raise "attempted to cast GenServer #{inspect(proc)} but no handle_cast/2 clause was provided"

          1 ->
            {:stop, {:bad_cast, msg}, state}
        end
      end
    end
  end

  defp wrap_handler(handler) do
    {k, f, a, g, b} = handler

    a =
      quote do
        unquote(k)(unquote("__react_#{f}__" |> String.to_atom())(unquote_splicing(a)), unquote(b))
      end
  end
end
