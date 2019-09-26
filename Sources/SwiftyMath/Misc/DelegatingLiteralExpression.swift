//
//  InheritLiteralExpression.swift
//  SwiftyMath
//
//  Created by Taketo Sano on 2019/09/26.

//  Having many types conforming to `ExpressibleByXXXLiteral`s causes implicit conversion chaos.
//  Many such types are containers that delegate the literal-initialization to their contents.
//  The protocols below can be used to expliticly choose which types to be conformed.

//  e.g. make RationalNumber expressible by int-literal.
//
//  extension RationalNumber: ExpressibleByIntegerLiteral, DelegatingIntegerLiteralInitialization {
//      public typealias IntegerLiteralDelegate = 𝐙
//      public typealias IntegerLiteralType = IntegerLiteralDelegate.IntegerLiteralType
//  }

public protocol DelegatingIntegerLiteralInitialization: ExpressibleByIntegerLiteral where IntegerLiteralType == IntegerLiteralDelegate.IntegerLiteralType {
    associatedtype IntegerLiteralDelegate: ExpressibleByIntegerLiteral
    init(_ inheritee: IntegerLiteralDelegate)
}

extension DelegatingIntegerLiteralInitialization {
    public init(integerLiteral value: IntegerLiteralType) {
        let delegate = IntegerLiteralDelegate(integerLiteral: value)
        self.init(delegate)
    }
}

public protocol DelegatingFloatLiteralInitialization: ExpressibleByFloatLiteral where FloatLiteralType == FloatLiteralDelegate.FloatLiteralType {
    associatedtype FloatLiteralDelegate: ExpressibleByFloatLiteral
    init(_ delegate: FloatLiteralDelegate)
}

extension DelegatingFloatLiteralInitialization {
    public init(floatLiteral value: FloatLiteralType) {
        let delegate = FloatLiteralDelegate(floatLiteral: value)
        self.init(delegate)
    }
}
