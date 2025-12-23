# 2025-12-22

I started to download the corresponding files from the eggnog webpage `https://eggnogdb.org`

```
wget https://eggnogdb.org/public/eggnog7/e7.proteins.fa.gz
wget https://eggnogdb.org/public/eggnog7/e7.og_fasta_sequences.tar
wget https://eggnogdb.org/public/eggnog7/e7.og_info_kegg_go.tsv.gz
wget https://eggnogdb.org/public/eggnog7/e7.protein_families.tsv.gz
wget https://eggnogdb.org/public/eggnog7/e7.clu2ogs.tsv.gz
wget https://eggnogdb.org/public/eggnog7/e7.taxid_info.tsv.gz
wget https://eggnogdb.org/public/eggnog7/e7.trees.tsv.gz
```

Then I prepared the diamond database and unpacked other data tables

```
module load diamond/2.1.16
gunzip e7.proteins.fa.gz
gunzip e7.og_info_kegg_go.tsv.gz
gunzip e7.protein_families.tsv.gz
gunzip e7.taxid_info.tsv.gz
gunzip e7.clu2ogs.tsv.gz

diamond makedb \
  --in e7.proteins.fa \
  -d eggnog7_proteins
```

The database was then generated for the proteinnames and sequences (59,310,557) providing  this summary

```
Database sequences  59310557
Database letters  21584125582
Database hash  96214b11d2bc8baf4971505fb348d828
Total time  1205s
```

Then I explode the file e7.og_info_kegg_go.tsv to have a single search term later for the database intersection.

```
awk -F'\t' '{
    n=split($6, arr, ",");
    for(i=1;i<=n;i++){
        $6=arr[i];
        print $0
    }
}' OFS='\t' e7.og_info_kegg_go.tsv > e7.og_info_kegg_go_long.tsv
```

The new file `e7.og_info_kegg_go_long.tsv` has 121,478,035 rows and the following columns

1. OG name
2. protein cluster
3. taxonomic level
4. number of proteins associated to OG
5. number of species associated to OG
6. protein name
7. KEGG KO terms
8. KEGG KO symbols
9. GO slim terms

# 2025-12-23

Next I merge in the taxonomic information, assuming that we have the old taxonomic id in column 3
```
awk -F'\t' '
NR==FNR {
    if ($1 !~ /^#/) {
        tax[$1] = $3 "\t" $4 "\t" $5 "\t" $6
    }
    next
}
{
    if ($3 in tax) {
        print $0 "\t" tax[$3]
    } else {
        print $0 "\tNA\tNA"
    }
}
' e7.taxid_info.tsv e7.og_info_kegg_go_long.tsv > e7.og_info_with_taxa.tsv
```

Then I do already a test annotation

```
cd /run/nvme/job_31023856/data
module load diamond
cp /scratch/project_2009831/eggnog_devel/eggnog7_proteins.dmnd .
cp /scratch/project_2009831/eggnog_devel/e7.og_info_with_taxa.tsv .
cp /scratch/project_2001829/RuminomicsHighLow/results/contig_annotate/prodigal/ERR2019356/ERR2019356.prodigal.fa  .

diamond blastp \
  -d eggnog7_proteins.dmnd \
  -q ERR2019356.prodigal.fa \
  -o ERR2019356.diamond.tsv \
  --outfmt 6 \
  --max-target-seqs 1   # nur 1 Treffer pro Query
  --evalue 1e-5         # Filter, optional
  -p 16
```

And then I'll merge it with my master table

```
gzip e7.og_info_with_taxa.tsv

awk -F'\t' -v OFS='\t' '
NR==FNR {
    # og_taxa.tsv: key = Protein in col 6
    prot[$6] = $0   # store annotation line for merging
    next
}
{
    key = $2   # Diamond sseqid
    if (key in prot) {
        # Only select Diamond columns 1,2,3,4,11,12 + append annotation
        print $1, $2, $3, $4, $11, $12, prot[key]
    } else {
        print $1, $2, $3, $4, $11, $12, "NA"
    }
}
' <(zcat e7.og_info_with_taxa.tsv.gz) ERR2019356.diamond.tsv | gzip > ERR2019356_eggnog_annotations.tsv.gz
```

That works well, so I can prepare the files for download

```
mv e7.og_info_with_taxa.tsv.gz eggnog7_20251223_master_search_table.tsv.gz
mv eggnog7_proteins.dmnd eggnog7_20251223_proteins.dmnd
```
