import { createServer } from 'http'                    // from @frankdugan3, an example of TypeScript code
                                                      
export const server = createServer((req, res) => {     // that was misidentified as Qt Linguist in cloc
  res.writeHead(200, { 'Content-type': 'text/plain' }) // versions before 1.78
  res.write('Hello world!')
  res.end()
}).listen(8080)
