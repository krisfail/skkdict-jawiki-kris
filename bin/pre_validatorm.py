import time
import logging

from jawiki import pre_validate

logging.basicConfig(filename='logs/pre_validatem.log', level=logging.INFO)

t0 = time.time()

with open('dat/scannedm.tsv', 'r', encoding='utf-8') as rfp, \
        open('dat/pre_validatedm.tsv', 'w', encoding='utf-8') as wfp:

    pre_validator = pre_validate.PreValidator()
    for line in rfp:
        cols = line.strip().split("\t")
        if len(cols) != 3:
            logging.info(f"Invalid entry: {cols}")
            continue

        title, kanji, yomi = cols
        if pre_validator.validate(title, kanji, yomi):
            wfp.write(f"{title}\t{kanji}\t{yomi}\n")

print(f"Proceeded: {str(time.time() - t0)} seconds")
