from xmlrpc.server import SimpleXMLRPCServer


def f(a: int, b: int) -> int:
    return a + b

with SimpleXMLRPCServer(("0.0.0.0", 9999)) as server:
    server.register_introspection_functions()
    server.register_function(f)
    server.serve_forever()
