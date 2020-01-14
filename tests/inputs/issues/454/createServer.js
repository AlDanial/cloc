function createServer () {
  server.use(bodyParser.text({ type: '*/*' }))

  server.post('/:queueId', async function (request, response) {
    response.status(200).end()
  })

  server.get('/:queueId', async function (request, response) {
    const message = state
    response.status(200).send(message).end()
  })

  return server
}
