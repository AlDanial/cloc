# nominal; skip first two
cloc --yaml --out case_1.yaml --skip-leading 2 ../../../inputs/issues/530

# more lines than in the file; null return
cloc --yaml --out case_2.yaml --skip-leading 100 ../../../inputs/issues/530

# in extension list; skip first two
cloc --yaml --out case_3.yaml --skip-leading 2,c,h ../../../inputs/issues/530

# not in extension list; skip nothing
cloc --yaml --out case_4.yaml --skip-leading 2,C,H ../../../inputs/issues/530
