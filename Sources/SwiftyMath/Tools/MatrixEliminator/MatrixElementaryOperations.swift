//
//  MatrixElementaryOperations.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/10/26.
//

public enum RowElementaryOperation<R: Ring> {
    case AddRow(at: Int, to: Int, mul: R)
    case MulRow(at: Int, by: R)
    case SwapRows(Int, Int)
    
    public var determinant: R {
        switch self {
        case .AddRow(_, _, _):
            return .identity
        case let .MulRow(at: _, by: r):
            return r
        case .SwapRows:
            return -.identity
        }
    }
    
    public var inverse: Self {
        switch self {
        case let .AddRow(i, j, r):
            return .AddRow(at: i, to: j, mul: -r)
        case let .MulRow(at: i, by: r):
            return .MulRow(at: i, by: r.inverse!)
        case .SwapRows:
            return self
        }
    }
    
    public var transposed: ColElementaryOperation<R> {
        switch self {
        case let .AddRow(i, j, r):
            return .AddCol(at: i, to: j, mul: r)
        case let .MulRow(at: i, by: r):
            return .MulCol(at: i, by: r)
        case let .SwapRows(i, j):
            return .SwapCols(i, j)
        }
    }
}

public enum ColElementaryOperation<R: Ring> {
    case AddCol(at: Int, to: Int, mul: R)
    case MulCol(at: Int, by: R)
    case SwapCols(Int, Int)
    
    public var determinant: R {
        switch self {
        case .AddCol(_, _, _):
            return .identity
        case let .MulCol(at: _, by: r):
            return r
        case .SwapCols:
            return -.identity
        }
    }
    
    public var inverse: Self {
        switch self {
        case let .AddCol(i, j, r):
            return .AddCol(at: i, to: j, mul: -r)
        case let .MulCol(at: i, by: r):
            return .MulCol(at: i, by: r.inverse!)
        case .SwapCols:
            return self
        }
    }
    
    public var transposed: RowElementaryOperation<R> {
        switch self {
        case let .AddCol(i, j, r):
            return .AddRow(at: i, to: j, mul: r)
        case let .MulCol(at: i, by: r):
            return .MulRow(at: i, by: r)
        case let .SwapCols(i, j):
            return .SwapRows(i, j)
        }
    }
}

extension Matrix {
    public func applyRowOperations<S: Sequence>(_ ops: S) -> Self where S.Element == RowElementaryOperation<R> {
        let worker = RowEliminationWorker(self, trackRowInfos: false)
        
        // TODO batch addRows
        for op in ops {
            worker.apply(op)
        }
        
        return worker.resultAs(Self.self)
    }

    public func applyColOperations<S: Sequence>(_ ops: S) -> Self where S.Element == ColElementaryOperation<R> {
        // TODO transpose in place to reduce overhead
        let worker = RowEliminationWorker(self.transposed, trackRowInfos: false)
        
        // TODO batch addRows
        for op in ops {
            worker.apply(op.transposed)
        }
        
        return worker.resultAs(DMatrix<R>.self).transposed.as(Self.self)
    }
}
