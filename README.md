## Simple Nextflow script to find reads common to two bam files ##

procedure:  

* extract mapped reads into two derivative bam files: mapped1.bam and mapped2.bam
* extract read names and sort
* compare read names and find common read names using linux 'comm' utility
* extract reads from mapped1.bam using common read names and return common_mapped1.bam
* extract reads from mapped2.bam using common read names and return common_mapped2.bam

usage example:
```
nextflow run nf-commonreads/main.nf -with-docker [nextflow-image] --bam1 [path or s3 folder uri] --bam2 [path or s3 folder uri] --outdir [path to folder or s3 folder uri]
```

If the input bam filenames are not unique, then specify tags like this:

```
nextflow run nf-commonreads/main.nf -with-docker [nextflow-image] --bam1 [path or s3 folder uri] --tag1 [unique tag] --bam2 [path or s3 folder uri] --tag2 [unique tag] --outdir [path to folder or s3 folder uri]
```

