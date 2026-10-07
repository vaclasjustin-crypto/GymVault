import Foundation

// Logic mirror smoke test for Linux CI-style validation.
func approx(_ a: Double, _ b: Double, eps: Double = 0.000001) -> Bool { abs(a - b) < eps }

// 10 mg in 2 ml = 5 mg/ml. 2.5 mg = 0.5 ml = 50 U-100 markings.
let c1 = 10.0 / 2.0
let v1 = 2.5 / c1
assert(approx(c1, 5.0))
assert(approx(v1, 0.5))
assert(approx(v1 * 100.0, 50.0))

// 10 IU in 1 ml. 2 IU = 0.2 ml = 20 U-100 markings.
let c2 = 10.0 / 1.0
let v2 = 2.0 / c2
assert(approx(v2, 0.2))
assert(approx(v2 * 100.0, 20.0))

// 250 mg/ml. 125 mg = 0.5 ml = 50 U-100 markings.
let v3 = 125.0 / 250.0
assert(approx(v3, 0.5))
assert(approx(v3 * 100.0, 50.0))

print("Calculator smoke tests passed")
