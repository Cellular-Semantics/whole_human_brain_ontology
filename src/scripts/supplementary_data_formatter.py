import os
import csv
from template_generation_utils import read_csv, read_csv_to_dict

CLUSTER_ANNOTATION_PATH = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../dendrograms/supplementary/cluster_annotation_CS202210140.tsv")
NT_SYMBOL_MAPPING = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../dendrograms/supplementary/Neurotransmitter_symbols_mapping.tsv")
BRAIN_REGION_MAPPING = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../dendrograms/supplementary/Brain_region_mapping.tsv")


def get_unique_nts(raw_file_path):
    unique_nts = set()
    headers, records = read_csv_to_dict(raw_file_path, delimiter="\t")

    for record in records:
        neurotransmitters = records[record]["Neurotransmitter auto-annotation"].strip()
        if neurotransmitters:
            unique_nts.update(neurotransmitters.split(" "))

    with open(NT_SYMBOL_MAPPING, mode='w') as out:
        writer = csv.writer(out, delimiter="\t", quotechar='"')
        writer.writerow(["SYMBOL", "CELL TYPE LABEL", "CELL TYPE NEUROTRANSMISSION ID", "GENES", "COMMENTS"])

        for unique_nt in unique_nts:
            writer.writerow([unique_nt, "", "", "", ""])


def get_unique_brain_regions(raw_file_path):
    unique_regions = set()
    headers, records = read_csv_to_dict(raw_file_path, delimiter="\t")

    for record in records:
        brain_regions = records[record]["Top three regions"].strip()

        if brain_regions:
            # Midbrain: 21.0%, Basal forebrain: 19.0%, Pons: 14.3%
            parts = brain_regions.split(",")
            for part in parts:
                label = part.split(":")[0].strip()
                percentage = part.split(":")[1].strip().replace("%", "")
                if float(percentage) >= 10:
                    unique_regions.add(label)

    with open(BRAIN_REGION_MAPPING, mode='w') as out:
        writer = csv.writer(out, delimiter="\t", quotechar='"')
        writer.writerow(["LABEL", "UBERON ID", "HBA ID"])

        for region in unique_regions:
            writer.writerow([region, "", ""])


# get_unique_nts(CLUSTER_ANNOTATION_PATH)
get_unique_brain_regions(CLUSTER_ANNOTATION_PATH)
