都知道memstore大小到一定程度后会flush到disk上去，这个大小是由hbase.hregion.memstore.flush.size定义的。flush的时候也不是说马上就flush出去，会有个检查，就是下面这个方法了：

 

code：hbase 0.20.6， MemStoreFlusher.java

 

Java代码  收藏代码
```java
/* 
  * A flushRegion that checks store file count.  If too many, puts the flush 
  * on delay queue to retry later. 
  * @param fqe 
  * @return true if the region was successfully flushed, false otherwise. If  
  * false, there will be accompanying log messages explaining why the log was 
  * not flushed. 
  */  
 private boolean flushRegion(final FlushQueueEntry fqe) {  
   HRegion region = fqe.region;  
   if (!fqe.region.getRegionInfo().isMetaRegion() &&  
       isTooManyStoreFiles(region)) {  
     if (fqe.isMaximumWait(this.blockingWaitTime)) {  
       LOG.info("Waited " + (System.currentTimeMillis() - fqe.createTime) +  
         "ms on a compaction to clean up 'too many store files'; waited " +  
         "long enough... proceeding with flush of " +  
         region.getRegionNameAsString());  
     } else {  
       // If this is first time we've been put off, then emit a log message.  
       if (fqe.getRequeueCount() <= 0) {  
         // Note: We don't impose blockingStoreFiles constraint on meta regions  
         LOG.warn("Region " + region.getRegionNameAsString() + " has too many " +  
           "store files; delaying flush up to " + this.blockingWaitTime + "ms");  
       }  
       this.server.compactSplitThread.compactionRequested(region, getName());  
       // Put back on the queue.  Have it come back out of the queue  
       // after a delay of this.blockingWaitTime / 100 ms.  
       this.flushQueue.add(fqe.requeue(this.blockingWaitTime / 100));  
       // Tell a lie, it's not flushed but it's ok  
       return true;  
     }  
   }  
   return flushRegion(region, false);  
 }  
```

这个code逻辑是：

1. 如果是meta region，没话说，立即flush出去吧，因为meta region优先级高啊；

2. 如果是user的region，先看看是不是有太多的StoreFile了，这个storefile就是每次memstore flush造成的，flush一次，就多一个storefile，所以一个HStore里面会有多个storefile（其实就是hfile）。判断多不多的一个阈值是由hbase.hstore.blockingStoreFiles定义的；

 

Note：要弄清楚的就是，Hbase将table水平划分成Region，region按column family划分成Store，每个store包括内存中的memstore和持久化到disk上的HFile。

 

还有一个check flush的地方，就是HRegion里面

 

Java代码  收藏代码
```java
/* 
  * Check if resources to support an update. 
  * 
  * Here we synchronize on HRegion, a broad scoped lock.  Its appropriate 
  * given we're figuring in here whether this region is able to take on 
  * writes.  This is only method with a synchronize (at time of writing), 
  * this and the synchronize on 'this' inside in internalFlushCache to send 
  * the notify. 
  */  
 private void checkResources() {  
  
   // If catalog region, do not impose resource constraints or block updates.  
   if (this.getRegionInfo().isMetaRegion()) return;  
  
   boolean blocked = false;  
   while (this.memstoreSize.get() > this.blockingMemStoreSize) {  
     requestFlush();  
     if (!blocked) {  
       LOG.info("Blocking updates for '" + Thread.currentThread().getName() +  
         "' on region " + Bytes.toStringBinary(getRegionName()) +  
         ": memstore size " +  
         StringUtils.humanReadableInt(this.memstoreSize.get()) +  
         " is >= than blocking " +  
         StringUtils.humanReadableInt(this.blockingMemStoreSize) + " size");  
     }  
     blocked = true;  
     synchronized(this) {  
       try {  
         wait(threadWakeFrequency);  
       } catch (InterruptedException e) {  
         // continue;  
       }  
     }  
   }  
   if (blocked) {  
     LOG.info("Unblocking updates for region " + this + " '"  
         + Thread.currentThread().getName() + "'");  
   }  
 } 
```

这里的memstoreSize是一个region中所有memstore的总大小，blockingMemStoreSize计算的公式如下：

blockingMemStoreSize=hbase.hregion.memstore.flush.size*hbase.hregion.memstore.block.multiplier

就是说，对整个HRegion来说，所有memstore的总大小大于multiplier个memstore阈值的时候，就开始阻止客户端的更新了，这样是为了避免内存中的数据太多吧。