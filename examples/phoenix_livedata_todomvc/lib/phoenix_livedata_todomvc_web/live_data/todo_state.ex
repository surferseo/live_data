defmodule PhoenixLivedataTodomvcWeb.LiveData.TodoState do
  use LiveData, endpoint: PhoenixLivedataTodomvcWeb.Endpoint

  def init(_) do
    {:ok,
     %{
       todos: [
         %{id: 0, title: "test", done: false},
         %{id: 1, title: "another test", done: true}
       ]
     }}
  end

  def handle_call({:set_title, %{"id" => id, "title" => title}}, _from, state) do
    new_todos =
      state.todos
      |> Enum.map(fn
        %{id: ^id} = todo -> Map.put(todo, :title, title)
        todo -> todo
      end)

    {:reply, :ok, state |> update_todos(new_todos)}
  end

  def handle_call({:toggle_all, _}, _from, state) do
    all_done = state.todos |> Enum.all?(fn todo -> todo.done end)

    new_todos =
      state.todos
      |> Enum.map(fn
        todo -> Map.put(todo, :done, !all_done)
      end)

    {:reply, :ok, state |> update_todos(new_todos)}
  end

  def handle_call({:add_todo, %{"title" => title}}, _from, state) do
    new_todos = [%{id: state.todos |> length, title: title, done: false} | state.todos]

    {:reply, :ok, state |> update_todos(new_todos)}
  end

  def handle_call({:clear_completed, _}, _from, state) do
    new_todos =
      state.todos
      |> Enum.filter(fn
        %{done: true} -> false
        _ -> true
      end)

    {:reply, :ok, state |> update_todos(new_todos)}
  end

  def handle_call({:toggle_done, id}, _from, state) do
    new_todos =
      state.todos
      |> Enum.map(fn
        %{id: ^id} = todo -> Map.put(todo, :done, !todo.done)
        todo -> todo
      end)

    {:reply, :ok, state |> update_todos(new_todos)}
  end

  defp update_todos(state, todos) do
    new_todos =
      state
      |> Map.put(
        :todos,
        todos
      )

    new_todos
  end
end
