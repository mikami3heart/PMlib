import numpy as np
import pyPerfMonitor
  
pmlib = pyPerfMonitor.PerfMonitor()
pmlib.initialize(5)

matsize=10000
A_matrix = np.ones((matsize,matsize), dtype='float32')
A_matrix = np.random.rand(matsize,matsize).astype(np.float32)

print(A_matrix.dtype)
#	print(A_matrix)

#   rng = np.random.default_rng()   # rng forces float64 data type
#   B_matrix = rng.random((matsize,matsize))

B_matrix = np.ones((matsize,matsize), dtype='float32')
B_matrix = np.random.rand(matsize,matsize).astype(np.float32)
print(B_matrix.dtype)
#	print(B_matrix)

pmlib.start("section-X")
C_matrix = np.matmul(A_matrix,B_matrix)
pmlib.stop("section-X")
print(C_matrix.dtype)
print(C_matrix[0,0])
print(C_matrix[matsize-1,matsize-1])
#	print(C_matrix)

pmlib.report("")
#   pmlib.report("perf-report.txt")

