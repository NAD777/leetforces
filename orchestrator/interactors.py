from xmlrpc.client import ServerProxy

def xmlrpc_generate_interactor(ip: str, params):
    node = ServerProxy(f"http://{ip}:31337")
    result = node.generate_test_data(**params)
    return result

def xmlrpc_run_interactor(ip: str, params):
    node = ServerProxy(f"http://{ip}:31337")
    result = node.run_tests(**params)
    return result
