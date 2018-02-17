# zeppelin

A `debian:jessie` based Spark and [Zeppelin](http://zeppelin.apache.org) Docker container.

This image is large and opinionated. It contains:

- [Spark 2.2.0](http://spark.apache.org/docs/2.2.0) and [Hadoop 2.7.3](http://hadoop.apache.org/docs/r2.7.3)
- [PySpark](http://spark.apache.org/docs/2.2.0/api/python) support with [Python 3.4](https://docs.python.org/3.4), [NumPy](http://www.numpy.org), [PandaSQL](https://github.com/yhat/pandasql), and [SciPy](https://www.scipy.org/scipylib/index.html), but no matplotlib.
- A partial list of interpreters out-of-the-box. If your favorite interpreter isn't included, consider [adding it with the api](http://zeppelin.apache.org/docs/0.7.3/manual/dynamicinterpreterload.html).
  - spark
  - shell
  - angular
  - markdown
  - postgresql
  - jdbc
  - python
  - hbase
  - elasticsearch

## simple usage

To start Zeppelin with no configuration simply run the container:

```
docker run --rm -p 8080:8080 ssalaues/zeppelin
```

Zeppelin will be running at `http://${YOUR_DOCKER_HOST}:8080`and will clean up the container upon exit 

## complex usage

### build

If you want to build an image with custom JVM memory constraints use the following command with your custom values.
You can set the max memory usage along with max persistant usage with the below respective commands.
(Defaults if not specified, MEM=2gb and MAX_PERM_SIZE=1024m)
```
docker build -t ssalaues/zeppelin --build-arg MEM=16g --build-arg MAX_PERM_SIZE=8g .
```

### run

The container can be ran with arguments to limit the amount of resources the container has access to.
(defaults allow for containers to use as much cpu resources as available on the system)
```
 docker run --cpus=8 -v "$(pwd)"/notebooks:/usr/zeppelin/notebook -p 8080:8080 ssalaues/zeppelin
```
#### NOTE: that the above command also has a bind mount to the containers default notebook directory for data retention

