//
//  PolynomialRootFinder.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/06/12.
//

extension Polynomial where R == 𝐂 {
    // Newton's method: https://en.wikipedia.org/wiki/Newton%27s_method
    //
    // MEMO: Jenkins–Traub algorithm might be better
    // https://en.m.wikipedia.org/wiki/Jenkins–Traub_algorithm
    public func findRoot() -> 𝐂? {
        let f = self
        if f.degree == 0 {
            return nil
        }
        
        if f.degree == 1 {
            return -f.constTerm / f.leadCoeff
        }
        
        let df = f.derivative
        
        for _ in 0 ..< 10 {
            var z: 𝐂 = .random(radius: 1.0)
            while df.evaluate(by: z).isZero {
                z = z + .random(radius: 0.1)
            }
            
            for _ in 0 ..< 10000 {
                let w = f.evaluate(by: z)
//                print("z = \(z) -> f(z) = \(w)")
                
                if w.isZero {
                    break
                }
                z = z - w / df.evaluate(by: z)
            }
            
            if f.evaluate(by: z.rounded()).isZero {
                return z.rounded()
            }
            
            if f.evaluate(by: z).isZero {
                return z
            }
        }
        
        return nil
    }
    
    public func findAllRoots() -> [𝐂] {
        var F = self
        return (0 ..< F.degree).compactMap { _ in
            if let z = F.findRoot() {
                // MEMO Ruffini's rule might be better
                // https://en.m.wikipedia.org/wiki/Ruffini%27s_rule
                F = F / .init(coeffs: [-z, .identity])
                return z
            } else {
                return nil
            }
        }
    }
}
