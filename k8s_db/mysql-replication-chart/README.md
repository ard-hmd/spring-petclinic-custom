# MySQL Replicated StatefulSet Chart

This Helm chart deploys a MySQL Replicated StatefulSet in a Kubernetes cluster, along with backup and replication features using XtraBackup.

## Installation

To install the MySQL StatefulSet chart, use the following Helm command:

```bash
helm install my-mysql ./path-to-chart-directory
```
 
  > **Note:**  Replace `my-mysql` with the desired release name and `./path-to-chart-directory` with the path to the directory containing the chart.

## Configuration

The following configuration options are available in the `values.yaml` file:

- `mysql.image`: The MySQL Docker image to use.
- `mysql.replicaCount`: Number of MySQL replicas to deploy.
- `mysql.storageSize`: Storage size for each replica.
- `mysql.envVars`: List of environment variables for the MySQL container.
- `xtrabackup.image`: The XtraBackup Docker image to use.

For more details, refer to the [values.yaml](./values.yaml) file.

## Usage Examples

1. To install the MySQL StatefulSet with default values:

```bash
helm install my-mysql ./path-to-chart-directory
```

2. To customize the MySQL replica count:

```bash
helm install my-mysql ./path-to-chart-directory --set mysql.replicaCount=3
```

## Notes

- This chart assumes a Kubernetes environment with persistent storage support.
- XtraBackup is used for backup and replication tasks.
- The init and clone containers handle MySQL setup and data cloning.
- For advanced configurations, consult the MySQL documentation and Helm Chart documentation.

## Author

Created by ard-hmd.
