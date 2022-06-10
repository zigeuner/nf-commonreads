#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/*  Process an input file
 *  usage example:
 *    nextflow run nf-commonreads/main.nf -with-docker [nextflow-image] --bam1 [path or s3 folder uri] --bam2 [path or s3 folder uri] --outdir [path to folder ors3 folder uri]
 *        
 */ 

params.bam1 = ''
params.bam2 = ''
params.outdir = 'results'

process extract_mapped {
    container '829680141244.dkr.ecr.us-west-1.amazonaws.com/artemys-biocontainers/sarekbase'
//    publishDir "$params.outdir"  
    
    input:
      path bamfile

    output:
      path "${bamfile.baseName}_mapped.bam"

    script:
      println "processing bamfile: " + bamfile
      """
      samtools view -b -F4 $bamfile > "${bamfile.baseName}_mapped.bam"
      """
}

process printpassed {
    container '829680141244.dkr.ecr.us-west-1.amazonaws.com/artemys-biocontainers/sarekbase'
    
    input:
      path inputfile

    script:
      println "path passed: " + inputfile
      """
      echo "done"
      """
}

process compare_bams {
    container '829680141244.dkr.ecr.us-west-1.amazonaws.com/artemys-biocontainers/sarekbase'
    publishDir "$params.outdir"
    
    input:
      path inputfiles

    output:
      path "${inputfiles[0].baseName}_sorted.txt"
      path "${inputfiles[1].baseName}_sorted.txt"
      path "common_mapped_readnames.txt"
      path "${inputfiles[0].baseName}_common.bam"
      path "${inputfiles[1].baseName}_common.bam"      

    script:
      println "path1 passed: " + inputfiles[0]
      println "path2 passed: " + inputfiles[1]      
      """
      samtools view "${inputfiles[0]}" | cut -f1 | LC_ALL=C sort | uniq > "${inputfiles[0].baseName}_sorted.txt"
      samtools view "${inputfiles[1]}" | cut -f1 | LC_ALL=C sort | uniq > "${inputfiles[1].baseName}_sorted.txt"
      LC_ALL=C comm -12 "${inputfiles[0].baseName}_sorted.txt" "${inputfiles[1].baseName}_sorted.txt" > common_mapped_readnames.txt
      picard FilterSamReads I="${inputfiles[0]}" O="${inputfiles[0].baseName}_common.bam" READ_LIST_FILE=common_mapped_readnames.txt FILTER=includeReadList
      picard FilterSamReads I="${inputfiles[1]}" O="${inputfiles[1].baseName}_common.bam" READ_LIST_FILE=common_mapped_readnames.txt FILTER=includeReadList
      """
}

workflow {
    bamfiles = channel.fromList([params.bam1, params.bam2])
    println "bamfiles: " + bamfiles
    extract_mapped(bamfiles)
    extract_mapped.out.view{ it }
    printpassed(extract_mapped.out.collect())
    compare_bams(extract_mapped.out.collect())
}
