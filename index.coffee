puts     = console.log
glob     = require "glob"
colors   = require "colors"
fs       = require "fs"
prompt   = require "prompt"
async    = require "async"
_        = require "underscore"
optimist = require "optimist"

usage = """

Resets package.json dependencies using a pretty interactive process.

Usage: packager [options]
"""

argv = optimist
  .usage(usage)
  .default("m", "~")
  .default("c", 1)
  .alias("c", "clear")
  .alias("m", "modifier")
  .alias("y", "yes")
  .alias("h", "help")
  .describe("c", "Wipe all dependencies and devDependencies (start from scratch).")
  .describe("m", "Which npm version prefix to add.")
  .describe("y", "Assumes you want to add all node_modules to package.json.")
  .boolean("c")
  .argv

if argv.h
  optimist.showHelp()
  process.exit 0

# Bust if no node_modules
if not fs.existsSync "node_modules"
  puts "No node_modules directory found!".red
  process.exit 1

# Bust if no package.json
if not fs.existsSync "package.json"
  puts "No package.json file found! Please create one first.".red
  process.exit 1

prompt.start()

# Read existing package.json
data = fs.readFileSync "package.json", "utf-8"
_package = JSON.parse data

# Blank out existing depen
if argv.clear
  _package.dependencies    = {}
  _package.devDependencies = {}

# Load all node_modules and their package.json's
glob "node_modules/*/package.json", (err, files) ->

  prompts = []
  modules = {}

  # Load all JSON and construct prompt schema
  for file in files
    data = fs.readFileSync file, "utf-8"
    json = JSON.parse data
    modules[json.name] = json
    prompts.push
      name: json.name
      description: "#{json.name} [#{json.version}]"
      default: "y"
      required: true

  # Write out new package.json with amended dependencies
  write = (input, fn) ->
    orig = _package.dependencies

    for name, s of input
      if /^git/.exec orig[name]
        _package.dependencies[name] = orig[name]
      else if s is "dev"
        _package.devDependencies[name] = argv.modifier + modules[name].version
      else if s is "y"
        _package.dependencies[name] = argv.modifier + modules[name].version
      else
        _package.dependencies[name] = s

    puts "\nWriting out new package.json.".green

    fs.writeFile "package.json", JSON.stringify(_package, null, 2), fn

  # Default to y's for everything
  if argv.yes
    keys  = Object.keys modules
    input = _.object keys, ("y" for i in [0...keys.length])
    write input, (err) -> process.exit 0 unless err
  else

    puts """

    Which do you want to include in your package.json? Type y, n or dev (to add to devDependencies). Type explicit version number to override.

    """

    # Prompt for input
    prompt.get prompts, (err, input) ->
      if err
        puts "\n\nPrompt interrupted. Doing nothing.".yellow
        process.exit 1
      write input, (err) -> process.exit 0 unless err

