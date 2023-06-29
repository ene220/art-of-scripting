#testing the makefile ezz
#trying pulling down
#fatima hisam
#testing the makefile ezz
#trying pulling down
#third test ezz
#Nathan this is a test

#GROUCHY GRINCH
All: Data Untar Stats Investigate Evaluate Root Index GC Intron length estimate Annotation2 Annotation3 Stranded Sensing Gene selection Report Sort_store IGV

#Chapter 18
Data:
	# Download the data.
	wget -nc http://data.biostarhandbook.com/rnaseq/data/grinch.tar.gz

# Unpack the data
Untar:
	# Unpack the data
	tar zxvf grinch.tar.gz

#Print statistics on the data
Stats:
	# Print statistics on the data
	seqkit stats reads/*.fq
	
#Investigate the genome
Investigate:
	# Investigate the genome
	seqkit stats refs/grinch-genome.fa

#Count lines in each annotation file
Evaluate:
	#Evaluate the annotation files
	wc -l refs/grinch-ann*

##Visual Annotations

#Chapter 19

#Root Creations
Root: 
	# Root Creation
	parallel echo {1}{2} ::: Cranky Wicked ::: 1 2 3 > ids
	parallel --citation

#Index the Genome
	# A shortcut to the genome.
IDX = refs/grinch-genome.fa

Index:
	# Build the index. It needs to be done only once per genome.
	hisat2-build $(IDX) $(IDX)


	# Make a directory for the bam file.
	# Run the hisat aligner for each sample.
	mkdir -p bam
	cat ids | parallel "hisat2 -x $(IDX) -U reads/{}.fq | samtools sort > bam/{}.bam"

	# Create a bam index for each file.
	cat ids | parallel samtools index bam/{}.bam

#Average sequence composition of GC
GC:
	# Average sequence composition of GC
	cat refs/grinch-genome.fa | geecee --filter
	# Compute GC for long gene
	cat reads/Cranky1.fq | seqkit seq -s | geecee --filter

#Intron Length Estimate (500bp, max 2500bp)
Intron length estimate:
	# Make a directory for the bam file.
	mkdir -p bam1
	# Run the hisat aligner for each sample.
	cat ids | parallel "hisat2 --max-intronlen 2500 -x $(IDX) -U reads/{}.fq  | samtools sort > bam1/{}.bam"
	cat ids | parallel samtools index bam1/{}.bam

##Visual Annotations
	
#Chapter 20
Annotation1:
	# Count reads in a single file.
	featureCounts -a refs/grinch-annotations_1.gff -o counts.txt bam/Cranky1.bam

Annotation2:
	# Count reads in a single file.
	featureCounts -t exon -g Parent -a refs/grinch-annotations_2.gff -o counts2.txt bam/Cranky1.bam

Annotation3:
	# Count reads in a single file.
	featureCounts -F GFF -a refs/grinch-annotations_3.gtf -o counts-3.txt bam/Cranky3.bam
	featureCounts -a refs/grinch-annotations_3.gtf -o counts-33.txt bam/C*.bam bam/W*.bam

#Chapter 21
#Stranded alignments
Stranded:
	# Make a directory for the bam file.
	mkdir -p bam2

	# Run the hisat aligner for each sample.
	cat ids | parallel "hisat2 --rna-strandness R --max-intronlen 2500 -x $(IDX) -U reads/{}.fq  | samtools sort > bam2/{}.bam"

	# Create a bam index for each file.
	cat ids | parallel samtools index bam2/{}.bam

#Antisense and Sense counts
Sensing:
	featureCounts -s 1 -a refs/grinch-annotations_3.gtf -o counts-anti3.txt bam1/C*.bam bam1/W*.bam

	featureCounts -s 2 -a refs/grinch-annotations_3.gtf -o counts-sense1.txt bam1/C*.bam bam1/W*.bam

	cat counts-sense1.txt | grep GRI |  datamash  max 7-12

	cat counts-anti3.txt | grep GRI |  datamash  max 7-12

#Chapter 22
#Coverage of the selected genes
Gene selection: 
	# Select the genes.
	cat refs/grinch-annotations_2.gff | awk '$$3=="gene" { print $$0 }' > genes.gff

	bedtools coverage -S -a genes.gff -b bam1/*.bam > coverage.txt
	
#Transcript Integrity
Report:
	cat coverage.txt | cut -f 9,13 | tr ";" "\t" | cut -f 1,3 | head
Sort_store:
	cat coverage.txt | cut -f 9,13 | tr ";" "\t" | cut -f 1,3 | sort -k2,2rn > tin.txt

#For IGV
IGV:
	# create .fai files for the genome
	samtools faidx refs/grinch-genome.fa
