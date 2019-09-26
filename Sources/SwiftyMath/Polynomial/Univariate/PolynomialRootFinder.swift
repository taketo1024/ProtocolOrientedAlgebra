//
//  PolynomialRootFinder.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/06/12.
//

extension _Polynomial where T == NormalPolynomialType, R == 𝐂 {
    // Newton's method: https://en.wikipedia.org/wiki/Newton%27s_method
    //
    // MEMO: Jenkins–Traub algorithm might be better
    // https://en.m.wikipedia.org/wiki/Jenkins–Traub_algorithm
    public func findRoot() -> 𝐂? {
        let F = self
        if F.degree == 0 {
            return nil
        }
        
        if F.degree == 1 {
            return -F.constTerm / F.leadCoeff
        }
        
        let f = F.derivative
        
        for _ in 0 ..< 10 {
            var z: 𝐂 = .random(radius: 1.0)
            while f.evaluate(at: z).isZero {
                z = z + .random(radius: 0.1)
            }
            
            for _ in 0 ..< 10000 {
                let w = F.evaluate(at: z)
//                print("z = \(z) -> f(z) = \(w)")
                
                if w.isZero {
                    break
                }
                z = z - w / f.evaluate(at: z)
            }
            
            if F.evaluate(at: z.rounded()).isZero {
                return z.rounded()
            }
            
            if F.evaluate(at: z).isZero {
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
