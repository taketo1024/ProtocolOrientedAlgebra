//
//  SimpleDirectedGraph.swift
//  SwiftyHomology
//
//  Created by Taketo Sano on 2020/10/08.
//

import Foundation

public typealias PlainGraph<VertexId: Hashable> = Graph<VertexId, Int, Int>

public struct Graph<VertexId, VertexValue, EdgeValue> where VertexId: Hashable {
    public typealias Options = [String: Any]
    
    public private(set) var vertices: [VertexId: Vertex]
    public var options: Options

    public init(template: Template) {
        self.init(options: template.options)
    }
    
    public init(options: Options? = nil) {
        self.vertices = [:]
        self.options = options ?? Template.plain.options
    }

    @inlinable
    public subscript(id: VertexId) -> Vertex? {
        vertices[id]
    }
    
    @discardableResult
    public mutating func addVertex(id: VertexId, value: VertexValue, options: Options = [:]) -> Vertex {
        assert(!vertices.contains(key: id))
        
        let v = Vertex(id: id, value: value, options: options)
        vertices[id] = v
        return v
    }
    
    public mutating func removeVertex(_ v: Vertex) {
        v.outEdges.forEach { e in
            v.removeEdges(to: e.target)
        }
        v.inEdges.forEach { e in
            v.removeEdges(from: e.source)
        }
        vertices[v.id] = nil
    }
    
    public func addEdge(fromId: VertexId, toId: VertexId, value: EdgeValue, options: Options = [:]) {
        guard let v = self[fromId], let w = self[toId] else {
            return
        }
        v.addEdge(to: w, value: value, options: options)
    }
    
    public func collectEdges() -> [Edge] {
        vertices.values.flatMap { $0.outEdges }
    }
    
    public final class Vertex: Equatable, CustomStringConvertible {
        public let id: VertexId
        public let value: VertexValue
        public var options: Options
        public var inEdges:  [Edge] = []
        public var outEdges: [Edge] = []
        
        fileprivate init(id: VertexId, value: VertexValue, options: Options) {
            self.id = id
            self.value = value
            self.options = options
        }

        public func addEdge(to: Vertex, value: EdgeValue, options: Options = [:]) {
            let e = Edge(source: self, target: to, value: value, options: options)
            outEdges.append(e)
            to.inEdges.append(e)
        }
        
        public func hasEdge(to: Vertex) -> Bool {
            outEdges.contains { $0.target == to }
        }
        
        public func hasEdge(from: Vertex) -> Bool {
            from.hasEdge(to: self)
        }
        
        public func edges(to: Vertex) -> [Edge] {
            outEdges.filter { $0.target == to }
        }
        
        public func edges(from: Vertex) -> [Edge] {
            from.edges(to: self)
        }
        
        public func removeEdges(to: Vertex) {
            outEdges.removeAll { e in
                e.target == to
            }
            to.inEdges.removeAll { e in
                e.source == self
            }
        }
        
        public func removeEdges(from: Vertex) {
            from.removeEdges(to: self)
        }
        
        public static func == (v: Vertex, w: Vertex) -> Bool {
            v.id == w.id
        }
        
        public var description: String {
            "\(id)"
        }
    }
    
    public struct Edge: CustomStringConvertible {
        public let source: Vertex
        public let target: Vertex
        public let value: EdgeValue
        public var options: Options
        
        fileprivate init(source: Vertex, target: Vertex, value: EdgeValue, options: Options) {
            self.source = source
            self.target = target
            self.value = value
            self.options = options
        }
        
        public var description: String {
            return "\(source)-\(target)"
        }
    }
    
    public enum Template {
        case hierarchical, plain
        
        fileprivate var options: Options {
            switch self {
            case .hierarchical:
                return [
                    "edges": [
                        "arrows": "to"
                    ],
                    "layout": [
                        "improvedLayout": false,
                        "hierarchical": [
                            "enabled": true,
                            "direction": "UD",
                            "sortMethod": "directed",
                            "shakeTowards": "roots",
                            "nodeSpacing": 10
                        ]
                    ]
                ]
            default:
                return [
                    "edges": [
                        "arrows": "to"
                    ]
                ]
            }
        }
    }
}

extension Graph where VertexId: CustomStringConvertible, VertexValue == Int, EdgeValue == Int {
    public init(structure: [VertexId: [VertexId]] = [:], options: Options? = nil) {
        self.init(options: options)
        
        for v in structure.keys {
            addVertex(id: v)
        }
        for (v, ws) in structure {
            for w in ws {
                addEdge(fromId: v, toId: w)
            }
        }
    }
    
    @discardableResult
    public mutating func addVertex(id: VertexId, options: Options = [:]) -> Vertex {
        addVertex(id: id, value: 0, options: options)
    }
    
    public func addEdge(fromId: VertexId, toId: VertexId, options: Options = [:]) {
        addEdge(fromId: fromId, toId: toId, value: 0, options: options)
    }
}

extension Graph {
    public func topologicalSort() -> [Vertex] {
        var visited: Set<VertexId> = []
        var result: [Vertex] = []
        
        visited.reserveCapacity(vertices.count)
        result .reserveCapacity(vertices.count)

        func traverse(_ v: Vertex) {
            visited.insert(v.id)
            
            for w in v.outEdges.map({ $0.target }) where !visited.contains(w.id) {
                traverse(w)
            }
            
            result.append(v)
        }
        
        let startVertices = vertices.values.filter{ $0.inEdges.isEmpty }
        for v in startVertices {
            traverse(v)
        }
        
        return result.reversed()
    }
}

extension Graph {
    // MEMO: ignores edge-directions.
    public func spanningTree() -> Self {
        var remain = Set(self.vertices.keys)
        
        var tree = Self()
        for v in vertices.values {
            tree.addVertex(id: v.id, value: v.value, options: v.options)
        }
        
        func dig(_ v: Vertex) {
            remain.remove(v.id)
            for e in v.outEdges where remain.contains(e.target.id) {
                let w = e.target
                tree.addEdge(fromId: v.id, toId: w.id, value: e.value, options: e.options)
                dig(w)
            }
            for e in v.inEdges where remain.contains(e.source.id) {
                let w = e.source
                tree.addEdge(fromId: w.id, toId: v.id, value: e.value, options: e.options)
                dig(w)
            }
        }
        
        while !remain.isEmpty {
            let rootId = remain.first!
            let root = self[rootId]!
            dig(root)
        }
        
        return tree
    }
}

extension Graph {
    public func asHTML(title: String? = nil) -> String {
        let template =
"""
<!doctype html>
<html>
<head>
  <title>${title}</title>
  <script type="text/javascript" src="https://visjs.github.io/vis-network/standalone/umd/vis-network.min.js"></script>
  <style type="text/css">
    #mynetwork {
      width: 100%;
      height: 100vh;
      border: 1px solid lightgray;
    }
  </style>
</head>
<body>

<div id="mynetwork"></div>

<script type="text/javascript">
  var nodes = new vis.DataSet(${vertices});
  var edges = new vis.DataSet(${edges});

  // create a network
  var container = document.getElementById('mynetwork');
  var data = {
    nodes: nodes,
    edges: edges
  };
  var options = ${options};
  var network = new vis.Network(container, data, options);
</script>
</body>
</html>
"""
        let indexTable = Dictionary(vertices.keys.enumerated().map { ($1, $0) })
        let rawVertices = vertices.map { (id, v) -> [String: Any] in
            v.options.merging([
                "id": indexTable[id]!,
                "label": "\(v.id)",
                "shape": "box"
            ], overwrite: false)
        }
        let rawEdges = vertices.values.flatMap {
            $0.outEdges.map { e -> [String: Any] in
                e.options.merging([
                    "from": indexTable[e.source.id]!,
                    "to": indexTable[e.target.id]!
                ], overwrite: false)
            }
        }
        func serialize(_ data: Any) -> String {
            let data = try! JSONSerialization.data(withJSONObject: data, options: [])
            return String(data: data, encoding: .utf8)!
        }
        let html =
            template
                .replacingOccurrences(of: "${title}", with: title ?? "graph")
                .replacingOccurrences(of: "${options}", with: serialize(options))
                .replacingOccurrences(of: "${vertices}", with: serialize(rawVertices))
                .replacingOccurrences(of: "${edges}", with: serialize(rawEdges))
        return html
    }
    
    public func showHTML(title: String? = nil) {
        guard #available(OSX 10.12, *) else {
            return
        }
        
        #if os(macOS)
        let html = asHTML(title: title)
        let file = FileManager().temporaryDirectory.appendingPathComponent("\(title ?? "tmp").html")
        try! html.write(to: file, atomically: true, encoding: .utf8)
        print(file)
        
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [file.absoluteString]
        task.launch()
        #endif
    }
}
