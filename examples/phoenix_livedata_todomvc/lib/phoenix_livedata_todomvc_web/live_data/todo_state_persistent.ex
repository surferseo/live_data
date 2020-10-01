defmodule PhoenixLivedataTodomvcWeb.LiveData.TodoStatePersistent do
  alias PhoenixLivedataTodomvc.{Repo, Todo}
  use LiveData, endpoint: PhoenixLivedataTodomvcWeb.Endpoint
  import Ecto.Query

  def init(_) do
    todos = from(t in Todo, order_by: [desc: :id]) |> Repo.all()

    {:ok, %{todos: todos}}
  end

  def handle_call({"set_title", %{"id" => id, "title" => title}}, _from, state) do
    {:reply, :ok, update_todo(state, id, fn _ -> %{title: title} end)}
  end

  def handle_call({"toggle_all", _}, _from, state) do
    all_done = state.todos |> Enum.all?(fn todo -> todo.done end)

    {_, new_todos} =
      from(t in Todo, select: t, where: t.id in ^todo_ids(state))
      |> Repo.update_all(set: [done: !all_done])

    {:reply, :ok, %{state | todos: new_todos}}
  end

  def handle_call({"add_todo", %{"title" => title}}, _from, state) do
    new_todos = [Repo.insert!(%Todo{title: title, done: false}) | state.todos]

    {:reply, :ok, %{state | todos: new_todos}}
  end

  def handle_call({"clear_completed", _}, _from, state) do
    {_, ids} =
      from(t in Todo, select: t.id, where: t.done == true and t.id in ^todo_ids(state))
      |> Repo.delete_all()

    new_todos = state.todos |> Enum.reject(fn todo -> Enum.member?(ids, todo.id) end)

    {:reply, :ok, %{state | todos: new_todos}}
  end

  def handle_call({"toggle_done", id}, _from, state) do
    {:reply, :ok, update_todo(state, id, fn todo -> %{done: !todo.done} end)}
  end

  defp update_todo(state, id, attrs_callback) do
    new_todos =
      state.todos
      |> Enum.map(fn
        %{id: ^id} = todo -> Repo.update!(Todo.changeset(todo, attrs_callback.(todo)))
        todo -> todo
      end)

    %{state | todos: new_todos}
  end

  defp todo_ids(state) do
    state.todos |> Enum.map(fn todo -> todo.id end)
  end

  defp serialize({:todos, todos}) do
    {:todos,
     Enum.map(todos, fn todo ->
       %{
         title: todo.title,
         id: todo.id,
         done: todo.done
       }
     end)}
  end

  # TODO: figure out why it's not logging exceptions
  defp serialize(state) do
    state |> Enum.map(&serialize/1) |> Enum.into(%{})
  end
end
