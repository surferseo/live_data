import React, { useCallback, useRef, useState } from 'react'
import useOnClickOutside from 'use-onclickoutside'

import useDoubleClick from '../hooks/useDoubleClick'
import useOnEnter from '../hooks/useOnEnter'
import useInput from '../hooks/useInput'

export default function TodoItem({ todo, action }) {
  const onDelete = useCallback(() => action('delete_todo', todo.id), [
    todo.id,
    action,
  ])

  const onDone = useCallback(() => {
    action('toggle_done', todo.id)
  }, [todo.id, action])

  const [editing, setEditing] = useState(false)
  const [newValue, onNewValueChange, setNewValue] = useInput()

  const handleViewClick = useDoubleClick(null, () => {
    setEditing(true)
    setNewValue(todo.title)
  })

  const finishedCallback = useCallback(() => {
    action('set_title', { id: todo.id, title: newValue })
    setEditing(false)
  }, [newValue, todo.id, action])

  const onEnter = useOnEnter(finishedCallback, [newValue, todo.id])
  const ref = useRef()
  useOnClickOutside(ref, finishedCallback)

  return (
    <li
      onClick={handleViewClick}
      className={`${editing ? 'editing' : ''} ${todo.done ? 'completed' : ''}`}
    >
      <div className="view">
        <input
          type="checkbox"
          className="toggle"
          checked={todo.done}
          onChange={onDone}
        />
        <label>{todo.title}</label>
        <button className="destroy" onClick={onDelete} />
      </div>
      {editing && (
        <input
          ref={ref}
          className="edit"
          value={newValue}
          onChange={onNewValueChange}
          onKeyPress={onEnter}
          autoFocus
        />
      )}
    </li>
  )
}
