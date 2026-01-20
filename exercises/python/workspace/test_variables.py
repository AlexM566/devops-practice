#!/usr/bin/env python3
"""Test cases for variables exercise"""

def test_string_formatting():
    """Test that string formatting works correctly"""
    server_name = "web-server-01"
    port = 8080
    cpu_usage = 45.5
    is_healthy = True
    
    status = f"Server: {server_name} | Port: {port} | CPU: {cpu_usage}% | Healthy: {is_healthy}"
    assert "web-server-01" in status
    assert "8080" in status
    assert "45.5" in status
    assert "True" in status
    print("✓ String formatting test passed")

def test_list_operations():
    """Test list operations"""
    services = ["nginx", "redis", "postgres", "grafana"]
    services.append("prometheus")
    assert "prometheus" in services
    assert len(services) == 5
    
    services.remove("redis")
    assert "redis" not in services
    assert len(services) == 4
    assert services[0] == "nginx"
    assert services[-1] == "prometheus"
    print("✓ List operations test passed")

def test_dictionary_operations():
    """Test dictionary operations"""
    server_config = {
        "hostname": "prod-server-01",
        "ip": "192.168.1.100",
        "ports": [80, 443, 8080],
        "enabled": True
    }
    
    server_config["region"] = "us-east-1"
    assert "region" in server_config
    assert server_config["region"] == "us-east-1"
    
    server_config["hostname"] = "prod-server-02"
    assert server_config["hostname"] == "prod-server-02"
    print("✓ Dictionary operations test passed")

if __name__ == "__main__":
    test_string_formatting()
    test_list_operations()
    test_dictionary_operations()
    print("\n✅ All tests passed!")
