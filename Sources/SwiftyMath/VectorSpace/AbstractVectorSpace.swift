//
//  AbstractVectorSpace.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/16.
//

public typealias AbstractVectorSpace<K: Field> = AbstractFreeModule<K>
public typealias AbstractTensorSpace<K: Field> = AbstractTensorModule<K>

public typealias AbstractLinearMap<K: Field> = AbstractFreeModuleHom<K>
public typealias AbstractTensorMap<K: Field> = AbstractTensorModuleHom<K>
