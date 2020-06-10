# appfamily-template

## Description

An AppFamily Template which you can derive from to define deployable Rancher project sets in Octopus Deploy.

On each run, a snapshot of the Dev state of these stacks will be performed, and the resulting docker/rancher .YMLs will be zipped up into a release package, which is then deployable from Octopus.

## Instructions
### 1. Define your AppFamily JSON

[The AppFamily JSON is defined here.](apps.json)

Simply add the stack names from the environment that you want to include in your package. 

(It is valid to have only one stack, and/or only one of backend/frontend.)

(OPTIONAL: For advanced users only. You can control how ENVKEY vars are mapped to your services using the example provided in [this file](apps-with-customEnvkeyMappings.json). Be sure to rename it to apps.json.)

### 2. Define your Jenkinsfile Webhooks

[The Jenkinsfile is defined here.](Jenkinsfile)

Add valid Teams webhooks for Success and Failure webhook variables.

### 3. Run the master build in Jenkins

Run the 'master' build for your AppFamily in Jenkins to generate a releasable snapshot.

### That's it.

Now you can deploy this AppFamily as a project from the Cardano Github feed in Octopus Deploy.
