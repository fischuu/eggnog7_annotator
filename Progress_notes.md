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

Next I merge in the taxonomic information, assuming that we have the old taxonomic id in column 3

```
# First, sort both files on the join columns
# e7.og_info_kegg_go_long.tsv: join on column 3
# e7.taxid_info.tsv: join on column 1 (Old_Taxid)

# I do that on a quick, local ssd

# extract the key column and sort
sort -t $'\t' -k3,3n --buffer-size=100G   --temporary-directory=$LOCAL_SCRATCH   e7.og_info_kegg_go_long.tsv > e7.og_info_kegg_go_long_sorted.tsv

sort -t $'\t' -k1,1n --buffer-size=100G   --temporary-directory=$LOCAL_SCRATCH   e7.taxid_info.tsv > e7.taxid_info_sorted.tsv

# Now join (tab-separated)
join -t $'\t' -1 3 -2 1 e7.og_info_kegg_go_long_sorted.tsv e7.taxid_info_sorted.tsv > e7.og_info_kegg_go_long_sorted_with_tax.tsv

```
