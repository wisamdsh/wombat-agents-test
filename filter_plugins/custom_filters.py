#!/usr/bin/python

from typing import List , Tuple

class FilterModule(object):
    def filters(self):
        return {'selectattrs': self.selectattrs}

    def selectattrs(self, data, attr) -> List[Tuple[str, List]]:
        result = {}
        for item in data:
            new_item = list(item.items())
            key = self.find(new_item, "Names")[0]
            key = key[1:]
          
            result[key] = self.find(new_item, attr)
        print(result)
        return result 
            
    
    def find(self, data, attr):
        for key, value in data:
            if isinstance(value, dict):
                new_data = list(filter(lambda x: x[0] != key, data + (list(value.items()))))
                return self.find(new_data, attr)
            elif key == attr:
                return value


# ===========================================       
# test example
# ===========================================

test_var = [{
                "ansible_loop_var": "container",
                "changed": True,
                "container": {
                    "Command": "docker-entrypoint.sh sh -c rabbitmq-server",
                    "Created": 1634822507,
                    "Id": "8600644dc62fa831968e139d563cbb83b9dae5fb67afc30bbb62897b039cf9f4",
                    "Image": "custom_rabbitmq:3.8-management",
                    "Names": [
                        "/ans-rmq3.8"
                    ],
                    "Ports": [
                        {
                            "IP": "0.0.0.0",
                            "PrivatePort": 5673,
                            "PublicPort": 5673,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 15671,
                            "Type": "tcp"
                        },
                        {
                            "IP": "0.0.0.0",
                            "PrivatePort": 15672,
                            "PublicPort": 15672,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 15691,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 25672,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 15692,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 4369,
                            "Type": "tcp"
                        },
                        {
                            "PrivatePort": 5671,
                            "Type": "tcp"
                        },
                        {
                            "IP": "0.0.0.0",
                            "PrivatePort": 5672,
                            "PublicPort": 5672,
                            "Type": "tcp"
                        }
                    ],
                    "Status": "Up 40 seconds"
                },
                "failed": False,
                "invocation": {
                    "module_args": {
                        "api_version": "auto",
                        "argv": None,
                        "ca_cert": None,
                        "chdir": None,
                        "client_cert": None,
                        "client_key": None,
                        "command": "sh -c \"{ epmd -names | grep name | awk '{print $2}'; cat /etc/hostname | tr -d '\\n'; } | tr '\\n' '@'\"",
                        "container": "8600644dc62fa831968e139d563cbb83b9dae5fb67afc30bbb62897b039cf9f4",
                        "debug": False,
                        "docker_host": "unix://var/run/docker.sock",
                        "ssl_version": None,
                        "stdin": None,
                        "stdin_add_newline": True,
                        "strip_empty_ends": True,
                        "timeout": 60,
                        "tls": False,
                        "tls_hostname": None,
                        "tty": False,
                        "use_ssh_client": False,
                        "user": None,
                        "validate_certs": False
                    }
                },
                "rc": 0,
                "stderr": "",
                "stderr_lines": [],
                "stdout": "rabbit@rmq",
                "stdout_lines": [
                    "rabbit@rmq"
                ]
            }]

x = FilterModule()
x.filters()["selectattrs"](test_var, "stdout")