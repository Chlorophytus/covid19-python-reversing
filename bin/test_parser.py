import numpy as np
from covid19re.vectorize import VectorizedGenomeParser

rest = None
with open("./bin/data/GCF_009858895.2_ASM985889v3_genomic.fna", 'r') as f:
    f.readline()
    rest = f.read().replace('\n', '')

genome = VectorizedGenomeParser(rest)
print(np.array(memoryview(genome)))
    