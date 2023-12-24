import re
import z3

input = [[int(i) for i in re.findall("-?\d+", l)]
         for l in open('input.txt').readlines()[:3]]

rock = z3.RealVector('r', 6)
time = z3.RealVector('t', 3)

s = z3.Solver()

for (t, vec) in zip(time, input):
    for i in range(3):
        s.add(rock[i] + rock[i + 3] * t == vec[i] + vec[i + 3] * t)

s.check()

s.model().eval(sum(rock[:3]))
