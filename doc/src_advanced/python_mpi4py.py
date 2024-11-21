import numpy as np
from mpi4py import MPI
import pyMpiPerfMonitor

print("python pmlib mpi4py check program starts")

size = MPI.COMM_WORLD.Get_size()
rank = MPI.COMM_WORLD.Get_rank()
name = MPI.Get_processor_name()

#   comm = MPI.COMM_WORLD
#   size = comm.Get_size()
#   rank = comm.Get_rank()
#   name = comm.Get_processor_name()

print(f"<main> rank={rank},  size={size},  name={name}")

pmlib = pyMpiPerfMonitor.PerfMonitor()
pmlib.initialize(5)

matsize=1000
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

pmlib.report("perf-report.txt")

