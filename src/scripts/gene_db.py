"""
Download gene info from https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz

This scripts filters Human genes from the gene_info file and converts to a ROBOT template to represent as an ontology.

To review data: zcat gene_info.gz | cut -f1,2,3,5,9,13 > gene_info_filter
"""
import os
import csv

# Downloaded https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz
GENE_INFO = "/home/huseyin/Downloads/entrez/gene_info_all"

TAX_ID = 0
GENE_ID = 1
SYMBOL = 2
SYNONYMS = 4

SIMPLE_HUMAN = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../templates/simple_human.tsv")


def construct_human_gene_db():
    genes = dict()
    with open(GENE_INFO) as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        for row in rd:
            if row[TAX_ID] == "9606":
                genes[row[GENE_ID]] = row

    with open(SIMPLE_HUMAN.replace(".tsv", "_2.tsv"), mode='w') as out:
        writer = csv.writer(out, delimiter="\t", quotechar='"')
        writer.writerow(["ID", "TYPE", "NAME", "SYNONYMS"])
        writer.writerow(["ID", "SC %", "A rdfs:label", "A oboInOwl:hasExactSynonym SPLIT=|"])

        for gene in genes:
            synonyms = genes[gene][SYNONYMS]
            if synonyms == "-":
                synonyms = ""
            writer.writerow(["entrez:" + gene, "SO:0000704",
                             genes[gene][SYMBOL] + " (Hsap)", synonyms])


construct_human_gene_db()



