parseContributors = (value) ->
  if value is ''
    return []
  value
    .split '\n'
    .map(
      (line, lineNumber) ->
        if line is ''
          return
            type: 'newline',
            raw: '',
            value: ''
        else if line.startsWith '#'
          return
            type: 'comment',
            raw: line,
            value: line.slice(1)
        else if line.charAt(line.length - 1) is '>' and line.includes '<'
          return
            type: 'contributor'
            raw: line
            value:
              name: line.split(' <')[0],
              email: line.split(' <')[1].slice(0, -1)
        else
          throw new Error('Invalid line ' + (lineNumber + 1))
    )

if typeof module isnt 'undefined'
  module.exports = parseContributors
