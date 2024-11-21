import pyPerfMonitor 

pmlib = pyPerfMonitor.PerfMonitor()
pmlib.initialize(66)
pmlib.start("section-X")
n=1000000
add=0.0
for i in range(n): add=add+1.0
for i in range(n): add=add+10.0*i
pmlib.stop("section-X")
print("<python main> computed %d F.P.ops add=", 3*n, add)

#   pmlib.stop("section-Y", 0.5, 3)
#   pmlib.stop(label="section-Z", flopPerTask=0.9, iterationCount=10)

pmlib.report("perf-report.txt")

