all: SKK-JISYO.jawiki

check: SKK-JISYO.jawiki
	pytest check.py

test:
	pytest
	pyflakes *.py */*.py
	autopep8 --max-line-length 180 -i *.py */*.py
	flake8 . --count --exit-zero --max-complexity=30 --max-line-length=1200 --statistics

# dat/jawiki-latest-pages-articles.xml.bz2:
# 	wget --no-verbose --no-clobber -O dat/jawiki-latest-pages-articles.xml.bz2 https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-pages-articles.xml.bz2

# dat/jawiki-latest-abstract.xml.gz:
# 	wget --no-verbose --no-clobber -O dat/jawiki-latest-abstract.xml.gz https://dumps.wikimedia.org/jawiki/latest/jawiki-latest-abstract.xml.gz

# dat/jawiki-latest-pages-articles.xml: dat/jawiki-latest-pages-articles.xml.bz2
# 	bunzip2 --keep --force dat/jawiki-latest-pages-articles.xml.bz2

# dat/jawiki-latest-abstract.xml: dat/jawiki-latest-abstract.xml.gz
# 	gzip -d --keep --force dat/jawiki-latest-abstract.xml.gz

dat/dic-nico-intersection-pixiv.txt:
	wget -O dat/dic-nico-intersection-pixiv.txt https://cdn.ncaq.net/dic-nico-intersection-pixiv.txt

dat/dic-nic-pix-clean.tsv: dat/dic-nico-intersection-pixiv.txt
	sed -e "s/\t固有名詞\tnico-pixiv//g" dat/dic-nico-intersection-pixiv.txt | sed -e "s/\tアルファベット\tnico-pixiv//g" | sed -e "1,8d" > dat/dic-nic-pix-clean.tsv

dat/grepped.txt: #dat/jawiki-latest-pages-articles.xml
	rg "<title>.*</title>|'''[』|（(]" dat/jawiki-latest-pages-articles.xml > dat/grepped.txt

dat/scanned.tsv: dat/grepped.txt bin/scanner.py jawiki/scanner.py
	python bin/scanner.py

dat/pre_validated.tsv: dat/scanned.tsv bin/pre_validator.py jawiki/pre_validate.py
	python bin/pre_validator.py

dat/converted.tsv: dat/pre_validated.tsv bin/converter.py jawiki/converter.py jawiki/hojin.py jawiki/jachars.py dat/dic-nic-pix-clean.tsv
	python bin/converter.py
	cat dat/converted.tsv dat/dic-nic-pix-clean.tsv > dat/conv.tsv
	sort dat/conv.tsv | uniq > dat/converted.tsv

dat/post_validated.tsv: dat/converted.tsv bin/post_validator.py jawiki/post_validate.py user_simpledic.csv
	python bin/post_validator.py

SKK-JISYO.jawiki: dat/post_validated.tsv bin/makedict.py jawiki/skkdict.py
	python bin/makedict.py /usr/share/skk/SKK-JISYO.L /usr/share/skk/SKK-JISYO.jinmei /usr/share/skk/SKK-JISYO.geo

dat/greppedm.txt: dat/jawiki-latest-abstract.xml
	grep -E "<title>.*</title>|'''[』|（(]" dat/jawiki-latest-abstract.xml > dat/greppedm.txt

dat/scannedm.tsv: dat/greppedm.txt bin/scannerm.py jawiki/scanner.py
	python bin/scannerm.py

dat/pre_validatedm.tsv: dat/scannedm.tsv bin/pre_validatorm.py jawiki/pre_validate.py
	python bin/pre_validatorm.py

dat/convertedm.tsv: dat/pre_validatedm.tsv bin/converterm.py jawiki/converter.py jawiki/hojin.py jawiki/jachars.py
	python bin/converterm.py

dat/post_validatedm.tsv: dat/convertedm.tsv bin/post_validatorm.py jawiki/post_validate.py user_simpledic.csv
	python bin/post_validatorm.py

SKK-JISYO.jawikimini: dat/post_validatedm.tsv bin/makedict2.py jawiki/skkdict.py
	python bin/makedict2.py /usr/share/skk/SKK-JISYO.L /usr/share/skk/SKK-JISYO.jinmei /usr/share/skk/SKK-JISYO.geo

.PHONY: all test

