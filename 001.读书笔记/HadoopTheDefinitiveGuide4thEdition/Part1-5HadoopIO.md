# Hadoop I/O

Hadoop comes with a set of primitives for data I/O. Some of these are techniques that are more general than Hadoop, such as `data integrity` and `compression`, but deserve special consideration when dealing with multiterabyte datasets. Others are Hadoop tools or APIs that form the building blocks for developing distributed systems, such as `serialization frameworks` and on-disk data structures.

## Data Integrity / 数据完整

A commonly used error-detecting code is CRC-32 (32-bit cyclic redundancy check), which computes a 32-bit integer checksum for input of any size. CRC-32 is used for checksumming in Hadoop’s `ChecksumFileSystem`, while HDFS uses a more efficient variant called `CRC-32C`.

- Data Integrity in HDFS

HDFS transparently checksums all data written to it and by default verifies checksums when reading data. A separate checksum is created for every `dfs.bytes-per-checksum` bytes of data. The default is `512 bytes`, and because a CRC-32C checksum is 4 bytes long, the storage overhead is less than 1%./HDFS自动进行checksum工作,默认每512MB一次check.

`Datanodes are responsible for verifying` the data they receive before storing the data and its checksum. This applies to data that they receive from clients and from other datanodes during replication. A client writing data sends it to a pipeline of datanodes (as explained in Chapter 3), and the last datanode in the pipeline verifies the checksum. If the datanode detects an error, the client receives `a subclass of IOException`, which it should handle in an application-specific manner (for example, by retrying the operation).

When clients read data from datanodes, they verify checksums as well, comparing them with the ones stored at the datanodes. Each datanode keeps a persistent log of checksum verifications, so it knows the last time each of its blocks was verified. When a client successfully verifies a block, it tells the datanode, which updates its log. Keeping statistics such as these is valuable in detecting bad disks.

In addition to block verification on client reads, each datanode runs a `DataBlockScanner` in a background thread that periodically verifies all the blocks stored on the datanode. This is to guard against corruption due to “`bit rot`” in the physical storage media. See Datanode block scanner for details on how to access the scanner reports.\
每个DataNode还后台运行一个DataBlockScanner来周期性的检查是否存在"bit rot"

Because HDFS stores replicas of blocks, it can “heal” corrupted blocks by copying one of the good replicas to produce a new, uncorrupt replica. The way this works is that `if a client detects an error when reading a block, it reports the bad block and the datanode it was trying to read from to the namenode before throwing a ChecksumException`. `The namenode marks the block replica as corrupt so it doesn’t direct any more clients to it or try to copy this replica to another datanode`. It then schedules a copy of the block to be replicated on another datanode, so its replication factor is back at the expected level. Once this has happened, the corrupt replica is deleted.

It is possible to disable verification of checksums by passing false to the `setVerifyChecksum()` method on FileSystem before using the `open()` method to read a file. The same effect is possible from the shell by using the `-ignoreCrc` option with the `- get` or the equivalent `-copyToLocal` command. This feature is useful if you have a corrupt file that you want to inspect so you can decide what to do with it. For example, you might want to see whether it can be salvaged before you delete it.

You can find a file’s checksum with `hadoop fs -checksum`. This is useful to check whether two files in HDFS have the same contents — something that distcp does, for example (see Parallel Copying with distcp).

- LocalFileSystem

The Hadoop LocalFileSystem performs client-side checksumming. This means that when you write a file called filename, the filesystem client transparently creates a hidden file, `.filename.crc`, in the same directory containing the checksums for each chunk of the file. The chunk size is controlled by the f`ile.bytes-per-checksum property`, which defaults to 512 bytes. The chunk size is stored `as metadata` in the `.crc` file, so the file can be read back correctly even if the setting for the chunk size has changed. Checksums are verified when the file is read, and if an error is detected, `LocalFileSystem throws a ChecksumException`.

Checksums are fairly cheap to compute (in Java, they are implemented in native code), typically adding a few percent overhead to the time to read or write a file. For most applications, this is an acceptable price to pay for data integrity. It is, however, possible to disable checksums, which is typically done when the underlying filesystem supports checksums natively. This is accomplished by using `RawLocalFileSystem` in place of `LocalFileSystem`. To do this globally in an application, it suffices to remap the implementation for file URIs by setting the property `fs.file.impl` to the value `org.apache.hadoop.fs.RawLocalFileSystem`. Alternatively, you can directly create a RawLocalFileSystem instance, which may be useful if you want to disable checksum verification for only some reads, for example:

```java
Configuration conf = ...
FileSystem fs = new RawLocalFileSystem();
fs.initialize(null, conf);
```

- ChecksumFileSystem

LocalFileSystem uses `ChecksumFileSystem` to do its work, and this class makes it easy to add checksumming to other (nonchecksummed) filesystems, as ChecksumFileSystem is just a wrapper around FileSystem. The general idiom is as follows:

```java
FileSystem rawFs = ...
FileSystem checksummedFs = new ChecksumFileSystem(rawFs);
```

The underlying filesystem is called the `raw filesystem`, and may be retrieved using the `getRawFileSystem()` method on `ChecksumFileSystem`. ChecksumFileSystem has a few more useful methods for working with checksums, such as `getChecksumFile()` for getting the path of a checksum file for any file. Check the documentation for the others.

If an error is detected by ChecksumFileSystem when reading a file, it will call its `reportChecksumFailure()` method. The default implementation does nothing, but LocalFileSystem moves the offending file and its checksum to a side directory on the same device called `bad_files`. Administrators should periodically check for these bad files and take action on them.

### Compression / 压缩

### Serialization / 序列化

### File-Based Data Structures