import os
import csv
from template_generation_utils import read_csv, read_csv_to_dict

CLUSTER_ANNOTATION_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../dendrograms/raw/Table_S2_cluster_annotation.tsv")
NT_SYMBOL_MAPPING = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../dendrograms/raw/Neurotransmitter_symbols_mapping.tsv")


def get_unique_nts(raw_file_path):
    unique_nts = set()
    headers, records = read_csv_to_dict(raw_file_path, delimiter="\t")

    for record in records:
        neurotransmitters = records[record]["Neurotransmitter auto-annotation"].strip()
        if neurotransmitters:
            unique_nts.update(neurotransmitters.split(" "))

    with open(NT_SYMBOL_MAPPING, mode='w') as out:
        writer = csv.writer(out, delimiter="\t", quotechar='"')
        writer.writerow(["SYMBOL", "CELL TYPE LABEL", "CELL TYPE ID", "GENES", "COMMENTS"])

        for unique_nt in unique_nts:
            writer.writerow([unique_nt, "", "", "", ""])


get_unique_nts(CLUSTER_ANNOTATION_PATH)
