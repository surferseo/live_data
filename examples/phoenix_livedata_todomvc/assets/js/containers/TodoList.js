import React, { useCallback, useMemo } from 'react'
import { NavLink } from 'react-router-dom'
import useRouter from 'use-react-router'

import useInput from '../hooks/useInput'
import useOnEnter from '../hooks/useOnEnter'
import TodoItem from './TodoItem'
import { useElixirState } from '../useElixirState'
import { guid } from '../utils'

let CLIENT_ID

if (localStorage.getItem('client_id')) {
  CLIENT_ID = localStorage.getItem('client_id')
} else {
  CLIENT_ID = guid()
  localStorage.setItem('client_id', CLIENT_ID)
}
console.log(CLIENT_ID)

export default function TodoList({ socket, filter }) {
  const [{ todos }, action] = useElixirState(
    'TodoList',
    { todos: [] },
    CLIENT_ID
  )
  // const [todos, action] = [[{ id: 0, title: 'test' }], () => {}]

  const left = useMemo(() => todos.reduce((p, c) => p + (c.done ? 0 : 1), 0), [
    todos,
  ])

  const visibleTodos = useMemo(
    () =>
      filter
        ? todos.filter((i) => (filter === 'active' ? !i.done : i.done))
        : todos,
    [todos, filter]
  )

  const anyDone = useMemo(() => todos.some((i) => i.done), [todos])
  const allSelected = useMemo(() => visibleTodos.every((i) => i.done), [
    visibleTodos,
  ])

  const onToggleAll = useCallback(() => {
    action('toggle_all')
  }, [action])

  const onClearCompleted = useCallback(() => {
    action('clear_completed')
  }, [action])

  const [newValue, onNewValueChange, setNewValue] = useInput()
  const onAddTodo = useOnEnter(
    (e) => {
      if (newValue) {
        action('add_todo', { title: newValue })
        setNewValue('')
      }
    },
    [newValue]
  )

  return (
    <React.Fragment>
      <header className="header">
        <h1>todos</h1>
        <input
          className="new-todo"
          placeholder="What needs to be done?"
          onKeyPress={onAddTodo}
          value={newValue}
          onChange={onNewValueChange}
          autoFocus
        />
      </header>

      <section className="main">
        <input
          id="toggle-all"
          type="checkbox"
          className="toggle-all"
          checked={allSelected}
          onChange={onToggleAll}
        />
        <label htmlFor="toggle-all" />
        <ul className="todo-list">
          {visibleTodos.map((todo) => (
            <TodoItem key={todo.id} todo={todo} action={action} />
          ))}
        </ul>
      </section>

      <footer className="footer">
        <span className="todo-count">
          <strong>{left}</strong> items left
        </span>
        <ul className="filters">
          <li>
            <NavLink exact={true} to="/" activeClassName="selected">
              All
            </NavLink>
          </li>
          <li>
            <NavLink to="/active" activeClassName="selected">
              Active
            </NavLink>
          </li>
          <li>
            <NavLink to="/completed" activeClassName="selected">
              Completed
            </NavLink>
          </li>
        </ul>
        {anyDone && (
          <button className="clear-completed" onClick={onClearCompleted}>
            Clear completed
          </button>
        )}
      </footer>
    </React.Fragment>
  )
}
