# Zeppelin

A `debian:jessie` based Spark and [Zeppelin](http://zeppelin.apache.org) Docker container.

This image contains:

- [Spark 2.2.0](http://spark.apache.org/docs/2.2.0) and [Hadoop 2.7.3](http://hadoop.apache.org/docs/r2.7.3)
- [PySpark](http://spark.apache.org/docs/2.2.0/api/python) support with [Python 3.4](https://docs.python.org/3.4), [NumPy](http://www.numpy.org), and [PandaSQL](https://github.com/yhat/pandasql), but no scipy or matplotlib.
- A partial list of interpreters out-of-the-box: 
  - spark
  - shell
  - angular
  - markdown
  - postgresql
  - jdbc
  - python
  - hbase
  - elasticsearch
If your favorite interpreter isn't included, consider [adding it with the api](http://zeppelin.apache.org/docs/0.7.3/manual/dynamicinterpreterload.html). 
## Simple Usage

To start Zeppelin with no configuration run the container:

```
docker run --rm -p 8080:8080 ssalaues/zeppelin
```

Zeppelin runs at `http://${YOUR_DOCKER_HOST}:8080`and cleans up the container on exit 

## Complex Usage

### build

To build an image with custom JVM memory constraints, use the following command with your custom values.
You can set the maximum memory along with maximum persistent memory with the commands below.
(Default values are: MEM=2gb and MAX_PERM_SIZE=1024m)
```
docker build -t ssalaues/zeppelin --build-arg MEM=16g --build-arg MAX_PERM_SIZE=8g .
```
#### NOTE: Because of Spark memory constraints, allow for the entire data set to be stored in memory for optimal performance.

### run

The container can be run with arguments that limit the amount of resources it can access. Adjust this tunable resource to conform to anticipated performance needs (Default values allow containers to use as many CPU resources as are available on the system).
```
 docker run --cpus=4 -v "$(pwd)"/examples/notebooks:/usr/zeppelin/notebook -p 8080:8080 ssalaues/zeppelin
```
#### NOTE: This command also creates a bind mount to the container's default notebook directory for persistent notebook storage.

## Demo Using sql Commands on Spark
A pre-loaded "Demo" notebook (along with accessKey and secretKey values) enables connection to an S3-compatible endpoint. This basic demo uses this [Yelp dataset](https://github.com/shaivikochar/Yelp-Dataset-Analysis/blob/master/zeppelin.md) as an example and has very simple code to load all JSON files in bucket ```foo```, process it, and put it into a SQL table for search.

#### NOTE: Spark expects each line to be a separate JSON object. It fails if you load "pretty" formatted JSON files

```
import scala.collection.mutable.WrappedArray
import spark.implicits._
import org.apache.spark.sql.functions._

//Set the endpoint
sc.hadoopConfiguration.set("fs.s3a.endpoint", "http://endpoint:port");
// Allow S3 to be an accessible file system
sc.hadoopConfiguration.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem");
// Access key and Secret key values
sc.hadoopConfiguration.set("fs.s3a.access.key", "accessKey1");
sc.hadoopConfiguration.set("fs.s3a.secret.key", "verySecretKey1");

// Load all json files (regex supported)
val allFiles = sc.textFile("s3a://foo/*.json");
val business = spark.read.json(allFiles);
 
val b = business.withColumn("category", explode(
    when(col("categories").isNotNull, col("categories"))
    .otherwise(array(lit(null).cast("string")))
    ))
    
b.registerTempTable("business")

```

Running a SQL query on the data loaded in the example above requires a new paragraph in Zeppelin. For example, the following query outputs the data parsed in a visualization:

```
%sql SELECT  category,city,avg(stars) as avg_stars from business  group by category,city order by category asc, avg_stars desc
```
![chart](https://github.com/ssalaues/docker-zeppelin/blob/master/examples/chart.png?raw=true)
Suggested reading for advanced JSON processing in Spark:
http://blog.antlypls.com/blog/2016/01/30/processing-json-data-with-sparksql/
