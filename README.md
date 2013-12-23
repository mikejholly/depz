A nice little tool for when you forget to `npm install --save`. It inspects your `node_modules` directory, pulls out module names and versions and either merges them into your package.json or replaces them outright.

## Usage

  Resets package.json dependencies using a pretty interactive process.

  Usage: packager [options]

  Options:
    -c, --clear     Wipe all dependencies and devDependencies (start from scratch).  [default: 1]
    -m, --modifier  Which npm version prefix to add.                                 [default: "~"]
    -y, --yes       Assumes you want to add all node_modules to package.json.

## Example

  Which do you want to include in your package.json? Type y, n or dev (to add to devDependencies). Type explicit version number to override.

  prompt: async [0.2.9]:  (y)
  prompt: colors [0.6.2]:  (y)
  prompt: glob [3.2.7]:  (y)
  prompt: optimist [0.6.0]:  (y)
  prompt: prompt [0.2.12]:  (y)
  prompt: underscore [1.5.2]:  (y)

  Writing out new package.json.

