//
//  SimpleDirectedGraph.swift
//  SwiftyHomology
//
//  Created by Taketo Sano on 2020/10/08.
//

import Foundation

public struct SimpleDirectedGraph<VertexValue: CustomStringConvertible, EdgeValue: CustomStringConvertible> {
    public typealias VertexId = Int
    public typealias Options = [String: Any]
    
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
        
        public func isConnected(to: Vertex) -> Bool {
            outEdges.contains { $0.target == to }
        }
        
        public func edge(to: Vertex) -> Edge? {
            outEdges.first { $0.target == to }
        }
        
        public func removeEdge(to: Vertex) {
            if let i = outEdges.firstIndex(where: { $0.target == to }) {
                outEdges.remove(at: i)
            }
            if let i = to.inEdges.firstIndex(where: { $0.source == self }) {
                to.inEdges.remove(at: i)
            }
        }
        
        public var toVertices: [Vertex] {
            outEdges.map{ $0.target }
        }
        
        public var fromVertices: [Vertex] {
            inEdges.map{ $0.source }
        }
        
        public static func == (v: Vertex, w: Vertex) -> Bool {
            v.id == w.id
        }
        
        public var description: String {
            "v\(Format.sub(id))"
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
            return "\(source)\(target)"
        }
    }
    
    public private(set) var vertices: [VertexId: Vertex]
    public var options: Options

    public init(options: Options = [:]) {
        self.vertices = [:]
        self.options = [
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
    }
    
    public subscript(id: VertexId) -> Vertex {
        vertices[id]!
    }
    
    private var idCounter = 0
    
    @discardableResult
    public mutating func addVertex(value: VertexValue, options: Options = [:]) -> Vertex {
        idCounter += 1
        
        let id = idCounter
        let v = Vertex(id: id, value: value, options: options)
        vertices[id] = v
        return v
    }
    
    public mutating func removeVertex(_ v: Vertex) {
        vertices[v.id] = nil
        v.inEdges.forEach { e in
            let u = e.source
            u.outEdges.removeAll { $0.target == v }
        }
        v.outEdges.forEach { e in
            let w = e.target
            w.inEdges.removeAll { $0.source == v }
        }
    }
    
    public func addEdge(from v: Vertex, to w: Vertex, value: EdgeValue, options: Options = [:]) {
        v.addEdge(to: w, value: value, options: options)
    }
    
    public func edges(from v: Vertex, to w: Vertex) -> [Edge] {
        v.outEdges.filter { e in
            e.target == w
        }
    }
}

extension SimpleDirectedGraph where VertexValue: Hashable {
    public func vertex(ofValue v: VertexValue) -> Vertex? {
        vertices.first { $0.value.value == v }?.value
    }
}

extension SimpleDirectedGraph {
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
        let indexTable = Dictionary(pairs: vertices.keys.enumerated().map { ($1, $0) })
        let rawVertices = vertices.map { (id, v) -> [String: Any] in
            v.options.merging([
                "id": indexTable[id]!,
                "label": v.value.description,
                "shape": "box"
            ], overwrite: false)
        }
        let rawEdges = vertices.values.flatMap {
            $0.outEdges.map { e -> [String: Any] in
                e.options.merging([
                    "from": indexTable[e.source.id]!,
                    "to": indexTable[e.target.id]!,
                    "label": e.value.description
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
        let html = asHTML(title: title)

        if #available(OSX 10.12, *) {
            let file = FileManager().temporaryDirectory.appendingPathComponent("\(title ?? "tmp").html")
            try! html.write(to: file, atomically: true, encoding: .utf8)
            print(file)

            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = [file.absoluteString]
            task.launch()
        } else {
            // Fallback on earlier versions
        }
    }
}
