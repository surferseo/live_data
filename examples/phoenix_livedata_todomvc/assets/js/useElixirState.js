import React, {
  useEffect,
  useState,
  useCallback,
  useMemo,
  useContext,
} from 'react'
import { Socket } from 'phoenix'
import { v4 as uuidv4 } from 'uuid'
import { SocketContext } from './App/App'
const { applyPatch } = require('fast-json-patch')

export const useSocket = () => {
  let [socket, setSocket] = useState(null)

  useEffect(() => {
    let socket = new Socket('/react_gen_server')
    socket.connect()
    setSocket(socket)
  }, [])

  return socket
}

export const useElixirState = (
  component,
  defaultState = null,
  id = uuidv4(),
  params = {}
) => {
  const { socket } = useContext(SocketContext)
  const [channel, setChannel] = useState(null)
  const [state, setState] = useState(defaultState)

  useEffect(() => {
    let channel
    if (socket) {
      channel = socket.channel(`${component}:${id}`, params)
      channel.join()
      setChannel(channel)
    }

    return () => {
      channel && channel.leave()
    }
  }, [socket, JSON.stringify(params)])

  const handleStateDiff = useCallback(
    ({ diff }) => {
      const doc = applyPatch({ ...state }, diff, false, false)

      setState(doc.newDocument)
    },
    [state, channel]
  )

  useEffect(() => {
    let ref = channel ? channel.on('diff', handleStateDiff) : null

    return () => {
      channel && ref && channel.off('diff', ref)
    }
  }, [channel, handleStateDiff])

  return [
    state,
    (msg, params) => {
      channel.push(msg, params)
    },
  ]
}
