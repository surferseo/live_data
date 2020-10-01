import React from 'react'
import { HashRouter, Route } from 'react-router-dom'
import 'todomvc-app-css/index.css'

import Footer from '../components/Footer'
import TodoList from '../containers/TodoList'

export const SocketContext = React.createContext({ socket: null })

export default function App({ socket }) {
  return (
    <SocketContext.Provider value={{ socket }}>
      <HashRouter>
        <React.Fragment>
          <div className="todoapp">
            <Route
              path="/:filter?"
              render={({
                match: {
                  params: { filter },
                },
              }) => <TodoList filter={filter} />}
            />
          </div>
          <Footer />
        </React.Fragment>
      </HashRouter>
    </SocketContext.Provider>
  )
}
