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

diamond makedb \
  --in e7.proteins.fa \
  -d eggnog7_proteins
```

The database was then generated providing  this summary

```
Database sequences  59310557
Database letters  21584125582
Database hash  96214b11d2bc8baf4971505fb348d828
Total time  1205s
```
