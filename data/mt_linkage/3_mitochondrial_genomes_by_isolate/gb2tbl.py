from Bio import SeqIO

files = {
    "Pseudoperonospora_cubensis_SC1982_mito.gb": "SC1982_mito",
    "Pseudoperonospora_cubensis_MSU1_mito.gb": "MSU1_mito",
    "Pseudoperonospora_humuli_OR502AA_mito.gb": "OR502AA_mito",
}

drop = {"locus_tag", "protein_id", "db_xref", "gene_xref",
        "old_locus_tag", "standard_name"}

def key(f):
    return tuple((int(x.start), int(x.end), x.strand) for x in f.location.parts)

with open("mitochondrial_genomes.tbl", "w") as out:
    for file, seqid in files.items():
        r = SeqIO.read(file, "genbank")

        # gene names from CDS/rRNA/tRNA etc.
        genes = {
            key(f): f.qualifiers["gene"][0]
            for f in r.features if "gene" in f.qualifiers
        }

        out.write(f">Feature {seqid}\n")

        for f in r.features:
            if f.type == "source":
                continue

            q = dict(f.qualifiers)

            if f.type == "gene" and "gene" not in q:
                if key(f) not in genes:
                    continue
                q["gene"] = [genes[key(f)]]

            for i, p in enumerate(f.location.parts):
                a, b = int(p.start) + 1, int(p.end)
                if p.strand == -1:
                    a, b = b, a
                out.write(f"{a}\t{b}\t{f.type if i == 0 else ''}\n")

            for k, values in q.items():
                if k in drop:
                    continue
                for v in values:
                    if "Derived using Geneious" not in str(v):
                        out.write(f"\t\t\t{k}\t{v}\n")
