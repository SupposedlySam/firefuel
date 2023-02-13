# Code Generation

[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)

To use `firefuel` you need to manually create a model and a collection at a minimum. Optionally, you can also create a repository to contain your data layer business logic (such as local and remote persistance through one `store` method).

Although it's fairly easy to do this, it gets annoying to copy/paste from another one when you need to add a new collection.

To ease this pain, we've created a brick for `firefuel`!

## What is Mason

Mason allows developers to create and consume reusable templates called "bricks" powered by the mason generator.

The `firefuel` brick creates a Collection, Model Stub and optional Repository.

For more information on Collections and Repositories, review the [Core Concepts](./coreconcepts.md)

## Using the Firefuel Brick

To install the `firefuel` brick, run `mason add firefuel`.

Afterwards, run `mason get` and `mason make firefuel` in the directory you'd like your FirefuelCollection and Model generated.

For more information, see the brick's [README](https://github.com/SupposedlySam/firefuel/blob/main/packages/firefuel/bricks/firefuel/README.md)
