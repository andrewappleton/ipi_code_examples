# CX as CODE EXAMPLES

## CSV-TO-QUEUE
Example showing how to use a CSV file to manage properties of a relatively "flat" resource
Also includes methods to manage simple nested properties

## JSON-TO-QUEUE
This example is very similar to the CSV-TO-QUEUE example, but opens up methods to handle more complex structure. 
It intentionally keeps it simple to focus on the possibilities this method offers.

## CLI-INTEGRATION
This example shows how to manage existing resources through the use of the `import()` command, and also shows advanced use of `external data` functionality within HCL to integrate the [Genesys Cloud Platform API CLI](https://developer.genesys.cloud/devapps/cli/)

The example uses the CLI to perform a lookup of existing queues and their IDs in the Cloud Org, then processes all the queues to update the `acw_timeout_ms` property to a set value.