assert = require 'assert'
fs = require 'fs'
path = require 'path'
parseContributors = require '..'
ora = require 'ora'

spinner1 = ora('Reading test files').start()
files = fs
  .readdirSync(path.join(process.cwd(), 'test'))
  .filter((file) -> file isnt 'index.js')
  .reduce(((acc, file) ->
    if file.startsWith 'raw'
      if acc.find((file2) -> file2.parsed and file2.parsed.slice(11, -5) is file.slice(3, -4))
        acc.find((file2) -> file2.parsed and file2.parsed.slice(11, -5) is file.slice(3, -4)).raw = path.join 'test', file
      else
        acc.push { raw: path.join('test', file) }
    else if file.startsWith 'parsed'
      if acc.find((file2) -> file2.raw and file2.raw.slice(8, -4) is file.slice(6, -5))
        acc.find((file2) -> file2.raw and file2.raw.slice(8, -4) is file.slice(6, -5)).parsed = path.join 'test', file
      else
        acc.push { parsed: path.join('test', file) }
    return acc
  ), [])

try
  assert.strictEqual(
    files.every((file) -> file.parsed and file.raw),
    true
  )
catch e
  indexOfFile = undefined
  if (
    files.find (file, index) ->
      indexOfFile = index
      return !file.parsed
  )
    spinner1.fail 'Unmatched parsed file for ' + (indexOfFile + 1) + 'th raw file'
  else if (
    files.find (file, index) ->
      indexOfFile = index
      return !file.raw
  )
    spinner1.fail 'Unmatched raw file for ' + (indexOfFile + 1) + 'th parsed file'
  else if (
    !files.every (file) ->
      sortedKeys = Object.keys(file).sort()
      return sortedKeys[0] is 'parsed' and sortedKeys[1] is 'raw'
  )
    spinner1.fail 'Error reading test files'
  console.log()
  throw e

spinner1.succeed()

spinner2 = ora('Running tests').start()

files.forEach (file, testNum) ->
  try
    assert.deepStrictEqual(parseContributors(fs.readFileSync(file.raw, 'utf8')), JSON.parse fs.readFileSync(file.parsed, 'utf8'))
  catch e
    spinner2.fail 'Failed test number ' + (testNum + 1)
    console.log()
    throw e

spinner2.succeed()
