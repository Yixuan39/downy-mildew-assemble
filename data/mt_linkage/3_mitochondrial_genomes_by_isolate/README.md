# Mitochondrial genome submission annotations

The NCBI submission set contains two *Pseudoperonospora cubensis* isolates: SC1982 and MSU1. The directory name is retained for existing paths.

- Individual `.gb` files contain the annotated genomes; individual `.fasta` files contain their sequences.
- `Pseudoperonospora_mitochondrial_genomes.fasta` and `mitochondrial_genomes.tbl` are the combined submission sequence and feature files, with matching sequence IDs.
- Run `python3 gb2tbl.py` from this directory to regenerate the feature table (requires Biopython).

*Pseudoperonospora humuli* OR502AA was removed from this submission set because, as reported by the submitter, its mitochondrial genome is identical to the previously submitted Illumina-assembled mitochondrial genome and NCBI will not accept the duplicate. It must remain excluded when regenerating submission files.

The parent `14_mitochondrial_genomes.gb` dataset and its linkage plots are comparative analysis materials, rather than this submission set, and retain the *P. humuli* record.
