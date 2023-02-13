# Architecture

Using the Firefuel library allows you to get started with Cloud Firestore quickly. Build out your data layer by extending the Repositories and Collections

- Data
  - Repository (data layer business logic)
  - Data Provider (Firebase Collection)

Let's get started!

## Data Layer

> The data layer's responsibility is to retrieve/manipulate data from one or more sources and do something with that data.

The data layer can be split into two parts:

- Repository
- Collection

This layer is the lowest level of the application and interacts with databases, network requests, and other asynchronous data sources.

### Collection

> The collection's responsibility is to provide raw data. The collection should be generic and versatile.

FirefuelRepositories come pre-built with [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations.
By extending the FirefuelCollection you get `create`, `read`, `update`, `delete`, and many other methods.

[collection.dart](_snippets/architecture/collection.dart.md ":include")

### Repository

> The repository layer is a wrapper around one or more collections with which the Firefuel Layer communicates.

[repository.dart](_snippets/architecture/repository.dart.md ":include")

As you can see, our repository layer can interact with multiple collections (or other repositories) and perform transformations on the data before handing the result to the business logic layer of your choosing.

So far, even though we've had some code snippets, all of this has been fairly high level. In the tutorial section we're going to put all this together as we build several different example apps.
