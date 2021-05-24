import SwmCore

// MARK: Fixed size square matrix
do {
    typealias M = Matrix3x3<𝐙> // 3x3 integer matrix
    
    let a: M = [
        1,2,3,
        4,5,6,
        7,8,9
    ]

    let b: M = [
        1,0,1,
        0,1,0,
        4,0,5
    ]
    
    a + b
    a - b
    a * b
    
    a.trace
    a.determinant
    a.inverse // nil
    
    b.trace
    b.determinant
    b.inverse
    
    b * b.inverse! == .identity
}

// MARK: Fixed size rectangular matrix
do {
    typealias M = Matrix<𝐙, _3, _2> // 3x2 integer matrix

    let a: M = [
        1,2,
        3,4,
        5,6
    ]

    let b: M = [
        1,0,
        0,1,
        4,0,
    ]
    
    a + b
    a - b
    
//  Below are prohibited in compile-time:
//  a * b
//  a.trace
//  a.determinant
//  a.inverse
    
    typealias N = Matrix<𝐙, _2, _3>
    
    let c: N = [
        1, 2, 3,
        4, 5, 6
    ]
    
    a * c
    
    (a * c).determinant // This is OK, because it is a 2x2 matrix.
}
